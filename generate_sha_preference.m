function y = generate_sha_preference(specs,tk,ha,opts)

%% pick a random speech file
folders.speech = opts.folders.speech;

ref = 1.1219e-006; %for josh's program

% read in speech filenames
filenames.speech = dir([folders.speech filesep '*.wav']);
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

%% read in speech, adjust to desired level
[y.target fs] = wavread([folders.speech filesep filenames.sp]);
y.target = change_spl(y.target,60 - calculate_spl(y.target,ref));
y.filenames = filenames;

% ramp signal
if opts.ramp > 0
    y.target = gate(y.target',opts.ramp,fs);
    y.target = y.target';
end

% set standard as target
y.standard = y.target;

%% randomize conditions

% randomize target and standard conditions
% 1 = sha, 2 = comp, 3 = dsl
random_order = randperm(2);
% if using sha vs comp - keep random_order as 1 & 2, if comp vs dsl at 1,
% if sha vs dsl change 2 to 3
switch opts.comparison(1); % make sure dsl = 3
    case 1
        switch opts.comparison(2)
            case 2 % do nothing
            case 3
                random_order(random_order == 2) = 3; 
        end
    case 2
        random_order = random_order+1;
end
        

%% amplify signals
% amplify target
switch random_order(1)
    case 1
        % amplify target as SHA
        spl_speech = calculate_spl(y.target,ref);
        [~, y.target] = ...
            sham(y.target,fs,spl_speech,0,ha.sha.idata);
        y.TargetLabel = 'sha'; % record standard for this trial
    case 2
        % amplify target as COMP
        spl_speech = calculate_spl(y.target,ref);
        [~, y.target] = ...
            sham(y.target,fs,spl_speech,1,ha.sha.idata);
        y.TargetLabel = 'comp'; % record standard for this trial
    case 3
        % amplify target as dsl
        y.target = amplify(y.target,ha,opts.ear);
        y.TargetLabel = 'dsl';
end

% amplify standard
switch random_order(2)
    case 1
        % amplify standard as SHA
        spl_speech = calculate_spl(y.standard,ref);
        [~, y.standard] = ...
            sham(y.standard,fs,spl_speech,0,ha.sha.idata);
        y.StandardLabel = 'sha';
    case 2
        % amplify standard as COMP
        spl_speech = calculate_spl(y.standard,ref);
        [~, y.standard] = ...
            sham(y.standard,fs,spl_speech,1,ha.sha.idata);
        y.StandardLabel = 'comp';
    case 3
        % amplify standard as dsl        
        y.standard = amplify(y.standard,ha,opts.ear);
        y.StandardLabel = 'dsl';
end

%remove wav file
movefile([folders.speech filesep filenames.sp],...
    [folders.speech filesep 'usedsentences' filesep filenames.sp]);

end