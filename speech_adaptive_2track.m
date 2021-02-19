function [results, specs,tk,ha,reward,opts] = speech_adaptive_2track(specs,tk,ha,reward,opts,ProgError)

%{
returns the reversal points for speech in noise, 2 tracks.
%}

%{
updates
    2012.06.06 copied from speech_adaptive.m
%}

% workaround for the repeat button
tk.fs = specs.fs;

%% define tracking variables, etc
tk.snr = tk.start_snr
myerror = 0;

if ~isfield(opts,'instructions')
    opts.instructions = 'Score the Response';
end
if ~isfield(opts,'TextButton1')
    opts.TextButton1 = 'correct';
end
if ~isfield(opts,'TextButton2')
    opts.TextButton2 = 'incorrect';
end
%% create the figure
%[fig_gap handles] = figure_interval(opts.displayGUI,1);
if opts.displayGUI == 0
    fig_gap = figure('MenuBar','None','Units','Normalized','Position',[0 0 1 1],...
        'Visible','off');
    
else
    
    fig_gap = figure('MenuBar','None','Units','Normalized','Position',...
        opts.position,'DeleteFcn',@delete_fig);
    
    % create GUI Objects
    uicontrol(fig_gap,'Style','Text','Tag','text1','Units','Normalized',...
        'Position',[.1 .7 .8 .2],'FontSize',24,'String',opts.instructions);
    
    uicontrol(fig_gap,'Style','PushButton','Tag','pushbutton1','Units','Normalized',...
        'Position',[.1 .3 .2 .2],'FontSize',24,'Enable','Off',...
        'String',opts.TextButton1,'CallBack',@interval1)
    
    uicontrol(fig_gap,'Style','PushButton','Tag','pushbutton2','Units','Normalized',...
        'Position',[.4 .3 .2 .2],'FontSize',24,'Enable','Off',...
        'String',opts.TextButton2,'CallBack',@interval2)
    
    if strcmpi(opts.ScorePhonemes,'yes') % add checkboxes
        
        uicontrol(fig_gap,'Style','Checkbox','Tag','checkbox1','Units','Normalized',...
            'Position',[.4 .1 .2 .2],'FontSize',24,...
            'String',opts.CheckBox1,'Enable','Off');
        
        uicontrol(fig_gap,'Style','Checkbox','Tag','checkbox2','Units','Normalized',...
            'Position',[.53 .1 .2 .2],'FontSize',24,...
            'String',opts.CheckBox2,'Enable','Off');
        
        uicontrol(fig_gap,'Style','Checkbox','Tag','checkbox3','Units','Normalized',...
            'Position',[.66 .1 .2 .2],'FontSize',24,...
            'String',opts.CheckBox3,'Enable','Off');
        
    end
    
    set(gcf, 'WindowKeyPressFcn', @key_press);
    
    handles = guihandles(fig_gap);
        
    % create figure for displaying tracker
    fig_tracker.fig = figure('MenuBar','None','Units','Normalized','Position',...
        [0 0 .7 .5]);
    title(opts.SetupFile.name);
    fig_tracker.axis1 = axes('Units','Normalized','Position',[.1 .6 .7 .35]);
    hold all; grid on;
    ylim([tk.min_snr tk.max_snr]);
    fig_tracker.axis2 = axes('Units','Normalized','Position',[.1 .1 .7 .35]);
    grid on;
    uicontrol('Style','PushButton','Units','Normalized','Tag','quit',...
        'Position',[.85 .4 .12 .1],'FontSize',16,'String','Quit','Callback',@quit_prog);
    uicontrol('Style','PushButton','Units','Normalized','Tag','repeat',...
        'Position',[.85 .6 .12 .1],'FontSize',16,'String','Repeat','Callback',@repeat);
    
    hold all;
    ylim([tk.min_snr tk.max_snr]);
    figure(fig_gap);
    
end

%% start the threshold search
if myerror == 0
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
                case 'a'
                    if get(handles.checkbox1,'Value') == 0
                        set(handles.checkbox1,'Value',1)
                    else
                        set(handles.checkbox1,'Value',0)
                    end
                case 's'
                    if get(handles.checkbox2,'Value') == 0
                        set(handles.checkbox2,'Value',1)
                    else
                        set(handles.checkbox2,'Value',0)
                    end
                case 'd'
                    if get(handles.checkbox3,'Value') == 0
                        set(handles.checkbox3,'Value',1)
                    else
                        set(handles.checkbox3,'Value',0)
                end
            end
        end
    end

    function interval1(varargin)
        tk.response = 1;
        feedback
    end

    function interval2(varargin)
        tk.response = 2;
        feedback;
    end

%% feedback function
    function feedback
        if opts.displayGUI == 1
            % prevent subject from pressing a button
            tk.keypress_ok = 0;
            set(handles.pushbutton1,'Enable','Off');
            set(handles.pushbutton2,'Enable','Off');
            if strcmpi(opts.ScorePhonemes,'yes') %
                set(handles.checkbox1,'Enable','Off');
                set(handles.checkbox2,'Enable','Off');
                set(handles.checkbox3,'Enable','Off');
            end
        end
        
        if tk.response == 1;
            % do this if they correctly identifed the signal
            
            if opts.displayGUI == 1
                plot(fig_tracker.(['axis' int2str(tk.CurrentTrack)]),...
                    tk.trialID(tk.CurrentTrack),...
                    tk.snr(tk.CurrentTrack),'*g');
            end
            
            tk.PhonemeScore(:,tk.trialID(tk.CurrentTrack),tk.CurrentTrack) = [1; 1; 1];
            tk.correct(tk.CurrentTrack) = tk.correct(tk.CurrentTrack) +1;
            tk.incorrect(tk.CurrentTrack) = 0;
        else
            
            if opts.displayGUI == 1
                
                plot(fig_tracker.(['axis' int2str(tk.CurrentTrack)]),...
                    tk.trialID(tk.CurrentTrack),...
                    tk.snr(tk.CurrentTrack),'*r')
            end
            
            %extract PhonemeScore
            if strcmpi(opts.ScorePhonemes,'yes')
                tk.PhonemeScore(1,tk.trialID(tk.CurrentTrack),tk.CurrentTrack) = get(handles.checkbox1,'Value');
                tk.PhonemeScore(2,tk.trialID(tk.CurrentTrack),tk.CurrentTrack) = get(handles.checkbox2,'Value');
                tk.PhonemeScore(3,tk.trialID(tk.CurrentTrack),tk.CurrentTrack) = get(handles.checkbox3,'Value');
            end
            tk.correct(tk.CurrentTrack) = 0;
            tk.incorrect(tk.CurrentTrack) = tk.incorrect(tk.CurrentTrack)+1;
            
        end
        
        tk = track_speech(tk,opts.test);
        
        % assign variables for output
        results.reversals = tk.reversals;
        results.trialData = tk.trialData;
        results.correctData = tk.correctData;
        results.stimuli = tk.stimuli;
        results.PhonemeScore = tk.PhonemeScore;
        
        % wait a bit and then display reward
        if reward.display == 1
            reward = DisplayPicture(reward);
            pause(reward.duration);
        end
        
        % do we continue or quit?
        if tk.reversalID(1) > tk.max_reversals
            tk.finished(1) = 1;
            tk.CurrentTrack = 2; %we are done with track 1
        elseif tk.finished(1) == 1 % if user ends this track
            tk.CurrentTrack = 2;
        end
        
        if tk.NumTracks > 1
            if tk.reversalID(2) > tk.max_reversals
                tk.finished(2) = 1;
                tk.CurrentTrack = 1; %we are done with track 2
            elseif tk.finished(2) == 1 % if user ends this track
                tk.CurrentTrack = 1;
            end
        end
        
        % do we continue or quit?
        if tk.NumTracks == 1
            if sum(tk.finished) == 1
                tk.quit = 2;
            elseif tk.trialID == tk.max_trials + 1;
                tk.quit = 2;
            end
        elseif tk.NumTracks > 1
            if sum(tk.finished) == 2
                tk.quit = 2;
            elseif tk.trialID(2) == tk.max_trials + 1
                tk.quit = 2;
            end
        end
        
        if tk.quit == 2;
            try
                saveas (fig_tracker.fig,[opts.folders.data opts.DataFileName '.eps'],'psc2');
                close(fig_gap);
                close(fig_tracker.fig);
                close(reward.fig.main);
            end
        else
            %reset phonemescore, if necessary
            if strcmpi(opts.ScorePhonemes,'yes')
                set(handles.checkbox1,'Value',0);
                set(handles.checkbox2,'Value',0);
                set(handles.checkbox3,'Value',0);
            end
            present;
        end
    end
%% present function
    function present(varargin)
        
        % show current SNR and reversalID
        if opts.displayGUI == 1
            plot(fig_tracker.(['axis' int2str(tk.CurrentTrack)]),...
                tk.trialID(tk.CurrentTrack),...
                tk.snr(tk.CurrentTrack),'*k');
            title(fig_tracker.(['axis' int2str(tk.CurrentTrack)]),...
                ['Reversal: ' int2str(tk.reversalID(tk.CurrentTrack)-1)]);
        end
        
        % generate target and standard stimuli
        if strcmpi(opts.test,'speech_in_noise')
            [stimuli myerror] = generate_speech_noise(opts,tk,ha,specs);
            
            % myerror 2 means the program was unable to create the stimuli.
            % The offending speech file is removed from the list and the
            % program will continue to try until it is sucessful.
            if myerror == 2
                while myerror == 2
                    [stimuli myerror] = generate_speech_noise(opts,tk,ha,specs);
                end
            end
            
        elseif strcmpi(opts.test,'speech_in_quiet')
            [stimuli myerror] = generate_speech(opts,ha,tk);
        end
        
        % do we have an error?
        if myerror == 1
            h = msgbox('Finished due to an error');
            waitfor(h);
            close(fig_gap);
            close(fig_tracker.fig);
        else
            
            % adjust by attenuation
            if specs.atten ~= 0
                stimuli.noise_sp = change_spl(stimuli.noise_sp,specs.atten);
            end
            
            % present intervals and record target, standard
            figure(fig_gap);
            present_intervals(handles,stimuli,specs.fs,opts,tk,stimuli.noise_sp,stimuli.filenames.sp);
            tk.keypress_ok = 1;
            tk.stimuli{tk.CurrentTrack,tk.trialID(tk.CurrentTrack)} = stimuli;
            
            % generate a random answer, if selected
            if opts.randomGenerator == 1
                random_answer = randperm(2);
                random_answer = random_answer(1);
                eval(['interval' int2str(random_answer)]);
            end
        end
        
        
    end

%% Repeat Function

    function repeat(varargin)
        % present intervals
        tk.keypress_ok = 0;
        figure(fig_gap);
        present_intervals(handles,tk.stimuli{tk.CurrentTrack,tk.trialID(tk.CurrentTrack)},...
            tk.fs,opts,tk,tk.stimuli{tk.CurrentTrack,tk.trialID(tk.CurrentTrack)}.noise_sp,...
            tk.stimuli{tk.CurrentTrack,tk.trialID(tk.CurrentTrack)}.filenames.sp);
        tk.keypress_ok = 1;
    end
%% functions
    function delete_fig(varargin)
        % clean up when closing the figure
        try c.Close(); end
    end

    function quit_prog(source,eventdata)
        if tk.finished(1) == 0
            h = questdlg('Quit Track 1?','Yes','No');
            if strcmpi(h,'Yes')
                tk.finished(1) = 1;
            end
        end
        if tk.NumTracks > 1
            if tk.finished(2) == 0
                h = questdlg('Quit Track 2?','Yes','No');
                if strcmpi(h,'Yes')
                    tk.finished(2) = 1;
                end
            end
        end
    end

end