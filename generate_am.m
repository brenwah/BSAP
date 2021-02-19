function [target standard1 standard2] = generate_am(specs,tk,ha)

% generate the target and standard
m = 10^(tk.signal_lv/20);
%m = 1/(10^(tk.signal_lv/20));
tk.signal_lv
[standard target]= noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),...
    specs.mod_rate,m,specs.carrier_dur,specs.fs,specs.carrier_ramp);
%target = noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),10,1,specs.carrier_dur,specs.fs,specs.carrier_ramp);
% WaveFile = randperm(50); WaveFile = WaveFile(1);
% standard = wavread([specs.FilePath 'SSN_56-8910_' int2str(WaveFile)]); 
% WaveFile = randperm(50); WaveFile = WaveFile(1);
% target = wavread([specs.FilePath 'SSN_56-8910_' int2str(WaveFile)]); 

% transpose the stimuli
% target = target';
% standard = standard';

% generate am

% npts = length(target);
% x= 1:npts;
% mod=(1+tk.m.*(cos((2*pi*specs.mod_rate/specs.fs)*x)));
% target=mod.*target;
% 
% % add ramps
% standard = gate(standard,.005,specs.fs);
% target = gate(target,.005,specs.fs);

% adjust SPL of the signals to the desired level
standard_spl = calculate_spl(standard,specs.ref);            
target_spl = calculate_spl(target,specs.ref);
standard = change_spl(standard,specs.carrier_lv - standard_spl);
target = change_spl(target,specs.carrier_lv - target_spl);

% add zeros to the beginning and ending of each stimuli
target = ...
    [zeros(1,round(.1*specs.fs)) target zeros(1,round(.1*specs.fs))];
standard = ...
    [zeros(1,round(.1*specs.fs)) standard zeros(1,round(.1*specs.fs))];

% transpose the stimuli
target = target';
standard1 = standard';
standard2 = standard1;