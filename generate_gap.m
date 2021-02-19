function [target, standard1, standard2] = generate_gap(specs,tk,ha,adaptON)

if strcmpi(adaptON,'gap duration')
    
    % generate the target and standard
    standard1 = noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),10,1,specs.carrier_dur,specs.fs,specs.carrier_ramp);
    standard2 = noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),10,1,specs.carrier_dur,specs.fs,specs.carrier_ramp);
    target = noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),10,1,specs.carrier_dur,specs.fs,specs.carrier_ramp);
    
    
    % adjust SPL of the signals to the desired level
    standard1_spl = calculate_spl(standard1,specs.ref);
    standard2_spl = calculate_spl(standard2,specs.ref);
    target_spl = calculate_spl(target,specs.ref);
    standard1 = change_spl(standard1,specs.carrier_lv - standard1_spl);
    standard2 = change_spl(standard2,specs.carrier_lv - standard2_spl);
    target = change_spl(target,specs.carrier_lv - target_spl);
    
    % generate gap
    target = gap_gen(target,tk.snr(tk.CurrentTrack),specs.gap_ramp,specs.fs);
    
else % adapt on carrier level

    % generate the target and standard
    standard1 = noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),10,1,specs.carrier_dur,specs.fs,specs.carrier_ramp);
    standard2 = noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),10,1,specs.carrier_dur,specs.fs,specs.carrier_ramp);
    target = noise_gen(specs.carrier_freq(1),specs.carrier_freq(2),10,1,specs.carrier_dur,specs.fs,specs.carrier_ramp);
    
    % adjust SPL of the signals to the desired level
    standard1_spl = calculate_spl(standard1,specs.ref);
    standard2_spl = calculate_spl(standard2,specs.ref);
    target_spl = calculate_spl(target,specs.ref);
    standard1 = change_spl(standard1,tk.snr(tk.CurrentTrack) - standard1_spl);
    standard2 = change_spl(standard2,tk.snr(tk.CurrentTrack) - standard2_spl);
    target = change_spl(target,tk.snr(tk.CurrentTrack) - target_spl);
    
    % generate gap
    target = gap_gen(target,specs.carrier_lv,specs.gap_ramp,specs.fs);
    
end

% add zeros to the beginning and ending of each stimuli
target = [zeros(1,round(.1*specs.fs)) target zeros(1,round(.1*specs.fs))];
standard1 = [zeros(1,round(.1*specs.fs)) standard1 zeros(1,round(.1*specs.fs))];
standard2 = [zeros(1,round(.1*specs.fs)) standard2 zeros(1,round(.1*specs.fs))];

% transpose the stimuli
target = target';
standard1 = standard1';
standard2 = standard2';