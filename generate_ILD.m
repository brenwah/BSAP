function [target, standard1, standard2] = generate_ILD(specs,opts,tk,ha)

%{
June 26, 2018 - copied from generate_forward_masker.
July 9, 2018 - MB - to maintain phase, standards now derived from target
(whereas before each (target, standard1, standard2) were generated
independently)
%}
% create target and standards
[target]= noise_gen(specs.target_f(1),specs.target_f(2),1,1,specs.target_dur,specs.fs,specs.target_ramp);
standard1=target;standard2=target;

% compute levels, consider using specs.masker_lv_calc in future, if needed
% compute masker and target levels
if strcmpi(tk.signal_lv_calc,'peak') % doesn't account for BW, if this is narrowband noise.
    target_spl = calculate_spl(max(abs(target))*.707,specs.ref);
    standard1_spl = calculate_spl(max(abs(standard1))*.707,specs.ref);
    standard2_spl = calculate_spl(max(abs(standard2))*.707,specs.ref);
elseif strcmpi(tk.signal_lv_calc,'overall')
    target_spl = calculate_spl(target(find(target,1):end),specs.ref); % use of find removes any leading zeros
    standard1_spl = calculate_spl(target(find(standard1,1):end),specs.ref); 
    standard2_spl = calculate_spl(target(find(standard2,1):end),specs.ref); 
else
    msgbox('must enter tk.target_lv_calc');
end

%adjust standard and target levels, reshape to columns for soundcard
target = change_spl(target,specs.target_lv - target_spl)';
standard1= change_spl(standard1,specs.standard_lv - standard1_spl)';
standard2= change_spl(standard2,specs.standard_lv - standard2_spl)';

% adjust SPL of masker and target for NH, to account for headphone transfer
% function. Josh's program takes care of this for HI.
if strcmpi(ha.switch,'no')
    target = change_spl(target,specs.cal);
    standard1 = change_spl(standard1,specs.cal);
    standard2 = change_spl(standard2,specs.cal);
end

% column one is left ear. Column 2 is right ear.
%adjust baseline ILD
standard1(:,2)=standard1(:,1); standard2(:,2)=standard1(:,1); target(:,2)=target(:,1);
if isfield(specs,'ILD_base')
    standard1(:,1) = change_spl(standard1(:,1),specs.ILD_base);
    standard2(:,1) = change_spl(standard2(:,1),specs.ILD_base);
    target(:,1) = change_spl(target(:,1),specs.ILD_base);
end

%adjust target, accounting for ILD split--if necessary
if strcmpi(specs.ILD_split,'yes')
    if tk.snr==0; lv_change=0; else; lv_change = tk.snr/2; end
    target(:,1)=change_spl(target(:,1),-lv_change);
    target(:,2)=change_spl(target(:,2),lv_change);
else
    target(:,2)=change_spl(target(:,2),tk.snr);
end

%rove
if length(specs.rove) > 1 
    temp = randperm(length(specs.rove)); temp = temp(1:3);
    rove = specs.rove(temp(1:3));
    target(:,1) = change_spl(target(:,1),rove(1));target(:,2) = change_spl(target(:,2),rove(1));
    standard1(:,1) = change_spl(standard1(:,1),rove(2));standard1(:,2) = change_spl(standard1(:,2),rove(2));
    standard2(:,1) = change_spl(standard2(:,1),rove(3));standard2(:,2) = change_spl(standard2(:,2),rove(3));
end

%
% display(['SNR: ' num2str(tk.snr,'%.1f')]);
% display(['Target L:' num2str(calculate_spl(max(abs(target(:,1)))*.707,specs.ref))]);
% display(['Target R:' num2str(calculate_spl(max(abs(target(:,2)))*.707,specs.ref))]);
% display(['Standard1 L:' num2str(calculate_spl(max(abs(standard1(:,1)))*.707,specs.ref))]);
% display(['Standard1 R:' num2str(calculate_spl(max(abs(standard1(:,2)))*.707,specs.ref))]);


% add zeros to the beginning and ending of each stimuli
target = [zeros(round(.1*specs.fs),2); target; zeros(round(.1*specs.fs),2)];
standard1 = [zeros(round(.1*specs.fs),2); standard1; zeros(round(.1*specs.fs),2)];
standard2 = [zeros(round(.1*specs.fs),2); standard2; zeros(round(.1*specs.fs),2)];

