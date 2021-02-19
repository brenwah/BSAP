function [noise,am_noise]=noise_gen(lof,hif,modf,m,dur,fs,ramp);
% [noise,am_noise]=noise_gen(lof,hif,modf,m,dur,fs)
% lof = lowest frequency
% hif = highest frequency
% modf = modulation frequency
% m = modulation depth (0-1)
% dur = duration (seconds)
% fs = sampling frequency
% ramp is the ramp duration
if nargin < 7
    ramp = .05; % default ramp size
end

% updates
%2009.03.24 added round code for determination of gate length - this allows
%for a wider range of sampling frequencies. Also added floor command so
%that it will accept non-even sampling rate (e.g. 48828.13 Hz)

npts=round(fs*dur);   srate=1/fs;

%CREATE noise [noise generation code courtesy of Les Bernstein]

hzppt=1/(npts.*srate);
locut=round(lof/hzppt)+1;
hicut=round(hif/hzppt)+1;

numcomp=(hicut-locut)+1;
specbuf=zeros(1,npts);

specbuf(:,locut:hicut)=randn(1,numcomp)+i*randn(1,numcomp);
expower=(1./npts).^2.*numcomp;

noise=real(ifft(specbuf))./expower.^0.5;

%modulate the noise
x= 1:npts;
mod=(1+m.*(cos((2*pi*modf/fs)*x)));
am_noise=mod.*noise;

%generate onset/offset ramps
if ramp ~=0
    onset_dur=ramp; offset_dur=ramp;
    onset=round(onset_dur*fs); offset=round(offset_dur*fs); %length in samples
    
    on_ramp=(sin(pi/2*x(1:onset)/x(onset))).^2;
    offset_ramp=fliplr(on_ramp);
    
    e=ones(size(x));
    e(1:onset)=e(1:onset).*on_ramp;
    e(floor(npts-offset+1:npts))=e(floor(npts-offset+1:npts)).*offset_ramp;
    
    noise=e.*noise;
    am_noise=e.*am_noise;
end
    
    %equate the RMS levels
    maxrms=1;
    noise_rms = sqrt(sum(noise .* noise)/length(noise));
    am_noise_rms = sqrt(sum(am_noise .* am_noise)/length(am_noise));
    
    noisefac = maxrms/noise_rms;
    am_noisefac = maxrms/am_noise_rms;
    
    am_noise=am_noise.*am_noisefac;
    noise=noise.*noisefac;
