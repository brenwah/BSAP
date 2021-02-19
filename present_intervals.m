function tk = present_intervals(handles,stimuli,fs,opts,tk,y,text)

% present a single trial in a 3AFC task or for speech. Returns the interval that
% contained the target. y & text are for speech. This soluction was done so
% that I could combined speech_present & present intervals. Later I will
% actually combine the two.
temp_track = ['track' int2str(tk.CurrentTrack)]; %to use the correct track to record data
temp_trialID = tk.trialID(tk.CurrentTrack);

if length(opts.test<4)
    test = 2;
elseif strcmpi(opts.test(1:6),'speech')
    test = 1;
else
    test = 2;
end

if test == 1
    
    % presents and records speech
    white = [0.7020    0.7020    0.7020]; % default background color for later
    
    if opts.noSound == 0
        %sound(stimuli.(stimID{target_interval(intervalID)}),fs); % play the stimuli
        if strcmpi(opts.displayFileName,'yes')
            set(handles.text1,'String',text);
        end
        pause(.5);
        player = audioplayer(y',fs);
        playblocking(player);
    end
    
    % turn buttons on. Now subject can indicate the response
    set(handles.pushbutton1,'Enable','on')
    set(handles.pushbutton2,'Enable','on')
        if strcmpi(opts.ScorePhonemes,'yes')
        set(handles.checkbox1,'Enable','on');
        set(handles.checkbox2,'Enable','on');
        set(handles.checkbox3,'Enable','on');
    end
    
else
    
    % define parameters
    pause_interval = opts.pause_interval; % the interval where nothing is yellow
    pause_internal_interval = opts.pause_internal_interval; % the pause before and after when displaying yellow for pushbutton
    
    white = [0.7020    0.7020    0.7020]; % default background color for later
    
    % determine the interval that has target
    target_interval(1:opts.num_intervals) = randperm(opts.num_intervals);
    stimID = {'target' 'standard1' 'standard2'};
    
    % play the three stimuli in order, if specified
    if opts.noSound == 0
        if isfield(opts,'instructions_presentation')
            handles.text1.String = opts.instructions_presentation;
        else
            handles.text1.String = 'Listen';handles.text1.BackgroundColor='y';
        end
        for intervalID = 1:opts.num_intervals
            interval_txt = int2str(intervalID);
            % change background color to yellow
            set(handles.(['pushbutton' interval_txt]),'BackgroundColor','y');
            
            pause (pause_internal_interval); % pause x seconds
            
            %sound(stimuli.(stimID{target_interval(intervalID)}),fs); % play the stimuli
            player = audioplayer(stimuli.(stimID{target_interval(intervalID)}), fs,24);
            playblocking(player);
            
            %pause(round(length(stimuli.target)/fs)) % acounnt for length of sound
            pause (pause_internal_interval); % pause x seconds
            set(handles.(['pushbutton' interval_txt]),'BackgroundColor',white); % change background color back to original
            pause(pause_interval); % pause between intervals, where nothing is yellow
        end
    end
    
    % turn buttons on. Now subject can indicate the response
    tk.keypress_ok = 1;
    set(handles.pushbutton1,'Enable','on')
    set(handles.pushbutton2,'Enable','on')
    if opts.num_intervals_displayed == 3
        set(handles.pushbutton3,'Enable','on')
    end
    handles.text1.String = opts.instructions;handles.text1.BackgroundColor='g';
    if tk.data.(temp_track).catch_trial(tk.trialID(tk.CurrentTrack)) == 1
        tk.data.(temp_track).target_interval(tk.trialID(tk.CurrentTrack),2) = 1;
    else
        tk.data.(temp_track).target_interval(tk.trialID(tk.CurrentTrack),1:length(target_interval)) = target_interval;
    end
    
end


end