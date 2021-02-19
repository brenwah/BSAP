function gated = gate(signal,gate_dur,fs)
% gated = gate(signal,gate_dur,fs)
%returns a gated signal
%created by marc brennan on 4/7/09


%generate onset/offset ramps
npts=length(signal);
x= 1:npts; 
onset_dur=gate_dur; offset_dur=gate_dur;
onset=round(onset_dur*fs); offset=round(offset_dur*fs); %length in samples 
 
on_ramp=(sin(pi/2*x(1:onset)/x(onset))).^2;         
offset_ramp=fliplr(on_ramp); 
 
e=ones(size(x));       
e(1:onset)=e(1:onset).*on_ramp; 
e(floor(npts-offset+1:npts))=e(floor(npts-offset+1:npts)).*offset_ramp; 
signal=e.*signal;   
gated = signal;


