% This function estimates the pwer spectral density using the Welch's
% periodogram method, on a sliding window.
% The complete signal is divided on different segments and the Welch 
% method is applied to each of them. By the default for each window the 
% Periodogram is estimated using an overlapping of 70%, this value is 
% is not controlled by encimamiento variable.
%
% [S,n]=pwelch_slider(data,ventana,encimamiento,options)
%
% S is the matrix with the full spectrum for each window
% n ius a vector with the window location index
% data is a matrix with signals in a column wise format
% ventana is the window lenght
% encimamiento is the percentage (0--1) of overlapping
% options is a string to complete the pwelch calling
%
% erik [dot] bojorges [at] ibero [dot] mx
% 2016/08/24
% ERBV


function [S,n]=pwelch_slider(data,ventana,encimamiento,options)


if nargin<2
    error('indique la ventana güey');
end

if nargin<3
    encimamiento=0.5;
    options=[''];
end

if nargin<4
    if ischar(encimamiento)
        options=encimamiento;
        encimamiento=0.5;
    else
        options=[''];
    end
end

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if isOctave
    noverlap=0.7;
else
    noverlap=ceil(ventana*0.3);
end

offset=round(ventana*(1-encimamiento));
[M,N]=size(data);

if M>ventana
    fin=M-ventana;
    n_ventanas=floor(fin/offset);

    if mod(fin,offset) > 0
        S=zeros(n_ventanas+1,1+ventana/2,N);
    	n=zeros(n_ventanas+1,1);
    else
    	S=zeros(n_ventanas,1+ventana/2,N);
    	n=zeros(n_ventanas,1);
    end

    for v=1:n_ventanas
        a=((v-1)*offset)+1;
        b=a+ventana-1;
        for n_sig=1:N
            S(v,:,n_sig)=pwelch(data(a:b,n_sig),ventana/2,noverlap,ventana);
        end
         n(v)=b;
    end

    if mod(fin,offset)>0
        v=v+1;
        for n_sig=1:N
            S(v,:,n_sig)=pwelch(data(M-ventana+1:M,n_sig),ventana/2,noverlap,ventana);
        end
        n(end)=M;
    end
    
else
    for n_sig=1:N
        S(:,n_sig)=pwelch(data(:,n_sig),ventana/2,0.7,ventana);
    end
end
