function sq_noise = noise_gen_squared(dur,mr,ramp,fs);
%{
y = input noise
start_time = time delay before starting gating
dur = duration of gating
mr = gating rate
ramp = ramp duration (cosine squared)
fs = sampling rate
%}

%npts=length(y);
%x= 1:npts;
%sq_noise = ones(1,npts);
phase2 = 0;

%generate one gate
dur_cycle = 1/mr;
npts=round(fs*dur_cycle/2+ramp*fs);
x= 1:npts;
sq_noise = ones(1,npts);

% generate on cycle
if ramp ~=0
    onset_dur=ramp; offset_dur=ramp;
    onset=round(onset_dur*fs); offset=round(offset_dur*fs); %length in samples
    
    on_ramp=(sin(pi/2*x(1:onset)/x(onset))).^2;
    offset_ramp=fliplr(on_ramp);
    
    e=ones(size(x));
    e(1:onset)=e(1:onset).*on_ramp;
    e(floor(npts-offset+1:npts))=e(floor(npts-offset+1:npts)).*offset_ramp;
    
    sq_noise=e.*sq_noise;
end

% generate off cycle

%off_cycle = zeros(1,round(fs*dur_cycle/2-ramp*fs));
%sq_noise = [sq_noise off_cycle];
%sq_noise2=sq_noise;
off_cycle = zeros(1,round(fs*dur_cycle));
phaseID = dur_cycle/360*phase2;
phaseID = round(phaseID*fs+1);
off_cycle(phaseID:phaseID+length(sq_noise)-1) = sq_noise;
sq_noise = off_cycle;
sq_noise2=sq_noise;

num_iterations = round(dur/dur_cycle);
for i = 1:num_iterations-1
    sq_noise = [sq_noise sq_noise2];
end

