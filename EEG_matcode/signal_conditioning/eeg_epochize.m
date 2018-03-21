% This function realizes epochs extractions of a data set. currently works
% only for 2d data.
%
% [epochs]=epochize(data,offset,Fs,ventana,tend)
%
% epochs  = 3D matrix [trial, epoch length, channels]
% data    = 2D matrix [sample, channels]
% offset  = vector with starting sample of every epoch
% Fs      = sampling rate
% ventana = 2 element vector with starting and ending time window in ms
% tend    = if not zero trend of every epoch is eliminated.
%
% excepting tend, all other parameters are mandatory. If
% ventana, e.g. ventana = [-200 800] then epochs will be from -200 ms
% before to 800 ms after the epoch onset marked on the offset vector.
% Epochs which start or end are before initial and final data sample, are
% not included on epochs matrix. By default trend on epochs IS NOT eliminated. 
%
% ERBV 2017/12/28
% erik[dot]bojorges[at]ibero[dot]mx


function [epochs]=eeg_epochize(data,offset,Fs,ventana,tend)

if nargin<5
    tend=0;
end

[~,n_channels]=size(data);

indexes=ceil([Fs * ventana(1)/1000 : 1 : Fs*ventana(2)/1000]);
n_samples=length(indexes);
t=1000*indexes/Fs;

eidxs=offset(:,1)+indexes(end);
iidxs=offset(:,1)+indexes(1);
offset=offset(eidxs<size(data,1) & iidxs>1,:);
n_epochs=length(offset);
idxs=repmat(offset(:,1),1,length(indexes)) + repmat(indexes,length(offset),1);
idxs=idxs';

epochs=data(idxs(:),:);

if (tend~=0)
    epochs=reshape(epochs(:),n_samples,n_epochs*n_channels);
    epochs=detrend(epochs);
end

epochs=reshape(epochs(:),n_samples,n_epochs,n_channels);
epochs=permute(epochs,[2,1,3]);