function [r2,Fpred,alpha] = dfa(x, options)

% estimacion del indoce alpha basado en el algoritmo propuesto por Peng 
% usando el método conocido como DFA. Esta basado sobre el código  
% descrito en physionet.org
%
% [r2,Fpred,alpha] = dfa(x, options)
%
% r2 = coeficientes de regresion para cada ajuste
% Fpred = valores de ajuste de los distintos valores de fluctuacion.
% alpha = matriz de indices de regresion [alpha,bias]; cada renglon son 
%         los valores de la regresion por cada una de las senales que se 
%         usan en el algoritmo
% x = matriz de senales, cada columna se toma como una senal
% options = opciones tal cual se usan en la funcion dada por physionet
% 
%           -l es el minimo tamaño de ventana a ser usado
%           -u es el maximo tamaño de ventana a ser usado
%           -d es el grado del ajuste a ser usado en cada ventana
%           -i no se hace la integracion de los datos
%           -s aun no funcionando del todo, pero se supone que hace una 
%              ventana deslizante.
%
% options= '-l 22 -u 50 -d 2'
%
% esto hara que se calcule el valor de alpha usando una ventana minima 
% de 22 y maxima de 50 haciendo un ajuste de grado 2 en cada una de las
% ventanas
% 
% Por las pruebas realizadas esta funcion obtiene el valor de alpha con un 
% offset de 0.002, respecto a la estimacion del método de physionet; aunque
% este valor cambia al parecer dependiendo del valor del alpha. En la señal 
% sintetica de 0.5 es de 0.0024, para alpha=0.8 offset=0.0027 y para alpha=1.5 % alpha=0.003.
%
%
% ERBV 
% erit [dot] bojorges [at] ibero [dot] mx
% 18/julio/2013
% 
% ERBV 2014/04/24



isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if nargin < 2
   pflag = 0;
end

[N,N_signals]=size(x);
y = cumsum(x);
range=[4,floor(N/4)];
inc=0;
cadenas={'-d'; '-h'; '-i'; '-l'; '-u'; '-s'};
degree=1;

for  i=1:length(cadenas)
    ptr=findstr(options, cadenas{i});
    if ~isempty(ptr)
        sp=findstr(options(ptr:end),' ');
        if length(sp)<2
            sp(2)=length(options);
        end
        switch i
            case 1
                degree = str2num(options(ptr+3:sp(2)));
            case 3
                y=x;
            case 4
                range(1) = str2num(options(ptr+3:sp(2)));
            case 5
                range(2) = str2num(options(ptr+3:sp(2)));
            case 6
                inc=1;
        end
    end
end

bmin=range(1);
bmax=range(2);

if(bmax>N)
    bmax=N;
end

% Se estiman los tamaños de las ventanas a ser usadas para el ajuste. Siguiendo la regla geometrica de crecimiento que se usa en la función de physionet. El vector ns tiene todos los tamanos de ventana a ser usado. 

if inc==0
    boxratio = 2^(1/8);
    rslen= floor(((log10(bmax/bmin))/log10(boxratio))+1.5);
    ns=zeros(rslen,1);
    i=1;
    n=2;
    ns(1)=bmin;
    while(n<=rslen && ns(n-1)<bmax)
        i=i+1;
        rw=round((bmin*boxratio^i)+0.5);
        if rw>ns(n-1)
            ns(n)=rw;
            n=n+1;
        end
    end

    n=n-1;
    if (ns(--n)>bmax)
        n=n-1;;
    end

    ns=ns(1:n);
else
    ns=1:length(x)/4;
end

% En esta parte se hace el recorte de las ventanas por cada una de las senales a partir de la estimacion de los tamaños de ventana que se estimaron en la seccion anterior. Se hace un recorte de cada senal en funcion de cada tamano de ventana y se estima el error mediante la funcion detrend
nn = length(ns);
F = zeros(nn,N_signals);
for n=1:nn
    r=floor(N/ns(n));    
    for s=1:N_signals
       t = reshape(y(1:r*ns(n),s),ns(n),r);
       t = detrend(t,degree);
       t=t(:);
       if(mod(N,ns(n))~=0)
           t=[t; detrend(y(r*ns(n)+1:end,s),1)];
       end
       F(n,s) = sqrt(mean(t.^2));
    end
end


% Aca se estima la regresion lineal y los parametros, ergo el valor de alpha asi como la bondad del ajuste.
lns = log10(ns);
lF = log10(F);
alpha=zeros(N_signals,2);
r2=zeros(N_signals,1);

for s=1:N_signals
    [alpha(s,:),S]=polyfit(lns,lF(:,s),1);
    if ~isOctave
        S.yf=polyval(alpha(s,:),lns);
    end
    r2(s)=rsquare(lF(:,s),S.yf);
    lFpred(:,s)=S.yf;
end

Fpred=[lns lF];
%Fpred = 10.^(lFpred);
