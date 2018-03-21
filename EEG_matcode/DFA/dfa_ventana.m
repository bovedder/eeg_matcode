% Esta función calcula el índice DFA con una ventana deslizante. Cada columna es tomada como una señal
%
% [m,bias,n]=dfa_ventana(data,ventana,encimamiento,options)
%
% m    =    pendientes con un ajuste de tendencia lineal, [número de ventanas x canales]
% bias =    ordenadas al origen del ajuste de tendencia,  [número de ventanas x canales]
% n    =    es el índice donde termina cada ventana, sirve para graficar las señales de entrada y su valor de índice fractal

function [m,bias,n]=dfa_ventana(data,ventana,encimamiento,options)

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

offset=round(ventana*(1-encimamiento));
[M,N]=size(data);

if M>ventana
    fin=M-ventana;
    n_ventanas=floor(fin/offset);

    if mod(fin,offset) > 0
	m=zeros(n_ventanas+1,N);
    	bias=zeros(n_ventanas+1,N);
    	n=zeros(n_ventanas+1,1);
    else
    	m=zeros(n_ventanas,N);
    	bias=zeros(n_ventanas,N);
    	n=zeros(n_ventanas,1);
    end

% figure(); %%para graficar las rectas
% hold on %%para graficar las rectas
    for v=1:n_ventanas
   	a=((v-1)*offset)+1;
   	b=a+ventana-1;
   	[z,F,p1]=dfa(data(a:b,:),options);
   	% plot(z,F); %%para graficar las rectas
   	m(v,:)=p1(:,1)';
   	bias(v,:)=p1(:,2)';
   	n(v)=b;
    end

    if mod(fin,offset)>0
    	[z,F,p1]=dfa(data(M-ventana+1:M,:),options);
    	m(end,:)=p1(:,1)';
    	bias(end,:)=p1(:,2)';
    	%n(end)=M-ventana+1;
    	n(end)=M;
    end
else
	[z,F,p1]=dfa(data,options);
	m=p1(:,1);
	bias=p1(:,2);
	n=M;
end

