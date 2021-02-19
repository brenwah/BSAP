function answer = model_carney(stimuli,specs,tk)

CF    = 4000;   % CF in Hz;   
cohc  = 1.0;    % normal ohc function
cihc  = 1.0;    % normal ihc function
species = 3;    % 1 for cat (2 for human with Shera et al. tuning; 3 for human with Glasberg & Moore tuning)
noiseType = 1;  % 1 for variable fGn (0 for fixed fGn)
fiberType = 3;  % spontaneous rate (in spikes/s) of the fiber BEFORE refractory effects; "1" = Low; "2" = Medium; "3" = High
implnt = 0;     % "0" for approximate or "1" for actual implementation of the power-law functions in the Synapse
% stimulus parameters
T = length(stimuli.target(:,1))/specs.fs;
nrep = 1;               % number of stimulus repetitions (e.g., 50);
psthbinwidth = 0.5e-3; % binwidth in seconds;
Fs = 100e3;  % sampling rate in Hz (must be 100, 200 or 500 kHz)
ref = 0.00002; %reference pressure for Carney

target = resample(stimuli.target(:,1),Fs,specs.fs)';
target = change_spl(target,calculate_spl(stimuli.target(:,1)) - calculate_spl(target',ref)); % set to same SPL for dif references
vihc.target = model_IHC(target,CF,nrep,1/Fs,T*2,cohc,cihc,species); 
[meanrate.target,varrate.target,psth.target] = model_Synapse(vihc.target,CF,nrep,1/Fs,fiberType,noiseType,implnt); 

standard1 = resample(stimuli.standard1(:,1),Fs,specs.fs)';
standard1 = change_spl(standard1,calculate_spl(stimuli.standard1(:,1)) - calculate_spl(standard1',ref)); % set to same SPL for dif references
vihc.standard1 = model_IHC(standard1,CF,nrep,1/Fs,T*2,cohc,cihc,species); 
[meanrate.standard1,varrate.standard1,psth.standard1] = model_Synapse(vihc.standard1,CF,nrep,1/Fs,fiberType,noiseType,implnt); 
 
standard2 = resample(stimuli.standard2(:,1),Fs,specs.fs)';
standard2 = change_spl(standard2,calculate_spl(stimuli.standard2(:,1)) - calculate_spl(standard2',ref)); % set to same SPL for dif references
vihc.standard2 = model_IHC(standard2,CF,nrep,1/Fs,T*2,cohc,cihc,species); 
[meanrate.standard2,varrate.standard2,psth.standard2] = model_Synapse(vihc.standard2,CF,nrep,1/Fs,fiberType,noiseType,implnt); 

%compute mean of meanrate level over duration of target
intervals = {'target' 'standard1' 'standard2'};
levels = [mean(meanrate.(intervals{tk.target_interval(tk.trialID,1)})(30959:32042)) ...
    mean(meanrate.(intervals{tk.target_interval(tk.trialID,2)})(30959:32042)) ...
    mean(meanrate.(intervals{tk.target_interval(tk.trialID,3)})(30959:32042))];
[Y, answer]=max(levels);

% figure
timeout = (1:length(psth.target))*1/Fs;
figure(4);
% plot target
subplot(3,3,1)
plot(timeout,[target zeros(1,length(timeout)-length(target))])
title('Input Stimulus')

subplot(3,3,4)
plot(timeout,vihc.target(1:length(timeout)))
title('IHC output')

subplot(3,3,7)
plot(timeout,meanrate.target); 
xl = xlim;
title('Mean Rate Output')
xlabel('Time (s)')

%plot standard 1
subplot(3,3,2)
plot(timeout,[standard1 zeros(1,length(timeout)-length(standard1))])
title('Input Stimulus')

subplot(3,3,5)
plot(timeout,vihc.standard1(1:length(timeout)))
title('IHC output')

subplot(3,3,8)
plot(timeout,meanrate.standard1); 
xl = xlim;
title('Mean Rate Output')
xlabel('Time (s)')

%plot standard 2
subplot(3,3,3)
plot(timeout,[standard2 zeros(1,length(timeout)-length(standard2))])
title('Input Stimulus')

subplot(3,3,6)
plot(timeout,vihc.standard2(1:length(timeout)))
title('IHC output')

subplot(3,3,9)
plot(timeout,meanrate.standard2); 
xl = xlim;
title('Mean Rate Output')
xlabel('Time (s)')

end