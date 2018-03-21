% Esta funcion lee directamente los datos guardados posterior a una prueba con el
% BCI2000. La información usada para la construccione de la funcion fue obtenida 
% de:
% 
% http://www.bci2000.org/wiki/index.php/Technical_Reference:BCI2000_File_Format#Parameter_Definitions
%
% Por el momento sirve para cargar archivos y estados, la parte de parametros es
% ignorada por no tener mucho sentido actualmente.
%
% [signal, states, Fs]=lini_read_bcidat(filename);
% 
% signal = matriz donde se almacena toda la informacion de los canales
% states = estructura donde se almacena el estado de la adquisición, fundamental
%          para saber como cortar epocas, y marcaje de eventos del experimento
%
% ERBV 30/mayo/2015

function [signal,states, Fs] = lini_read_bcidat(filename)

% para poder leer el tamaño del archivo y calcular el número total de muestras
g=dir(filename);

% los archivos están escritos en little endien
file_id=fopen(filename,'r','ieee-le');

% La primera linea del archivo contiene la información básica, 
% BCIversion, # canales, formato de los datos, longitud del encabezado, 
% Lomgitud del vector de estados.
cadena=fgets(file_id);

[tok,cadena]=strtok(cadena);

% Los campos se van cargando y automáticamente se van formando las variables 
% básicas para la lectura del archivo.
while (~isempty(tok)) 
    [value,cadena]=strtok(cadena);
    
    if (isempty( str2num(value) ))
        value=['''' value '''' ];
    end
        
    eval([tok value ';']);
    [tok,cadena]=strtok(cadena);
end

cadena=fgets(file_id);
% [ State Vector Definition ]
% Una vez que se acaban las variables básicas, empieza la definición de los 
% estados. Que son las variables que almacenan la información de los eventos 
% durante el registro.
%
% Por cada muestra de datos, hay un vector de estados. El cual se codifica 
% siguiendo las reglas que se detallan en esta sección.
% por cada variable se indica la longitud en bits de cada estado así como
% el offset en bytes y bit respecivamente para poder leerlo.
%
% states_list guarda los nombres de los estados
% states_offsets guarda las reglas para poder leer el vector de estados.
%

cadena=fgets(file_id);
states_offsets=[];
states_list=[];
n_states=0;
while ~strncmp(cadena,'[ Parameter Definition ]',12)
    [tok,cadena]=strtok(cadena);
    n_states = n_states+1;
    %eval(['states.' tok '=[];']);
    states_list{n_states}=tok;
    states_offsets=[states_offsets; str2num(cadena)];
    cadena=fgets(file_id);
end

% [ Parameter Definition ]
% Terminando la seccion de la definición del vector de estados, comienza la 
% seccion de la definicion de los parametros, con la cual se puede generar un
% archivo.prm para repetir la adquisición.

pos=ftell(file_id);
cadena=fread(file_id,HeaderLen-pos);
cadena=char(cadena');
aux=findstr(cadena,'SamplingRate=');
Fs=0;
if ~isempty(aux)
    cadena=cadena(aux:end);
    [tok,cadena]=strtok(cadena);
    [Fs,cadena]=strtok(cadena);
    Fs=str2num(Fs(Fs<65));
end

fseek(file_id,pos,'bof');
cadena=fread(file_id,HeaderLen-pos);
cadena=char(cadena');
aux=findstr(cadena,'SourceChGain=');
ChGain=ones(SourceCh,1);
if ~isempty(aux)
    cadena=cadena(aux:end);
    [tok,cadena]=strtok(cadena);
    [tok,cadena]=strtok(cadena);    
    for i=1:SourceCh
        [tok,cadena]=strtok(cadena);
        ChGain(i)=str2num(tok);
    end
end

fseek(file_id,pos,'bof');
cadena=fread(file_id,HeaderLen-pos);
cadena=char(cadena');
aux=findstr(cadena,'StateVectorLength=');
if ~isempty(aux)
    cadena=cadena(aux:end);
    [tok,cadena]=strtok(cadena);
    [tok,cadena]=strtok(cadena);    
    states_length=str2num(tok);
end

% se calcula la longitud del vector de estados en bytes
% states_length=ceil(sum(states_offsets(:,1))/8 );
%n_states=size(states_list,1);

if ~exist('DataFormat')
  DataFormat='int16';
end

dvalue=4;
if strcmp(DataFormat,'int16');
    dvalue=2;
end

% se estima el numero de muestras del registro siguiendo esta regla
samples=(g.bytes-HeaderLen)/( SourceCh*dvalue + states_length);

signal=zeros(samples,SourceCh);
prestate=false(samples, states_length*8);

for i=1:n_states
    eval(['states.' states_list{i} '= zeros(samples,1);']);
end

% al inicio de los datos. Este paso salta el encabezado completamente y se 
% coloca justo al inicio del archivo donde estan almacenados datos y estados.
fseek(file_id,HeaderLen,'bof');

% por cada muestra hay un vector de estados que debe ser codificado, en cada 
% lectura se obbtienen los datos de cada canal y el vector de estados 
% por comodidad se acomodaron en una matriz de bits para poder codificarlos 
% despues de la lectura y hacerlo más eficientemente.


%for i=1:samples
%   [signal(i,:),count]=fread(file_id,[1, SourceCh],DataFormat); 
%   [aux,count]=fread(file_id,states_length,'uchar',0,'ieee-le');

%   %aux_bit=[];
%   for ns=1:states_length
%        %aux_bit=[aux_bit bitget(aux(ns),1:8)];
%        prestate(i,1+(ns-1)*8:ns*8)=bitget(aux(ns),1:8);
%   end
%   %prestate(i,:)=aux_bit;   

%end

% se carga la senal
salto=( dvalue*(SourceCh-1) ) + states_length;
for i=1:SourceCh
    fseek(file_id, HeaderLen + ( dvalue*(i-1) ), 'bof' );
    [signal(:,i),count]=fread(file_id, samples, DataFormat, salto, 'ieee-le');
end
signal=(diag(ChGain)*signal')'; %.*(ChGain*ones(1,samples));

% se cargan los estados
salto=(dvalue*SourceCh) + (states_length-1);
for ns=1:states_length
    fseek(file_id,HeaderLen + (dvalue*SourceCh) + (ns-1), 'bof');
    [aux_bit,count]= fread(file_id, samples, 'uint8', salto,'ieee-le');

    for b=1:8
        prestate(:, b + (ns-1)*8 )=bitget(aux_bit,b);
    end
end

fclose(file_id);


% En cada iteración la matriz de vectores de estado es cortada acorde con la
% regla marcada en states_offsets [ State Vector Definition]. Cada renglon es 
% una lectura, así este procedimiento matricial optimiza el tiempo de lectura.
% Antes de convertir el arreglo de bits a sus valores estos deben ser volteados
% ya que el orden de los bits es little-endian
for ns=1:n_states
    aux_bit=prestate(:,1:states_offsets(ns,1));
    prestate=prestate(:,states_offsets(ns,1)+1:end);
    
    aux_bit=num2str(aux_bit(:,end:-1:1));
    aux_bit=bin2dec(aux_bit);
    eval(['states.' states_list{ns} '= aux_bit;']);
end

