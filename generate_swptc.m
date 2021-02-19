function    target = generate_swptc(specs,tk,ha)        

%{
December 2018. Started coding. MB
%}

% generate masker and target
lf = tk.swptc_f(tk.trialID) - specs.masker_bw/2;
hf = tk.swptc_f(tk.trialID) + specs.masker_bw/2;
masker = noise_gen(lf,hf,10,1,specs.masker_dur,specs.fs,specs.masker_ramp);
target= noise_gen(specs.signal_freq(1),specs.signal_freq(2),10,1,specs.signal_dur,specs.fs,specs.signal_ramp);

% compute masker level
if isfield(specs,'masker_lv_calc') 
    tk.masker_lv_calc =specs.masker_lv_calc; 
end
if strcmpi(tk.masker_lv_calc,'peak')
    masker_spl = calculate_spl(max(abs(masker))*.707,specs.ref,specs.masker_bw);
elseif strcmpi(tk.masker_lv_calc,'rms')
    masker_spl = calculate_spl(masker,specs.ref);
else
    msgbox('must enter tk.masker_lv_calc');
end

%compute target level
if strcmpi(tk.signal_lv_calc,'peak')
    target_spl = calculate_spl(max(abs(target))*.707,specs.ref);
elseif strcmpi(tk.signal_lv_calc,'overall')
    target_spl = calculate_spl(target(find(target,1):end),specs.ref);
else
    msgbox('must enter tk.target_lv_calc');
end

masker = change_spl(masker,tk.snr - masker_spl);
if specs.target_lv == -99
    target = zeros(size(target));
else
    target = change_spl(target,specs.target_lv - target_spl);
end



% add zeros to target, then add masker + target together
masker(specs.signal_loc)=masker(specs.signal_loc)+target;
target=masker';
end
