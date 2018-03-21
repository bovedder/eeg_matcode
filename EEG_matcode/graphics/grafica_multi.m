% realiza la grafica de varias senales en un mismo eje, con un espaciado entre cada una
% 
% [factor,Data]=grafica_multi(Data,x,factor,FMT,nombres)
%
% Data = matriz con los datos a graficar (cada columna es una senal)
% x = vector con  valores de x
% factor = valor del factor a escalar las gráficas.
% FMT = formato que se desea tenga la grafica 
% 
% Los valores de regreso son el factor de amplificación y la matriz con las senales
% acomodadas para graficar con las medias cambiadas.

function [factor,Data]=grafica_multi(Data,x,factor,FMT,nombres)

[n_puntos,n_senales]=size(Data);


if nargin<2
	x=[1:n_puntos];
end

if nargin<3
  factor=[];
end

if nargin<4
	FMT='';
end



%Data_movidas=zeros(n_puntos,n_senales);

if isempty(factor)
  [Data, factor]=normaliza(Data(:),[],1,0);
else
  Data=normaliza(Data(:),factor,1,0);
end

Data=reshape(Data,n_puntos,n_senales);
%Data=Data-repmat(mean(Data),n_puntos,1);
Data=Data+(repmat([0:n_senales-1],n_puntos,1));

%for i=1:n_senales
%	Data_movidas(:,i)=Data_movidas(:,i)+(i-1);
%end
if nargout==0
  Data=Data';
  eval( ['plot(x,Data,''' FMT ''');' ] );
  %plot(x,Data',FMT);

  if nargin<5
    nombres=num2str([1:n_senales]');
  end

  if ~isempty(nombres)
    for i=1:n_senales
      text(0,i-1,[nombres(i,:) ' '],'HorizontalAlignment','right');
    end
  end
end

grid on
axis tight;
set(gca,'Ytick',[]);
%axis('labelx');
