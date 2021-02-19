function [target, standard1, standard2] = generate_forward_masker(specs,opts,tk,ha)

%{
Jan 13th, 2016 - copied from generate_forward_masker. Updated to generate masker and standards separately.
Previously the masker was the same as standard 1 & 2.
%}
% load masker and target
file_names = dir([opts.folders.masker filesep '*.wav']);
file_num = randperm(length(file_names));
file_num = file_num(1);
masker = audioread([opts.folders.masker filesep file_names(file_num).name]);

file_num = randperm(length(file_names));
file_num = file_num(1);
standard1= audioread([opts.folders.masker filesep file_names(file_num).name]);

file_num = randperm(length(file_names));
file_num = file_num(1);
standard2= audioread([opts.folders.masker filesep file_names(file_num).name]);

file_names = dir([opts.folders.signal filesep '*.wav']);
file_num = randperm(length(file_names));
file_num = file_num(1);
target = audioread([opts.folders.signal filesep file_names(file_num).name]);

% compute masker and target levels
if strcmpi(specs.masker_lv_calc,'peak')
    masker_spl = calculate_spl(max(abs(masker))*.707,specs.ref,opts.masker_bw);
    standard1_spl= calculate_spl(max(abs(standard1))*.707,specs.ref,opts.masker_bw);
    standard2_spl= calculate_spl(max(abs(standard2))*.707,specs.ref,opts.masker_bw);
elseif strcmpi(specs.masker_lv_calc,'overall')
    masker_spl = calculate_spl(masker,specs.ref,opts.masker_bw);
    standard1_spl = calculate_spl(standard1,specs.ref,opts.masker_bw);
    standard2_spl = calculate_spl(standard2,specs.ref,opts.masker_bw);
else
    msgbox('must enter specs.masker_lv_calc');
end

if strcmpi(tk.signal_lv_calc,'peak')
    target_spl = calculate_spl(max(abs(target))*.707,specs.ref);
elseif strcmpi(tk.signal_lv_calc,'overall')
    target_spl = calculate_spl(target(find(target,1):end),specs.ref);
else
    msgbox('must enter tk.target_lv_calc');
end

%adjust masker and target levels
if strfind(opts.test,'adapt masker') 
    masker = change_spl(masker,tk.signal_lv - masker_spl);
    standard1= change_spl(standard1,tk.signal_lv - standard1_spl);
    standard2= change_spl(standard2,tk.signal_lv - standard2_spl);
    target = change_spl(target,specs.target_lv - target_spl);
else
    masker = change_spl(masker,specs.masker_lv - masker_spl);
    standard1= change_spl(standard1,specs.masker_lv - standard1_spl);
    standard2= change_spl(standard2,specs.masker_lv - standard2_spl);
    target = change_spl(target,tk.signal_lv - target_spl);
end

% adjust SPL of masker and target for NH, to account for headphone transfer
% function. Josh's program takes care of this for HI.


if strcmpi(ha.switch,'no')
    masker = change_spl(masker,specs.cal);
    standard1 = change_spl(standard1,specs.cal);
    standard2 = change_spl(standard2,specs.cal);
    target = change_spl(target,specs.cal);
end

% add zeros to masker, then add masker + target together
masker = [masker; zeros(length(target) - length(masker),1)];
target = masker+target;

% add zeros to standards, so that they are just as long as the target
standard1 = [standard1; zeros(length(target) - length(standard1),1)];;
standard2 = [standard2; zeros(length(target) - length(standard2),1)];;

% add zeros to the beginning and ending of each stimuli
target = [zeros(1,round(.1*specs.fs))'; target; zeros(1,round(.1*specs.fs))'];
standard1 = [zeros(1,round(.1*specs.fs))'; standard1; zeros(1,round(.1*specs.fs))'];
standard2 = [zeros(1,round(.1*specs.fs))'; standard2; zeros(1,round(.1*specs.fs))'];

% add mic noise, if desired
if isfield(specs,'micNoise')
    file_names = dir([specs.micNoise filesep '*.wav']);
    file_num = randperm(length(file_names));
    file_num = file_num(1);
    micNoise = audioread([specs.micNoise filesep file_names(file_num).name]);
    target = target+micNoise;
    standard1 = standard1+micNoise;
    standard2 = standard2+micNoise;
end

