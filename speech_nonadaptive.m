function [results] = speech_nonadaptive(specs,tk,ha,reward,opts)

msgbox('this function is to be deleted in a future version');
%{
presents speech for a set number of trials at specified level
%}

%{
updates
    2012.05.31 adapted from speech.adaptive.m
%}

h = msgbox('Press OK when ready');
uiwait(h);

%% define tracking variables
% tk.response = NaN; % what did the subject last press?
% tk.correct = 0; % how many in a row where correct?
% tk.incorrect = 0; % how many in a row where incorrect?
% tk.trialData = NaN(1,200); %speech wav file for each trial
% tk.correctData = NaN(1,200); %and whether the response was correct
% tk.trialID = 1; % trial ID
% tk.white = [0.7020    0.7020    0.7020]; % default background color for later
% tk.keypress_ok = 0; %0 = no, 1 = yes
% tk.quit = 0; % does the user want to continue (0) pause (1) or quit (2)?
myerror = 0;

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
        'Position',[.1 .7 .8 .2],'FontSize',24,...
        'String','Score the Response')
    
    uicontrol(fig_gap,'Style','PushButton','Tag','pushbutton1','Units','Normalized',...
        'Position',[.1 .3 .2 .2],'FontSize',24,...
        'String','correct','CallBack',@interval1)
    
    uicontrol(fig_gap,'Style','PushButton','Tag','pushbutton2','Units','Normalized',...
        'Position',[.4 .3 .2 .2],'FontSize',24,...
        'String','incorrect','CallBack',@interval2)
    
    set(gcf, 'WindowKeyPressFcn', @key_press);
    
    handles = guihandles(fig_gap);
    
    % prevent subject from pressing a button
    set(handles.pushbutton1,'Enable','Off')
    set(handles.pushbutton2,'Enable','Off')
    
    % create figure for displaying tracker
    fig_tracker = figure('MenuBar','None','Units','Normalized','Position',...
        [0 0 .5 .5]);
    fig_tracker_axis = axes('Units','Normalized','Position',[.1 .35 .8 .4]);
    uicontrol('Style','PushButton','Units','Normalized','Tag','quit',...
        'Position',[.8 .8 .2 .1],'FontSize',16,'String','Quit','Callback',@quit_prog);
    uicontrol('Style','PushButton','Units','Normalized','Tag','pause',...
        'Position',[.4 .8 .2 .1],'FontSize',16,'String','Pause','Callback',@quit_prog);
    hold all;
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
        end
        
        if tk.response == 1;
            % do this if they correctly identifed the signal
            
            if opts.displayGUI == 1
                plot(fig_tracker_axis,tk.trialID,60,'*g');
            end
            
            tk.correct = tk.correct +1;
            tk.incorrect = 0;
        else
            
            if opts.displayGUI == 1
                plot(fig_tracker_axis,tk.trialID,60,'*r')
            end
            
            tk.correct = 0;
            tk.incorrect = tk.incorrect+1;
            
        end
        
        %increment by one
        tk.trialID = tk.trialID+1;
        
        tk = track_speech(tk,opts.test);

        % wait a bit and then display reward
        if reward.display == 1
            reward = DisplayPicture(reward);
            pause(reward.duration);
        end
        
        % assign variables for output
        results.trialData = tk.trialData;
        results.correctData = tk.correctData;
        results.stimuli = tk.stimuli;
        
        % do we continue or quit?
        if tk.trialID == tk.max_trials + 1
            try
                close(fig_gap);
                close(fig_tracker);
                close(reward.fig.main);
            end
        elseif tk.quit == 1;
            h = msgbox('Press Ok when Ready');
            uiwait(h);
            tk.quit = 0;
            present
        elseif tk.quit == 2;
            try
                close(fig_gap);
                close(fig_tracker);
                close(reward.fig.main);
            end
        else
            present;
        end
        
    end
%% present function
    function present(varargin)
        
        
        % generate target and standard stimuli
        if strcmpi(opts.test,'speech_in_noise')
            [stimuli myerror] = generate_speech_noise(opts,tk.snr,ha);
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
        % present intervals and record target, standard
        figure(fig_gap);
        present_speech(handles,stimuli.noise_sp,specs.fs,stimuli.filenames.sp,opts);
        tk.keypress_ok = 1;
        tk.stimuli{tk.trialID} = stimuli;
        
        % generate a random answer, if selected
        if opts.randomGenerator == 1
            random_answer = randperm(2);
            random_answer = random_answer(1);
            eval(['interval' int2str(random_answer)]);
        end
        end
        
        
    end
%% reward function
%     function reward(varargin)
%         
%         % make gui invisible
%         set(fig_gap,'Visible','off');
%         
%         
%         res = c.Step();   %% step returns 1 as long as it can move next step. Returns 0 when no further steps are possible.
%         pause(0.05);
%         c.game.Draw(0);
%         
%         % wait and then make GUI visible
%         pause(opts.rewards.duration);
%         set(fig_gap,'Visible','on');
%     end

    function delete_fig(varargin)
        % clean up when closing the figure
        try c.Close(); end
    end

    function quit_prog(source,eventdata)
        button_tag = get(source,'Tag');
        switch button_tag
            case 'pause'
                tk.quit = 1;
            case'quit'
                h = questdlg('Are you sure?','Confirm','No');
                if strcmpi(h,'Yes')
                    tk.quit = 2;
                end
        end
    end


end
