function [results, specs,tk,ha,reward,opts, fig_tracker,ProgError] = gui_forward_masking(specs,tk,ha,reward,opts,ProgError)

%{
returns the reversal points for forward masking task.
specs is structure (see scratch.m)
%}

%{
updates
    
%}

% define a few variables
QuitProg = 0;
if isempty(tk.snr)
    warndlg('you must specify tk.snr');
    return
end
tk.signal_lv = tk.snr(tk.CurrentTrack);


% set defaults
if ~isfield(opts,'instructions')
    opts.instructions = 'Select The Number That Sounded Different';
end
if ~isfield(opts,'num_intervals')
    opts.num_intervals = 3;
end
if ~isfield(opts, 'ProvideFeedback')
    opts.ProvideFeedback = 'yes';
end
response_temp = 0;%used for key presses prior to end of presentation.
if isfield(specs,'target_lv'); specs.target_lv_temp = specs.target_lv; end % used for catch trials
tk.data.track1.catch_trial(1) = 0;  % record initial trial as not a catch trial
if tk.NumTracks == 2; tk.data.track2.catch_trial(1) = 0; end % record initial trial as not a catch trial



%% create the figure
%[fig_gap handles] = figure_interval(opts.displayGUI,1);
if opts.displayGUI == 0
    fig_gap = figure('MenuBar','None','Units','Normalized','Position',[0 0 1 1],...
        'Visible','off');
    
else
    
    fig_gap = figure('MenuBar','None','Units','Normalized','DeleteFcn',@delete_fig);
    pause(.25); fig_gap.Position = opts.position;
    
    % create GUI Objects
    uicontrol(fig_gap,'Style','Text','Tag','text1','Units','Normalized',...
        'Position',[.1 .7 .8 .2],'FontSize',24,...
        'String',opts.instructions)
    
    uicontrol(fig_gap,'Style','PushButton','Tag','pushbutton1','Units','Normalized',...
        'Position',[.1 .3 .2 .2],'FontSize',24,...
        'String',opts.text1,'CallBack',@interval1)
    
    uicontrol(fig_gap,'Style','PushButton','Tag','pushbutton2','Units','Normalized',...
        'Position',[.4 .3 .2 .2],'FontSize',24,...
        'String',opts.text2,'CallBack',@interval2)
    
    uicontrol(fig_gap,'Style','PushButton','Tag','pushbutton3','Units','Normalized',...
        'Position',[.7 .3 .2 .2],'FontSize',24,...
        'String',opts.text3,'CallBack',@interval3)
    
    set(gcf, 'WindowKeyPressFcn', @key_press);
    
    handles = guihandles(fig_gap);
    
    % prevent subject from pressing a button
    set(handles.pushbutton1,'Enable','Off')
    set(handles.pushbutton2,'Enable','Off')
    set(handles.pushbutton3,'Enable','Off')
    
    % hide intervals if necessary
    if opts.num_intervals_displayed <3; set(handles.pushbutton3,'Visible','Off');end
    if opts.num_intervals_displayed <2; set(handles.pushbutton2,'Visible','Off');end
    if opts.num_intervals_displayed <1; set(handles.pushbutton1,'Visible','Off');end
    
    % create figure for displaying tracker
    fig_tracker.fig = figure('MenuBar','None','Units','Inches','Position',[0 6 9 6]);
    fig_tracker.axis1 = axes('Units','Inches','Position',[.5 .5 5 5]); hold all; grid on;
    title({[opts.SetupFile.path opts.SetupFile.name]; 'Track 1'},'interpreter','none');
    ylim([tk.min_snr tk.max_snr]); xlim([0 tk.max_trials(1)]);
    if strcmpi(opts.test,'swptc'); xlim([tk.swptc_f(1) tk.swptc_f(end)]); end
    
    if tk.NumTracks == 2 % display a 2nd track if two tracks
        fig_tracker.fig.Position = [0 0 8 12]; fig_tracker.axis1.Position = [.5 6.5 5 5];
        fig_tracker.axis2 = axes('Units','Inches','Position',[.5 .5 5 5]); hold all; grid on;
        ylim([tk.min_snr tk.max_snr]); xlim([0 tk.max_trials(2)]);
        if strcmpi(opts.test,'swptc'); xlim([tk.swptc_f(1) tk.swptc_f(end)]); end
        title('Track 2');
    end
    
    fig_tracker.uiQuit = uicontrol('Style','PushButton','Units','Inches','Tag','quit',...
        'Position',[5.8 1 2 1],'FontSize',16,'String','Quit','Callback',@quit_prog);
    fig_tracker.uiPause = uicontrol('Style','PushButton','Units','Inches','Tag','pause',...
        'Position',[5.8 3 2 1],'FontSize',16,'String','Pause','Callback',@quit_prog);
    
    figure(fig_gap);
    
end

%% start the threshold search
if ProgError.status == 0
    present
    waitfor(fig_gap)
end
%% interval and keypress functions

    function key_press(varargin)
        if tk.keypress_ok == 1
            switch varargin{2}.Key
                case '1'
                    interval1
                case '2'
                    interval2
                case '3'
                    interval3
            end
        else
            response_temp = varargin{2}.Key;
        end
    end

    function interval1(varargin)
        tk.data.(['track' int2str(tk.CurrentTrack)]).response(tk.trialID(tk.CurrentTrack),1) = 1;
        feedback
    end

    function interval2(varargin)
        tk.data.(['track' int2str(tk.CurrentTrack)]).response(tk.trialID(tk.CurrentTrack),1) = 2;
        feedback;
    end

    function interval3(varargin)
        tk.data.(['track' int2str(tk.CurrentTrack)]).response(tk.trialID(tk.CurrentTrack),1) = 3;
        feedback;
    end

%% feedback function
    function feedback
        try
            temp_track = ['track' int2str(tk.CurrentTrack)]; %to use the correct track to record data
            temp_trialID = tk.trialID(tk.CurrentTrack);
            
            if opts.displayGUI == 1
                % prevent subject from pressing a button
                tk.keypress_ok = 0;
                set(handles.pushbutton1,'Enable','Off');
                set(handles.pushbutton2,'Enable','Off');
                set(handles.pushbutton3,'Enable','Off');
            end
            
            %         if opts.num_intervals == 1
            %             if tk.response(tk.trialID,1)==2
            %                 plt_color = '*g';
            %             elseif tk.response(tk.trialID,1)==3
            %                 plt_color ='*r';
            %             end
            %             tk.correct(tk.CurrentTrack) = tk.response(tk.trialID,1);
            %         else
            
            if tk.data.(temp_track).target_interval(temp_trialID,tk.data.(temp_track).response(temp_trialID,1)) == 1
                % do this if they correctly identifed the signal
                
                if opts.displayGUI == 1
                    
                    if ~strcmpi(opts.ProvideFeedback,'no')
                        % give visual feedback
                        temp2 = find(tk.data.(temp_track).target_interval(temp_trialID,:) == 1);
                        temp2 = sprintf('handles.pushbutton%1.0f',temp2);
                        set(eval(temp2),'BackgroundColor','g'); % change background color to green
                        pause (opts.pause_internal_interval); % pause x seconds
                        set(eval(temp2),'BackgroundColor',tk.white); % change background color to white
                    end
                    plt_color = '+g';
                    
                end
                
                if tk.data.(temp_track).catch_trial(temp_trialID) == 0
                    tk.correct(tk.CurrentTrack) = tk.correct(tk.CurrentTrack) +1;
                    tk.incorrect(tk.CurrentTrack) = 0;
                else
                    tk.catch_correct = 1;
                end
                
            else
                
                if opts.displayGUI == 1
                    
                    if ~strcmpi(opts.ProvideFeedback,'no')
                        % give visual feedback
                        temp2 = find(tk.data.(temp_track).target_interval(temp_trialID,:) == 1);
                        temp2 = sprintf('handles.pushbutton%1.0f',temp2);
                        set(eval(temp2),'BackgroundColor','r'); % change background color to red
                        pause (opts.pause_internal_interval); % pause x seconds
                        set(eval(temp2),'BackgroundColor',tk.white); % change background color to white
                    end
                    plt_color = '+r';
                    
                end
                
                if tk.data.(temp_track).catch_trial(temp_trialID) == 0
                    tk.correct(tk.CurrentTrack) = 0;
                    tk.incorrect(tk.CurrentTrack) = tk.incorrect(tk.CurrentTrack)+1;
                else
                    tk.catch_correct = 0;
                end
                
            end
            %end
            
            if opts.displayGUI == 1
                
                if strcmpi(opts.test,'swptc')
                    if tk.data.(temp_track).catch_trial(temp_trialID) == 1 %is a catch trial
                        plt_color(1) = '^';
                        plot(fig_tracker.(['axis' int2str(tk.CurrentTrack)]), tk.swptc_f(tk.trialID(tk.CurrentTrack)),tk.min_snr,plt_color);
                    else
                        plot(fig_tracker.(['axis' int2str(tk.CurrentTrack)]), tk.swptc_f(tk.trialID(tk.CurrentTrack)),tk.snr(tk.CurrentTrack),plt_color);
                    end
                else
                    plot(fig_tracker.(['axis' int2str(tk.CurrentTrack)]), tk.trialID(tk.CurrentTrack),tk.snr(tk.CurrentTrack),plt_color);
                end
            end
            
            
            if strcmpi(tk.method,'adaptive')
                tk = track_speech(tk,opts.test);
            elseif strcmpi(tk.method,'constant')
                tk = track_constant(tk,opts.test);
            end
            
            % determine if catch trial
            temp_trialID = tk.trialID(tk.CurrentTrack); %update trialID
            if tk.catch_probability > 0 && temp_trialID <= tk.max_trials
                if tk.data.(temp_track).catch_trial(temp_trialID) == 1
                    specs.target_lv_temp = specs.target_lv;
                    specs.target_lv = tk.catch_snr;
                else % not a catch trial
                    specs.target_lv = specs.target_lv_temp;
                end
            end
            
            % assign variables for output
            results.reversals = tk.reversals;
            results.trialData = tk.trialData;
            results.correctData = tk.correctData;
            results.stimuli = tk.stimuli;
            
            % wait a bit and then display reward
            if reward.display == 1
                reward = DisplayPicture(reward);
                pause(reward.duration);
            end
            
            % do we continue or quit?
            if tk.reversalID(1) > tk.max_reversals
                tk.finished(1) = 1;
            end
            
            
            % do we continue or quit?
            if min(tk.finished) == 1
                QuitProg = 2;
            end
            
            if QuitProg == 2
                end_data_collection;
            else
                if QuitProg == 1
                    h = msgbox('Press Ok when Ready');
                    uiwait(h);
                    QuitProg = 0;
                end
                present;
            end
        catch ME
            warndlg('Encountered an error. Will try to save the data.')
            end_data_collection;
            rethrow(ME);
        end
        
    end
%% present function
    function present(varargin)
        
        try
            
            % generate target and standard stimuli
            if strcmpi(opts.test,'threshold')
                [stimuli.target, stimuli.standard1, stimuli.standard2] = generate_tone(specs,opts,tk,ha);
            elseif strcmpi(opts.test,'audiometer_tone')
                [stimuli.target, stimuli.standard1] = generate_audiometer_tone(specs,tk,ha);
            elseif strncmpi(opts.test,'forward masking',14)
                [stimuli.target, stimuli.standard1, stimuli.standard2] = generate_forward_masker(specs,opts,tk,ha);
            elseif strcmpi(opts.test,'gap detection')
                [stimuli.target, stimuli.standard1, stimuli.standard2] = generate_gap(specs,tk,ha,'gap duration');
            elseif strcmpi(opts.test,'gap detection adapt noise level')
                [stimuli.target, stimuli.standard1, stimuli.standard2] = generate_gap(specs,tk,ha,'carrier level');
            elseif strcmpi(opts.test,'ILD')
                [stimuli.target, stimuli.standard1, stimuli.standard2] = generate_ILD(specs,opts,tk,ha);
            elseif strcmpi(opts.test,'am detection')
                [stimuli.target, stimuli.standard1, stimuli.standard2] = generate_am(specs,tk,ha);
            elseif strcmpi(opts.test,'swptc')
                [stimuli.target] = generate_swptc(specs,tk,ha);
            elseif strcmpi(opts.test,'sha preference')
                temp = generate_sha_preference(specs,tk,ha,opts);
                stimuli.target = temp.target;
                stimuli.standard1 = temp.standard;
                stimuli.TargetLabel = temp.TargetLabel;
                stimuli.StandardLabel = temp.StandardLabel;
            elseif strcmpi(opts.test,'spectralripple')
                phaseshift = rand*pi/2;
                stimuli.target = myLogFreqNoise(specs.freq(1),specs.freq(2),specs.rpo,tk.snr,phaseshift,specs);
                stimuli.target = resample(stimuli.target,specs.fs,44100);
                stimuli.target = gate(stimuli.target',specs.ramp,specs.fs)';
                stimuli.target = change_spl(stimuli.target,specs.masker_lv-calculate_spl(stimuli.target,specs.ref));
                if specs.randomlv > 0
                    randomlv2 = randomlv(randperm(13,1));
                    stimuli.target = change_spl(stimuli.target,randomlv2);
                end
                
                stimuli.standard1 = myLogFreqNoise(specs.freq(1),specs.freq(2),specs.rpo,0,phaseshift,specs);
                stimuli.standard1 = resample(stimuli.standard1,specs.fs,44100);
                stimuli.standard1 = gate(stimuli.standard1',specs.ramp,specs.fs)';
                stimuli.standard1 = change_spl(stimuli.standard1,specs.masker_lv-calculate_spl(stimuli.standard1,specs.ref));
                if specs.randomlv > 0
                    randomlv2 = randomlv(randperm(13,1));
                    stimuli.standard1 = change_spl(stimuli.standard1,randomlv2);
                end
                
                
                stimuli.standard2 = myLogFreqNoise(specs.freq(1),specs.freq(2),specs.rpo,0,phaseshift,specs);
                stimuli.standard2 = resample(stimuli.standard2,specs.fs,44100);
                stimuli.standard2 = gate(stimuli.standard2',specs.ramp,specs.fs)';
                stimuli.standard2 = change_spl(stimuli.standard2,specs.masker_lv-calculate_spl(stimuli.standard2,specs.ref));
                if specs.randomlv > 0
                    randomlv2 = randomlv(randperm(13,1));
                    stimuli.standard2 = change_spl(stimuli.standard2,randomlv2);
                end
                
            elseif strcmpi(opts.test,'spectralripplediscrimination')
                phaseshift = rand*pi/2;
                stimuli.target = myLogFreqNoise(specs.freq(1),specs.freq(2),tk.snr,specs.depth,phaseshift,specs);
                stimuli.target = resample(stimuli.target,specs.fs,44100);
                stimuli.target = gate(stimuli.target',specs.ramp,specs.fs)';
                stimuli.target = change_spl(stimuli.target,specs.masker_lv-calculate_spl(stimuli.target,specs.ref));
                if specs.randomlv > 0
                    randomlv2 = randomlv(randperm(13,1));
                    stimuli.target = change_spl(stimuli.target,randomlv2);
                end
                
                stimuli.standard1 = myLogFreqNoise(specs.freq(1),specs.freq(2),tk.snr,specs.depth,phaseshift+pi/2,specs);
                stimuli.standard1 = resample(stimuli.standard1,specs.fs,44100);
                stimuli.standard1 = gate(stimuli.standard1',specs.ramp,specs.fs)';
                stimuli.standard1 = change_spl(stimuli.standard1,specs.masker_lv-calculate_spl(stimuli.standard1,specs.ref));
                if specs.randomlv > 0
                    randomlv2 = randomlv(randperm(13,1));
                    stimuli.standard1 = change_spl(stimuli.standard1,randomlv2);
                end
                
                
                stimuli.standard2 = myLogFreqNoise(specs.freq(1),specs.freq(2),tk.snr,specs.depth,phaseshift+pi/2,specs);
                stimuli.standard2 = resample(stimuli.standard2,specs.fs,44100);
                stimuli.standard2 = gate(stimuli.standard2',specs.ramp,specs.fs)';
                stimuli.standard2 = change_spl(stimuli.standard2,specs.masker_lv-calculate_spl(stimuli.standard2,specs.ref));
                if specs.randomlv > 0
                    randomlv2 = randomlv(randperm(13,1));
                    stimuli.standard2 = change_spl(stimuli.standard2,randomlv2);
                end
                
            elseif strcmpi(opts.test,'PsyAcoustX')
                specs.PsyAcoustX.stimParams.targetLevel = tk.snr;
                %specs.PsyAcoustX.stimParams.hpMaskerLevel = tk.snr-specs.PsyAcoustX.stimParams.hpMaskerLevelDifference;
                %specs.PsyAcoustX.stimParams.lpMaskerLevel = tk.snr-specs.PsyAcoustX.stimParams.lpMaskerLevelDifference;
                [PsyAcoustX, stimuli.target, stimuli.standard1 stimuli.standard2] = makeStim(specs.PsyAcoustX);
            end
            
            % Amplify stimuli, if needed
            if ~strcmpi(opts.test,'sha preference')
                if strcmpi(ha.switch,'yes')|| strcmpi(ha.switch,'dsl')
                    if isfield(stimuli,'target'); stimuli.target = amplify(stimuli.target,ha,opts.ear); end
                    if isfield(stimuli,'standard1'); stimuli.standard1 = amplify(stimuli.standard1,ha,opts.ear); end
                    if isfield(stimuli,'standard2'); stimuli.standard2 = amplify(stimuli.standard2,ha,opts.ear); end
                    if strcmpi(opts.test,'threshold')
                        stimuli.standard1 = zeros(size(stimuli.target)); %otherwise we get clicks
                        stimuli.standard2 = zeros(size(stimuli.target)); %otherwise we get clicks
                    end
                elseif strcmpi(ha.switch,'enr')
                    stimuli.target = WDH_DSP_main(stimuli.target');
                    stimuli.standard1 = WDH_DSP_main(stimuli.standard1');
                    stimuli.target = stimuli.target';
                    stimuli.standard1 = stimuli.standard1';
                    if strcmpi(opts.test,'threshold')
                        stimuli.standard1 = zeros(size(stimuli.target)); %otherwise we get clicks
                    end
                elseif strcmpi(ha.switch,'sha')
                    spl_target = calculate_spl(stimuli.target,specs.ref);
                    [~, stimuli.target] = sham(stimuli.target,specs.fs,spl_target,0,ha.sha.idata);
                    spl_standard1 = calculate_spl(stimuli.standard1,specs.ref);
                    [~, stimuli.standard1] = sham(stimuli.standard1,specs.fs,spl_target,0,ha.sha.idata);
                elseif strcmpi(ha.switch,'cha')
                    spl_target = calculate_spl(stimuli.target,specs.ref);
                    [~, stimuli.target] = sham(stimuli.target,specs.fs,spl_target,1,ha.sha.idata);
                    spl_standard1 = calculate_spl(stimuli.standard1,specs.ref);
                    [~, stimuli.standard1] = sham(stimuli.standard1,specs.fs,spl_target,1,ha.sha.idata);
                elseif ~strcmpi(opts.test,'ILD')
                    % make stereo for NH
                    if isfield(stimuli,'target'); stimuli.target = [stimuli.target stimuli.target]; end
                    if isfield(stimuli,'standard1'); stimuli.standard1 = [stimuli.standard1 stimuli.standard1]; end
                    if isfield(stimuli,'standard2'); stimuli.standard2 = [stimuli.standard2 stimuli.standard2]; end
                end
            end
            
            % add hearing loss simulator
            if strcmpi(specs.HLsimulator,'yes')
                stimuli.HLnoise=HLSim_Filter(specs.HL_th_spl,.0000187551,(length(stimuli.target)/specs.fs)+0.4,0)';
                stimuli.target = [stimuli.HLnoise stimuli.HLnoise] + ...
                    [zeros(.2*specs.fs,2); stimuli.target; zeros(.2*specs.fs,2)];
                stimuli.standard1 = [stimuli.HLnoise stimuli.HLnoise] + ...
                    [zeros(.2*specs.fs,2); stimuli.standard1; zeros(.2*specs.fs,2)];
                stimuli.standard2 = [stimuli.HLnoise stimuli.HLnoise] + ...
                    [zeros(.2*specs.fs,2); stimuli.standard2; zeros(.2*specs.fs,2)];
            end
            
            % ADD ATTENUATION
            if specs.atten ~=0
                if isfield(stimuli,'target')
                    stimuli.target(:,1) = change_spl(stimuli.target(:,1),specs.atten);
                    stimuli.target(:,2) = change_spl(stimuli.target(:,2),specs.atten);
                end
                if isfield(stimuli,'standard1')
                    stimuli.standard1(:,1) = change_spl(stimuli.standard1(:,1),specs.atten);
                    stimuli.standard1(:,2) = change_spl(stimuli.standard1(:,2),specs.atten);
                end
                if isfield(stimuli,'standard2')
                    stimuli.standard2(:,1) = change_spl(stimuli.standard2(:,1),specs.atten);
                    stimuli.standard2(:,2) = change_spl(stimuli.standard2(:,2),specs.atten);
                end
            end
            
            % present to desired ear
            switch opts.test
                case 'ILD'
                otherwise
                    switch opts.ear
                        case 'left'
                            if isfield(stimuli,'target'); stimuli.target(:,2) = zeros(size(stimuli.target(:,1))); end
                            if isfield(stimuli,'standard1'); stimuli.standard1(:,2) = zeros(size(stimuli.standard1(:,1))); end
                            if isfield(stimuli,'standard2'); stimuli.standard2(:,2) = zeros(size(stimuli.standard2(:,1))); end
                        case 'right'
                            if isfield(stimuli,'target'); stimuli.target(:,1) = zeros(size(stimuli.target(:,2))); end
                            if isfield(stimuli,'standard1'); stimuli.standard1(:,1) = zeros(size(stimuli.standard1(:,2))); end
                            if isfield(stimuli,'standard2'); stimuli.standard2(:,1) = zeros(size(stimuli.standard2(:,2))); end
                        case 'both'
                    end
            end
            
            
            % chop signal, if desired
            if isfield(specs,'chop_signal')
                if isfield(stimuli,'target')
                    stimuli.target = stimuli.target(specs.chop_signal(1):specs.chop_signal(2));
                    stimuli.target = gate(stimuli.target',.002,specs.fs);
                    stimuli.target = stimuli.target';
                end
                if isfield(stimuli,'standard1')
                    stimuli.standard1 = stimuli.standard1(specs.chop_signal(1):specs.chop_signal(2));
                    stimuli.standard1 = gate(stimuli.standard1',.002,specs.fs);
                    stimuli.standard1 = stimuli.standard1';
                end
                if isfield(stimuli,'standard2')
                    stimuli.standard2 = stimuli.standard2(specs.chop_signal(1):specs.chop_signal(2));
                    stimuli.standard2 = gate(stimuli.standard2',.002,specs.fs);
                    stimuli.standard2 = stimuli.standard2';
                end
            end
            
            % output limit
            if isnumeric(tk.OutputLimit)
                if isfield(stimuli,'target')
                    stimuliLv = calculate_spl(stimuli.target,specs.ref);
                    if stimuliLv > tk.OutputLimit
                        stimuli.target = change_spl(stimuli.target,tk.OutputLimit - stimuliLv);
                        stimuli.target_OutputLimit = 'yes';
                    else
                        stimuli.target_OutputLimit = 'no';
                    end
                end
                if isfield(stimuli,'standard1')
                    stimuliLv = calculate_spl(stimuli.standard1,specs.ref);
                    if stimuliLv > tk.OutputLimit
                        stimuli.standard1 = change_spl(stimuli.standard1,tk.OutputLimit - stimuliLv);
                        stimuli.standard_OutputLimit = 'yes';
                    else
                        stimuli.standard_OutputLimit = 'no';
                    end
                end
                if isfield(stimuli,'standard2')
                    stimuliLv = calculate_spl(stimuli.standard2,specs.ref);
                    if stimuliLv > tk.OutputLimit
                        stimuli.standard2 = change_spl(stimuli.standard2,tk.OutputLimit - stimuliLv);
                        stimuli.standard_OutputLimit = 'yes';
                    else
                        stimuli.standard_OutputLimit = 'no';
                    end
                end
            end
            
            %         % add standard2
            %         if ~strcmpi(opts.test,'spectralripple')&~strcmpi(opts.test,'ILD')
            %             stimuli.standard2 = stimuli.standard1;
            %         end
            
            %debug
            if strcmpi(opts.debug,'yes')
                display('Type RETURN to exit debug mode');
                keyboard;%type RETURN
                try
                    addpath('/Volumes/HARL/BSAP/Functions');
                    addpath('/Volumes/HARL/BSAP/Functions/filterbank')
                    fc=50:50:5000;
                    [y_spl, fc, FileNames] = calculate_1_3_octave_spl(22050,specs.ref,fc);
                    [real_fft,real_freqs, tticks]=fft_in_real_dB(stimuli.standard1(:,1),specs.ref);
                catch
                end
            end
            % present intervals and record target, standard
            figure(fig_gap);
            if response_temp > 0;
                response_temp = 0;
            end % don't let them hit button before presentation
            tk = present_intervals(handles,stimuli,specs.fs,opts,tk);
            tk.stimuli{tk.trialID(tk.CurrentTrack),tk.CurrentTrack} = stimuli;
            
            % generate an answer, if selected
            if opts.randomGenerator == 1 % random response
                if opts.num_intervals ==1 %for single interval procedure
                    temp_num = 2;
                else
                    temp_num = opts.num_intervals;
                end
                answer = randperm(temp_num);
                answer = answer(1);
                eval(['interval' int2str(answer)]);
            elseif opts.randomGenerator == 2 %carney model
                answer = model_carney(stimuli,specs,tk);
                eval(['interval' int2str(answer)]);
            elseif opts.randomGenerator == 3 %always correct
                answer = find(tk.data.(temp_track).target_interval(temp_trialID,:)==1);
                eval(['interval' int2str(answer)]);
            elseif opts.randomGenerator == 4 %always wrong
                answer = find(tk.data.(temp_track).target_interval(temp_trialID,:)==2);
                eval(['interval' int2str(answer)]);
            elseif opts.randomGenerator == 5 % Dau LP filter, from AFC program, which is Viemeister JASA 1979 leaky-integrator model
                answer = model_viemeister1979(stimuli,specs,tk,opts);
                eval(['interval' int2str(answer)]);
                
            end
            if tk.response_temp_allowed == 1
                if response_temp > 0
                    temp = response_temp; response_temp = 0;
                    switch temp
                        case '1'
                            interval1
                        case '2'
                            interval2
                    end
                    
                end
            end
            
        catch ME
            warndlg('Encountered an error. Will try to save the data.')
            end_data_collection;
            rethrow(ME)
        end
        
        
    end
%% functions
    function delete_fig(varargin)
        % clean up when closing the figure
        try c.Close(); end
    end

    function quit_prog(source,eventdata)
        button_tag = get(source,'Tag');
        switch button_tag
            case 'pause'
                QuitProg = 1;
            case'quit'
                h = questdlg('Are you sure?','Confirm','No');
                if strcmpi(h,'Yes')
                    QuitProg = 2;
                end
        end
        figure(fig_gap);% get back to subject response figure
    end

    function end_data_collection(varargin)
        try
            fig_tracker.uiPause.Visible = 'off';
            fig_tracker.uiQuit.Visible = 'off';
            saveas (fig_tracker.fig,[opts.folders.data opts.DataFileName],'epsc');
            close(fig_gap); close(fig_tracker.fig); close(reward.fig.main);
            archstr = computer('arch');
            if strcmpi(archstr(1:3),'MAC'); system(['open "' [opts.folders.data opts.DataFileName] '.eps"']);
            elseif strcmpi(archstr(1:3),'win'); winopen([opts.folders.data opts.DataFileName '.eps']); end
        end
    end


end
