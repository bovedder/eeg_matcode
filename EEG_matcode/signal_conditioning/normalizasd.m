% lleva el conjunto de datos a una distribución de media 0 y varianza 1.
%
% [normal,factor]=normalizasd(signal)
%
% normal = matriz de datos escalados
% factor = vector de factores de escalamiento
% signal = matriz de datos de entrada cada columna es escalada para ajustar a los 
%          valores mencionados

function [normal,factor]=normalizasd(signal,factor)

media=mean(signal);
sd=std(signal);
max_signal=media+sd;
min_signal=media-sd;

[M,N]=size(signal);


if nargin<2
    factor=zeros(2,N);
    signal=signal-repmat(media,M,1);
    %~ factor=(2)./(max_signal-min_signal);
    factor(1,:)=1./sd;
    %~ normal=(repmat(factor,M,1).*(signal-repmat(min_signal,M,1)))-1;
    normal=repmat(factor(1,:),M,1).*signal;
    factor(2,:)=media;
else
    %~ normal=(repmat(factor,M,1).*(signal-repmat(min_signal,M,1)));
    %~ normal= normal-repmat(mean(normal),M,1);
    
    normal=signal./repmat(factor(1,:),M,1);

    if (isvector(factor))
        factor=[factor;-mean(normal)];
    end

    normal=normal+repmat(factor(2,:),M,1);
end
