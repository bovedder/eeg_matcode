%~ Estima el periodograma de welch en una matriz 3D, util para los casos
%~ donde el EEg es acomodado en este tipo de estructura. La matriz
%~ debe tener la siguiente conformacion [n_epocas, n_muestras, n_canales]
%~ 
%~ [espectro]=pwelch_mat3d(data,w_length,overlap,Nfft)
%~ 
%~ ERBV 2014/04/24

function [espectro]=pwelch_mat3d(data,w_length,overlap,Nfft)

[n_epocas,n_muestras,n_canales]=size(data);

if nargin<4
    espectro=zeros(n_epocas,round(w_length/2)+1,n_canales);
    Nfft=512;
else
    espectro=zeros(n_epocas,round(Nfft/2)+1,n_canales);
end
    

for epoch=1:n_epocas
    for chann=1:n_canales
        espectro(epoch,:,chann) = pwelch(squeeze(data(epoch,:,chann)),w_length,overlap,Nfft);
    end
end
