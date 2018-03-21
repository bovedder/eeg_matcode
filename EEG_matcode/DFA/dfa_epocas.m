function [m,bias,N,F]=dfa_epocas(data,options)

[n_epocas,n_muestras,n_canales]=size(data);

m=zeros(n_epocas,n_canales);
%[n,f,p]=dfa_physionet(squeeze(data(1,:,:)),options);
[n,f,p]=dfa(squeeze(data(1,:,:)),options);
[x,y]=size(n);
N=zeros(x,y,n_epocas);
F=zeros(x,y,n_epocas);
for i=1:n_epocas
    %[n,f,p]=dfa_physionet(squeeze(data(i,:,:)),options);
    [n,f,p]=dfa(squeeze(data(i,:,:)),options);
    m(i,:)=p(:,1)';
    bias(i,:)=p(:,2)';
    N(:,:,i)=n;
    %F(:,:,i)=f;
end

