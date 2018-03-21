% linitopoplot grafica un mapa topografico interpolando los valores
% de los electrodos. Las posiciones de los electrodos son leídas de 
% un archivo, y pueden estar escritas en coordenadas polares o carte-
% sianas. El gráfico siempre se pinta con la nariz hacia el norte, y
% el mapa de color es 'hot'
%
% linitopoplot(z,file,coord,limits)
%
% z = vector de datos (un dato por electrodo), la longitud del 
% vector debe coincidir con la cantidad de datos guardados en el 
% archivo de otra forma, marcara un error de dimensiones.
%
% file = nombre del archivo que contiene las posiciones del 
% arreglo, debe estar escrito en el siguiente orden: indice angulo 
% (posicion x) radio (posicion y) nombre del canal. El ángulo debe 
% estar escrito en grados y el radio menor a 0.5. En caso de usar 
% posiciones x,y estas deben estar inscritas en un círculo de radio
% 0.5. De otra forma la interpolacion será defectuosa.
%
% coord = indica que el archivo esta escrito en coordenadas 
% cartesianas (1) o polares (0), por omisión se asumen polares.
%
% limits = limites para la funcion imagesc ([bajo alto]), estos 
% serán los valores entre los cuales interpola dicha funcion.
% 
% ERBV 16/02/2012

function linitopoplot2(z,file,coord,limits)

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if nargin<4
    limits=[min(z) max(z)];
end

if nargin<3
    coord=0;
end

z=z(:);
n_channels=length(z);


fid = fopen(file);
theta = zeros(n_channels,1);
rho = zeros(n_channels,1);
name = {};

%for i = 1:n_channels
if isOctave
    i=1;    
    while ~feof(fid)
       [~,theta(i),rho(i),name{i}] = fscanf(fid,'%u %f %f %s','C');
       i=i+1;
    end
    
else
    for i=1:n_channels
       [A]= fscanf(fid,'%u %f %f');
       theta(i)=A(2);
       rho(i)=A(3);
       name{i}=fgets(fid);
    end
end
fclose(fid);

if (coord~=0)
    x=theta;
    y=rho;
    rho=abs(x+y*I);
    theta=arg(x+y*I);
    theta=theta*180/pi;
else
    x = rho.*cos(-(pi/2)+pi*theta/180);
    y = rho.*sin(-(pi/2)+pi*theta/180);
end

H=convhull(x,y);
H=H(1:end-1);

res = [0:1023]'/1024;

r = 0.5;

xx = r*cos(-(pi/2)+pi*theta(H)/180);
yy = r*sin(-(pi/2)+pi*theta(H)/180);

thetae=[0:2/2048:(2-2/2048)];

ff=0.5*cos(pi*thetae);
gg=0.5*sin(pi*thetae);

zetate=interp1(pi*theta(H)/180,z,thetae );

xe=[x;ff'];
ye=[y;gg'];
ze = [z;zetate'];

[XX,YY] = meshgrid(res-0.5,res-0.5);
ZZ = griddata(xe,ye,ze,XX,YY,'linear');
inx = find(XX.^2+YY.^2 > r^2);
ZZ(inx)= Inf;

imagesc(XX(1,:)',YY(:,1),ZZ,limits);
hold on;
%plot(xx,yy,'k',x,y,'ko');
plot(x,y,'ko','Linewidth',5)

%pinta orejas y nariz
orejas_x=0.05*cos(linspace(-pi/2,pi/2,1000));
orejas_y=0.05*sin(linspace(-pi/2,pi/2,1000));
%plot(orejas_x+r,orejas_y,'k');
plot(orejas_x+r,orejas_y,'k','Linewidth',5);

orejas_x=0.05*cos(linspace(pi/2,3*pi/2,1000));
orejas_y=0.05*sin(linspace(pi/2,3*pi/2,1000));
plot(orejas_x-r,orejas_y,'k','Linewidth',5);

nariz_x=[-r/10 0 r/10];
nariz_y=[0 -r/10 0];
plot(nariz_x,nariz_y-r,'k','Linewidth',5);

hold off;

axis equal;
axis square;
axis('off');
axis([-r-0.05 r+0.05 -r*(1.1) r])
colormap('hot');
colorbar;

