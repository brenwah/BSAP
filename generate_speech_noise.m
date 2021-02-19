function [y myerror] = generate_speech_noise(opts,tk,ha,specs)

% the location of the speech, noise, and where you want the combine signal
% at the specified SNR.

folders.speech = opts.folders.speech;
folders.noise = opts.folders.noise;

ref = 1.1219e-006; %for josh's program

% read in speech filenames
filenames.speech = dir([folders.speech filesep '*.wav']);
num_files = length(filenames.speech);

%error?
myerror = 0; % 1 is fatal, 2 is not fatal
if num_files == 0
    h = msgbox('Out of Speech Files');
    pause(h);
    myerror = 1;
    y = [];
    return
end



% read in noise filenames
filenames.noise = dir([folders.noise filesep '*.wav']);

%pick a random file
if opts.randomize == 1 %randomize
    random_file = randperm(length(filenames.speech));
    random_file = random_file(1);
    filenames.sp = filenames.speech(random_file).name;
else %do not randomize
    filenames.sp = filenames.speech(1).name;
end

% read in speech, adjust to desired SPL
[y.speech fs] = audioread([folders.speech filesep filenames.sp]);
y.speech = change_spl(y.speech,opts.speech_lv - calculate_spl(y.speech,ref));

% read in noise, adjust to get SNR
random_noise = randperm(length(filenames.noise));
random_noise = random_noise(1);
filenames.cur_noise = filenames.noise(random_noise).name;
y.noise = audioread([folders.noise filesep filenames.cur_noise]);
spl_adj = calculate_spl(y.speech,ref) - calculate_spl(y.noise,ref) - tk.snr(tk.CurrentTrack);
y.noise = change_spl(y.noise,spl_adj);

% gate noise, if needed
if opts.gate == 1
    y.noise = GateNoise(y.noise);
end

% combine speech plus noise
try
y.noise_sp = y.noise;
id_range = opts.SpeechStartID:opts.SpeechStartID+length(y.speech)-1;
y.noise_sp(id_range) = y.noise_sp(id_range) + y.speech;
y.filenames = filenames;

% chop noise to duration of signal
if ~isempty(opts.SpeechEndID) % leave original noise length if empty
    dur_combined = id_range(end) + opts.SpeechEndID;
    y.noise_sp = y.noise_sp(1:dur_combined);
end
% ramp signal
if opts.ramp > 0
    y.noise_sp = gate(y.noise_sp',opts.ramp,fs);
    y.noise_sp = y.noise_sp';
end

% Amplify stimuli, if needed
if strcmpi(ha.switch,'dsl')
    y.noise_sp = amplify(y.noise_sp,ha,opts.ear);
elseif strcmpi(ha.switch,'sha')
    spl_noise_sp = calculate_spl(y.noise_sp,specs.ref);
    [temp y.noise_sp] = ...
        sham(y.noise_sp,specs.fs,spl_noise_sp,ha.sha.cm,ha.sha.idata);
else
end

catch
   fig_h = msgbox(['unable to create stimulus for ' filenames.sp]);
   waitfor(fig_h);
   myerror = 2;
end

%remove wav file
movefile([folders.speech filesep filenames.sp],...
    [folders.speech filesep 'usedsentences' filesep filenames.sp])

% remove extra stuff that makes save files huge
y = rmfield(y,'noise');
y = rmfield(y,'speech');

% create gated noise
    function gated_noise = GateNoise(steady_noise)
        dur = 3.5; %seconds
        mr = 8; %8 hz
        ramp = .002;%seconds
        fs = 22050;
        sq_noise = noise_gen_squared(dur,mr,ramp,fs);
        
        % multiply the gated noise with the steady state noise
        gated_noise = steady_noise';
        startID = 2209;
        endID= 79376; % start/end of gating
        gated_noise(startID:endID) = gated_noise(startID:endID).*sq_noise;
        gated_noise = gated_noise';
    end


end