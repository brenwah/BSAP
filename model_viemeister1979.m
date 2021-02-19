function answer = model_viemeister1979(stimuli,specs,tk,opts)

temp_track = ['track' int2str(tk.CurrentTrack)]; %to use the correct track to record data
temp_trialID = tk.trialID(tk.CurrentTrack);

% 4-6 kHz four-pole Butterworth Bandpass (missing)

% first-order lowpass filter @ 65 Hz
[b,a] = folp(65,specs.fs);

switch opts.ear
    case 'left'
        colID = 1
        
    case 'right'
        colID = 2
end

% halfwave rectification
target = max(stimuli.target(:,colID),0);
standard1 = max(stimuli.standard1(:,colID),0);

% first-order lowpass filter @ 65 Hz
target = filter(b, a, target);
standard1 = filter(b, a, standard1);

% ac-coupled rms = std
out(1) = std(target,1);
out(2) = std(standard1,1);

if opts.num_intervals == 3;
    standard2 = max(stimuli.standard2(:,colID),0);
    standard2 = filter(b, a, standard2);
    out(3) = std(standard2,1);
end
        
% now select the interval with the maximum standard deviation
[~, answer] = max(out); % select stimuli with max power, where %1 = target, 2 = standard1, 3 = standard2
answer = find(tk.data.(temp_track).target_interval(temp_trialID,:)==answer);
end