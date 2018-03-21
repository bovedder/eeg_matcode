% [PSD,n,S]=PSD_analysis(eeg,window,Fs)

function [PSD,n,S]=PSD_analysis(eeg,window,Fs)

[~,n_channels]=size(eeg);

eeg=detrend(eeg','constant');
eeg=detrend(eeg','constant');

[S,n]=pwelch_slider(eeg,round(Fs*window),0.95);

PSD.beta_pow=zeros(length(n),n_channels);
PSD.alpha_pow=PSD.beta_pow;
PSD.beta1_pow=PSD.beta_pow;
PSD.beta2_pow=PSD.beta_pow;

alpha_limits = round( [8  : 0.5 : 14] * window) ;
beta_limits  = round( [14 : 0.5 : 30] * window) ;
beta1_limits = round( [14 : 0.5 : 22] * window) ;
beta2_limits = round( [22 : 0.5 : 30] * window) ;
gamma_limits = round( [30 : 0.5 : 100] * window) ;

for i=1:n_channels
  PSD.alpha_pow(:,i)=20*log10( trapz( squeeze( S(:,alpha_limits,i) ), 2  )./trapz( squeeze( S(:,:,i) ), 2  ) );
  PSD.beta1_pow(:,i)=20*log10( trapz( squeeze( S(:,beta1_limits,i) ), 2  )./trapz( squeeze( S(:,:,i) ), 2  ) );
  PSD.beta2_pow(:,i)=20*log10( trapz( squeeze( S(:,beta2_limits,i) ), 2  )./trapz( squeeze( S(:,:,i) ), 2  ) );
  PSD.beta_pow(:,i)=20*log10( trapz( squeeze( S(:,beta_limits,i) ), 2  )./trapz( squeeze( S(:,:,i) ), 2  ) );
  PSD.gamma_pow(:,i)=20*log10( trapz( squeeze( S(:,gamma_limits,i) ), 2  )./trapz( squeeze( S(:,:,i) ), 2  ) );
end
