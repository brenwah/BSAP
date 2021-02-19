function [target, standard1, standard2] = generate_tone(specs,opts,tk,ha)

if strcmpi(specs.signal_gen,'matlab')
    target = noise_gen(specs.signal_freq(1),specs.signal_freq(2),1,1,specs.signal_dur,specs.fs,specs.signal_ramp); target = target';
else
    % load masker and target
    file_names = dir([opts.folders.signal filesep '*.wav']);
    file_num = randperm(length(file_names));
    file_num = file_num(1);
    target = audioread([opts.folders.signal filesep file_names(file_num).name]);
end

if strcmpi(tk.signal_lv_calc,'peak')
    target_spl = calculate_spl(max(abs(target))*.707,specs.ref);
elseif strcmpi(tk.signal_lv_calc,'overall')
    target_spl = calculate_spl(target(find(target,1):end),specs.ref);
else
    msgbox('must enter tk.target_lv_calc');
end
target = change_spl(target,tk.signal_lv - target_spl);

% adjust SPL of target for NH, to account for headphone transfer
% function. Josh's program takes care of this for HI.
if strcmpi(ha.switch,'no')
    target = change_spl(target,specs.cal);
end

% add zeros to the beginning and ending of each stimuli
target = [zeros(1,round(.1*specs.fs))'; target; zeros(1,round(.1*specs.fs))'];

% standard will be zeros the size of target
standard = zeros(size(target));

standard1=standard;
standard2=standard;


