function save_results(results,specs,opts,tk,ha,reward)

warning('off','MATLAB:xlswrite:AddSheet');
warning('off','MATLAB:structOnObject'); %otherwise we get warnings that we can ignore.
warning('off','MATLAB:audiovideo:audiowrite:dataClipped');

results.specs = specs;
results.opts = opts;
results.tk = struct(tk);
results.ha = ha;
results.reward = struct(reward);

if strcmpi(opts.test,'swptc')
    results.tk.data.track1.masker_f = results.tk.swptc_f';
end

% delete file if necessary (so that it doesn't leave in previous data),
% then write to excel file
temp_xls_file = [opts.folders.data opts.DataFileName '.xlsx'];
if exist(temp_xls_file,'file')==2; delete(temp_xls_file); end
writetable(results.tk.data.track1,temp_xls_file,'Sheet','track1');
writetable(results.tk.data.track2,temp_xls_file,'Sheet','track2');

if ~isfield(opts,'SoundFileFormat')
    opts.SoundFileFormat = '.wav';
end

if ~isfield(opts,'BitsPerSample')
    if strcmpi(opts.SoundFileFormat, '.wav')
        opts.BitsPerSample = 32;
    elseif strcmpi(opts.SoundFileFormat, '.flac')
        opts.BitsPerSample = 24;
    end
end

if strcmpi(opts.SaveSoundFiles,'yes')
    if strcmpi(opts.test,'speech_in_noise')
        results = save_soundfiles_speech(results);
    elseif strcmpi(opts.test,'speech_in_quiet')
        results = save_soundfiles_speech_in_quiet(results);
    else
        results = save_soundfiles_everything_else(results);
    end
elseif strcmpi(opts.SaveSoundFiles,'no')
    results = rmfield(results,'stimuli');
end

save ([opts.folders.data opts.DataFileName '.mat'],'results');

    function results = save_soundfiles_speech_in_quiet(results)
        okToDelete = 1;
        for i = length(results.stimuli):-1:1
            try
                filename = results.stimuli{1,i}.filenames.sp;
                
                % remove & add extension
                filename = filename(1:end-4);
                filename = [filename opts.SoundFileFormat];
                
                %write audio
                audiowrite([opts.folders.data filename],...
                    results.stimuli{1,i}.noise_sp,specs.fs,'Title',filename,...
                    'BitsPerSample',opts.BitsPerSample); % commented out track info: opts.DataFileName ...' Track 1' ' Trial ' int2str(i) ' '
                
                if tk.NumTracks == 2
                    filename = length(results.stimuli{2,i}.filenames.sp);
                    filename = results.stimuli{2,i}.filenames.sp;
                    
                    % remove & add extension
                    filename = filename(1:end-4);
                    filename = [filename opts.SoundFileFormat];
                    
                    audiowrite([opts.folders.data filename],...
                        results.stimuli{1,i}.noise_sp,specs.fs,'Title',filename,...
                        'BitsPerSample',opts.BitsPerSample);
                end
            catch
                okToDelete = 0;
                display(['unable to save: ' filename]);
            end
        end
        if okToDelete == 1
            results = rmfield(results,'stimuli');
        else
            display('unable to save all sound files');
        end
    end

    function results = save_soundfiles_speech(results)
        okToDelete = 1;
        for i = length(results.stimuli):-1:1
            try
                filename = 'please ignore this error';
                filename = length(results.stimuli{1,i}.filenames.sp);
                filename = [results.stimuli{1,i}.filenames.sp(1:filename-4) ' ' ...
                    results.stimuli{1,i}.filenames.cur_noise];
                
                % remove & add extension
                filename = filename(1:end-4);
                filename = [filename opts.SoundFileFormat];
                
                %write audio
                audiowrite([opts.folders.data opts.DataFileName ...
                    ' Track 1' ' Trial ' int2str(i) ' ' filename],...
                    results.stimuli{1,i}.noise_sp,specs.fs,'Title',filename,...
                    'BitsPerSample',opts.BitsPerSample);
                
                if tk.NumTracks == 2
                    filename = 'please ignore this error';
                    filename = length(results.stimuli{2,i}.filenames.sp);
                    filename = [results.stimuli{2,i}.filenames.sp(1:filename-4) ' ' ...
                        results.stimuli{2,i}.filenames.cur_noise];
                    
                    % remove & add extension
                    filename = filename(1:end-4);
                    filename = [filename opts.SoundFileFormat];
                    
                    audiowrite([opts.folders.data opts.DataFileName ...
                        ' Track 2' ' Trial ' int2str(i) ' ' filename],...
                        results.stimuli{1,i}.noise_sp,specs.fs,'Title',filename,...
                        'BitsPerSample',opts.BitsPerSample);
                end
            catch
                okToDelete = 0;
                display(['unable to save: ' filename]);
            end
        end
        if okToDelete == 1
            results = rmfield(results,'stimuli');
        else
            display('unable to save all sound files');
        end
    end

    function results = save_soundfiles_everything_else(results)
        okToDelete = 1;
        temp_folder_path = [opts.folders.data opts.DataFileName filesep];
        if ~isdir(temp_folder_path)
            mkdir(temp_folder_path);
        end
        for trackID = 1:tk.NumTracks
            for i = size(results.stimuli,1):-1:1
                try
                    for fieldID = {'target' 'standard1' 'standard2'}
                        if isfield(results.stimuli{i,trackID},fieldID{1})
                            filename = ['Track ' int2str(trackID) ' Trial ' int2str(i) ' ' fieldID{1}];
                            y = results.stimuli{i,trackID}.(fieldID{1});
                            if specs.atten ~=0 % put it back to reference SPL
                                y(:,1) = change_spl(y(:,1),-specs.atten);
                                y(:,2) = change_spl(y(:,2),-specs.atten);
                            end
                            if max(max(abs(y))) > 1
                                display(['saved as .mat to prevent clipping: ' filename]);
                                save([temp_folder_path filename '.mat'],'y');
                            else
                                audiowrite([temp_folder_path filename opts.SoundFileFormat],...
                                    y,specs.fs,'Title',filename, 'BitsPerSample',opts.BitsPerSample);
                            end

                        end
                    end
                    if isfield(results.stimuli,'target_OutputLimit')
                        results.target_OutputLimit{i,trackID} = results.stimuli{i,trackID}.target_OutputLimit;
                        results.standard_OutputLimit{i,trackID} = results.stimuli{i,trackID}.standard_OutputLimit;
                    end

                catch
                    okToDelete = 0;
                    display(['unable to save: ' filename]);
                end
            end
        end
        if okToDelete == 1
            results = rmfield(results,'stimuli');
        else
            display('unable to save all sound files');
        end
    end
end
