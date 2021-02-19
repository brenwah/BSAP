function [y myerror] = generate_speech(opts,ha,tk)

% the location of the speech and where you want the processed signal.

folders.speech = opts.folders.speech;
%folders.output = opts.folders.output;

ref = 1.1219e-006; %for josh's program

% read in speech filenames
filenames.speech = dir([folders.speech filesep '*.wav']);
filenames.speech = [filenames.speech; dir([folders.speech filesep '*.flac'])];

num_files = length(filenames.speech);
myerror = 0;
if num_files==0
    myerror = 1;
    h = msgbox('Out of Speech Files');
    return
end

%pick a random file
if opts.randomize == 1
    random_file = randperm(length(filenames.speech));
    random_file = random_file(1);
    filenames.sp = filenames.speech(random_file).name;
else
    filenames.sp = filenames.speech(1).name;
end

% read in speech, adjust to desired level
[y.speech fs] = audioread([folders.speech filesep filenames.sp]);
y.filenames = filenames;
if tk.start_snr ~= -999
    y.speech = change_spl(y.speech,tk.snr(tk.CurrentTrack) - calculate_spl(y.speech,ref));
end
    

% ramp signal
if opts.ramp > 0
    y.speech = gate(y.speech',opts.ramp,fs);
    y.speech = y.speech';
end

% Amplify stimuli, if needed
if strcmpi(ha.switch,'dsl')
    y.speech = amplify(y.speech,ha,opts.ear);
elseif strcmpi(ha.switch,'sha')
    spl_speech = calculate_spl(y.speech,ref);
    [~, y.speech] = ...
        sham(y.speech,fs,spl_speech,ha.sha.cm,ha.sha.idata);
else
end

y.noise_sp = y.speech; % to maintain consistency

%write to wav file
%wavwrite(y.noise_sp,fs,[folders.output filesep filenames.sp]);

%remove wav file
movefile([folders.speech filesep filenames.sp],...
    [folders.speech filesep 'usedsentences' filesep filenames.sp])

end