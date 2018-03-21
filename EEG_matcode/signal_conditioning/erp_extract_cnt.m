function [epochs, stimuli,Fs,t]=erp_extract_cnt(file, ventana, ch_eeg)

if (nargin<2)
    ventana=[0 1000];
end

% Se cargan los datos del cnt, en particular los datos del Scan de Daniel
% son formato int32, por ello se coloca esa directiva en la función
% loadcnt. Dicha función es parte de EEGLAB, aunque yo solo la descargué
% por no requerir otras.
% 
% stimuli tiene el código de epocas en la segunda columna y en la primera
% tiene los índices de inicio de estimulación.

cnt=loadcnt(file,'dataformat','int32');
Fs=cnt.header.rate;
aux = [cnt.event.offset];
n_epochs=length(aux);
aux2 = [cnt.event.stimtype];
stimuli=[aux' aux2'];
clear aux aux2;

% Esto construye los canales laplacianos de Cz y Pz
% aux={cnt.electloc.lab};
% A=strfind(aux,'PZ');
% P(1)=find(~cellfun(@isempty,A));
% A=strfind(aux,'P3');
% P(2)=find(~cellfun(@isempty,A));
% A=strfind(aux,'P4');
% P(3)=find(~cellfun(@isempty,A));
% 
% A=strfind(aux,'CZ');
% C(1)=find(~cellfun(@isempty,A));
% A=strfind(aux,'C3');
% C(2)=find(~cellfun(@isempty,A));
% A=strfind(aux,'C4');
% C(3)=find(~cellfun(@isempty,A));
% 
clear aux;
% 
data=double(cnt.data);
n_channels=size(data,1);
% 
% mask=zeros(2,size(data,1));
% mask(1,P(1))=1;
% mask(1,P(2:3))=-0.5;
% 
% mask(2,C(1))=1;
% mask(2,C(2:3))=-0.5;
% 
% C_lpc=(mask*data)';

data=data';

% Se cortan las épocas de EEG y se acomodan en una matriz cuyas dimensiones
% son [n_epocas,n_muestras,n_canales]. El vector de tiempo que se regresa
% está acotado a la ventana de análisis que se especificó. La cual está
% expresada en ms
% indexes=ceil([Fs * ventana(1)/1000 : 1 : Fs*ventana(2)/1000]);
% n_samples=length(indexes);
% t=1000*indexes/Fs;
% 
% eidxs=stimuli(:,1)+indexes(end);
% stimuli=stimuli(eidxs<size(data,1),:);
% n_epochs=length(stimuli);
% idxs=repmat(stimuli(:,1),1,length(indexes)) + repmat(indexes,length(stimuli),1);
% idxs=idxs';

if nargin<3
    ch_eeg=[1:n_channels];
end

%data=[data(:,ch_eeg) C_lpc];

data=[data(:,ch_eeg)];

[eeg_data]=eeg_preprocessing(data);
epochs=epochize(eeg_data,stimuli(:,1),Fs,ventana,1);

t=linspace(ventana(1),ventana(2),size(epochs,2));

% 
