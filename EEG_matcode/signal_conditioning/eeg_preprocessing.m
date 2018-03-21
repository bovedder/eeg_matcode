% Esta función hace el preprocesamiento de la señal cruda de EEG. Los
% procesos que hace son:
% - Filtrado entre 0.1 y 12 Hz, con un eliptico de orden 3
% - Referencia al CAR
% - Normalización para tener media cero y varianza unitaria.
%
% [signal]=eeg_preprocessing(signal, paco)
%
% El control de las etapas de preprocesamiento se controlan con la variable
% paco = PArametros de ACOndicionamiento y Operacion
% paco.car == 1 remueve CAR
% paco.ica == 1 ejecuta la funcion deartifactingICA
% paco.norm == 1 normaliza a media 0 y varianza 1 todas las se�ales
%
% use la siguiente secuencia de comandos para inicializar su paco
%
% paco.car = 1;
% paco.ica = 0;
% paco.norm = 1;
% paco.Fs = 1000;
% paco.filtro={};
% [paco.filtro{1}.b, paco.filtro{1}.a]=ellip(3,0.01,40, 2*[0.1 12]/paco.Fs);
%
% ERBV 2017-dic-15
% erik[dot]bojorges[at]uia[dot]mx
%

function [signal]=eeg_preprocessing(signal, paco)

    if nargin<2
    % paco = PArametros de ACOndicionamiento y Operacion
    % car == 1 remueve CAR
    % ica == 1 ejecuta la funcion deartifactingICA
    % local_tend == 1 remueve tendencias locales de las �pocas
    % norm == 1 normaliza a media 0 y varianza 1 todas las se�ales
        paco.car = 1;
        paco.ica = 0;
        paco.norm = 1;
        paco.Fs = 1000;
        paco.filtro={};
        [paco.filtro{1}.b, paco.filtro{1}.a]=ellip(3,0.01,40, 2*[0.5 12]/paco.Fs);
    end


    [n_muestras,n_canales]=size(signal);
    uncanal=(n_canales==1);
   
    %signal=double(signal);
        
    if paco.car==1
        signal=detrend(signal');
        signal=signal';
        signal=detrend(signal);
    end

    % se filtra la senal con tantos filtros se desee, los coeficientes de los
    % filtros debe estar en una estructura filtro.b{} y filtro.a{}. Si filtro

    if ~isempty(paco.filtro)
        for i=1:length(paco.filtro)
            b=paco.filtro{i}.b;
            a=paco.filtro{i}.a;
            signal=filtfilt(b,a,signal);
        end
    end


    if paco.norm==1
        signal=normalizasd(signal);
    end

    if paco.ica==1 
        [A,W,mrem,signal]=deartifactingICA(signal);
    end
