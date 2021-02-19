function [X]= myLogFreqNoisecopy(startFreq, endFreq,rpo,depth,phaseshift)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Date: June 12, 2012
%Author: Benjamin Kirby
%Purpose: Create log-spaced summed sinusoidal noise
%modified: Oct 15th, 2015 by Marc Brennan to specify mod depth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=log10(startFreq);
b=log10(endFreq);
rpo=rpo/2; % rectification doubles the number of peaks, therefore divide
freq=logspace(a,b,400); %create log-spaced frequency vector
N=400; % total number of desired sinusoids
x=zeros(17640,N); %intialize output matrix
octaveWidth=log2(endFreq/startFreq)/log2(2);
size(x)
fs=400;
ts=1/fs;
len = 1;              % length of sine wave in sec
n = [0:1:fs*len-1]';  % discrete-time index
mag=abs(cos(2*pi*octaveWidth*rpo*n*ts+phaseshift));
mag=10.^(((mag*depth)-30)/20); %put amplitude vector in dB change one of the 30 to change depth
for ii=1:1:N,    %create sinusoids for desired frequencies
    low=0;
    high=2*pi;
    phase=low+(high-low)*rand;
    currentFreq=freq(ii);
    x(1:17640,ii)=mySine(1,currentFreq,phase)*mag(ii);
end
X=sum(x,2);   %sum sinusoids to create noise