function select_test
%SELECT_TEST runs a user selected function
%   Detailed explanation goes here

SelectedTest = 1;

% specify file, remove extension
fig_h.main = figure('Units','Normalized');

fig_h.listbox = uicontrol(fig_h.main,'Style','listbox','String',...
    {'Calibration','Speech, Adaptive, 2 Tracks',...
    'Speech, Adaptive, 1 Track' 'Psychoacoustic'},...
    'Units','Normalized','Position',[.2 .6 .3 .3],...
    'FontSize',16,'Position', [.2 .5 .6 .3], 'CallBack',@UpdateTest);

fig_h.pushbutton = uicontrol('Style','PushButton','String','Run',...
    'Units','Normalized','Position',[.2 .2 .2 .2],'FontSize',16,...
    'CallBack',@RunTest);

    function UpdateTest(Source, DataEvent)
        SelectedTest = get(Source,'Value');
    end
    function RunTest(Source,DataEvent)
        
        if SelectedTest ==1
            calibration;
        else
            % load data
            ha = []; opts = []; specs = []; ProgError.status = 0;
            tk = adaptive_tracker_combined;
            reward = rewards;
            [ha, opts, specs, tk, reward, ProgError] = load_data(reward,tk,ProgError);
            tk.data.track1(tk.max_trials(1)+1:end,:) = [];
            if tk.NumTracks == 2
                tk.data.track2(tk.max_trials(2)+1:end,:) = [];
            end
            
            % uncomment to save SetupInfo:
            SetupInfo.ha=ha;
            SetupInfo.opts=opts;
            SetupInfo.specs=specs;
            SetupInfo.tk=tk;
            SetupInfo.reward=reward;
            
            % error check
            if ProgError.status == 1
                fig.h = msgbox(ProgError.message);
                return
            end
            
            % set defaults, if needed
            if isfield(opts, 'PositionReadyButton') == 0
                opts.PositionReadyButton = [.45 .5 .08 .06];
            end
            if isfield(opts, 'randomize') == 0
                opts.randomize = 1;
            end
            if isfield(opts, 'SaveSoundFiles') == 0
                opts.SaveSoundFiles = 'no'
            end
            if isfield(opts, 'masker_bw') == 0
                opts.masker_bw = []; % do not compute spectrum level
            end
            if isfield(opts, 'StringReadyButton') == 0
                opts.StringReadyButton = 'Press to Start';
            end
            if isfield(opts, 'ScorePhonemes') == 0
                opts.ScorePhonemes = 'no';
            end
            if isfield(opts, 'debug') == 0
                opts.debug = 'no';
            end
            if isfield(specs, 'HLsimulator') == 0
                specs.HLsimulator= 'no';
            end
            if isfield(specs, 'randomlv') == 0
                specs.randomlv= 0;
            end
            if isfield(opts, 'text1') == 0
                opts.text1='1';
            end
            if isfield(opts, 'text2') == 0
                opts.text2='2';
            end
            if isfield(opts, 'text3') == 0
                opts.text3='3';
            end
            if isfield(opts, 'num_intervals_displayed') == 0
                opts.num_intervals_displayed=3;
            end
            if isfield(specs, 'NoiseShape') == 0
                specs.NoiseShape.f = [63	80	100	125	160	200	250	315	400	500	630	800	1000	1250	...
                    1600 2000 2500 3150	4000	5000	6300	8000	10000	12500];
                specs.NoiseShape.lv =[39 44 54 58  57 60 60 59 62 62 61 57 54 53 52 49 48 47 46 ...
                    44 44 44 43 41];
            end
            
            % load psyAcoustX data, if necessary
            if strcmpi(opts.test,'PsyAcoustX')
                specs.PsyAcoustX = load(opts.folders.PsyAcoustX,'PsyAcoustX');
                specs.PsyAcoustX = specs.PsyAcoustX.PsyAcoustX;
            end
            
            
            
            % load HA data
            if strcmpi(ha.switch,'yes') || strcmpi(ha.switch,'dsl')
                ha = setup_ha(ha,opts.ear,opts.test);
                if isempty(gcp('nocreate')) == 1
                    f = waitbar(.25,'Starting Parallel Processing');
                    parpool 'local'
                    waitbar(1,f);
                    close(f);
                end
            elseif strcmpi(ha.switch,'sha')
                ha.sha.idata = importdata(ha.sha.setupFile);
            elseif strcmpi(ha.switch,'cha')
                ha.sha.idata = importdata(ha.sha.setupFile);
            end
            
            if reward.display == 1
                reward = load_reward_directory(reward);
            end
            
            %specify location to save data
            opts.DataFileName = 0;
            DefaultName = strfind(opts.SetupFile.name,'.'); DefaultName = opts.SetupFile.name(1:DefaultName-1);
            while opts.DataFileName == 0
                [opts.DataFileName, opts.folders.data] = ...
                    uiputfile([opts.folders.data DefaultName '.mat']);
            end
            opts.DataFileName(end-3:end) = [];
            
            % use correct headphone jack
            f = warndlg(['Use Correct Headphone Jack for Atten = ' int2str(specs.atten)]);
            uiwait(f);
            
            % check for a second monitor
            pos = get(0,'MonitorPositions'); sz = size(pos);
            if ~sz(1) > 1
                warndlg('Second Monitor Not Detected');  
            end
            
            % wait until the subject is ready
            fig_uiwait = figure('MenuBar','None','Units','Normalized');
            pause(.25); fig_uiwait.Position = opts.PositionReadyButton;
            
            uicontrol(fig_uiwait,'Style','PushButton','Tag','pushbutton1','Units','Normalized',...
                'Position',[.3 .3 .4 .4],'FontSize',24,...
                'String',opts.StringReadyButton,'CallBack',@interval1)
            
            set(gcf, 'WindowKeyPressFcn', @key_press);
            
            waitfor(fig_uiwait);
            
            tic;
            
            switch SelectedTest
                case 2
                    [results] = speech_adaptive_2track(specs,tk,ha,reward,opts);
                case 3
                    tk = setup_1track(tk);
                    [results] = speech_adaptive_2track(specs,tk,ha,reward,opts);
                case 4
                    if tk.NumTracks ==1; tk = setup_1track(tk); end
                    [results, specs,tk,ha,reward,opts,ProgError] ...
                        = gui_forward_masking(specs,tk,ha,reward,opts,ProgError);
            end
            
            results.elapsedTime = toc;
            save_results(results,specs,opts,tk,ha,reward);
            
            try
                switch SelectedTest
                    
                    case 2
                        msg = sprintf('Track 1 Threshold: %3.1f \nTrack 2 Threshold: %3.0f' ,...
                            mean(results.reversals(1,tk.threshold_calc_num:end)),...
                            mean(results.reversals(2,tk.threshold_calc_num:end)));
                    case 3
                        msg = sprintf('Threshold: %3.1f' ,...
                            mean(results.reversals(1,tk.threshold_calc_num:end)));
                    case 4
                        switch opts.test
                            case 'gap detection'
                                msg = sprintf('Threshold: %3.1f ms' ,...
                                    geomean(results.reversals(1,tk.threshold_calc_num:end))*1000);
                            case 'swptc'
                                if tk.catch_probability > 0
                                    temp_num_catch_trials = sum(tk.data.track1.catch_trial==1);
                                    temp_num_catch_correct = sum(tk.data.track1.correctData(tk.data.track1.catch_trial==1));
                                    msg = ['Track 1 Proportion Correct Catch Trials: ' num2str(temp_num_catch_correct/temp_num_catch_trials,'%3.2f')];
                                    if tk.NumTracks == 2
                                        temp_num_catch_trials = nansum(tk.data.track2.catch_trial==1);
                                        temp_num_catch_correct = nansum(tk.data.track2.correctData(tk.data.track1.catch_trial==1));
                                        msg = [msg;'Track 2 Proportion Correct Catch Trials: ' num2str(temp_num_catch_correct/temp_num_catch_trials,'%3.2f')];
                                    end
                                else
                                    msg = 'completed';
                                end
                            otherwise
                                msg = sprintf('Threshold: %3.1f dB SPL' ,...
                                    mean(results.reversals(1,tk.threshold_calc_num:end)));
                            end
                end
                display_threshold(msg)
            catch
                display('unable to display threshold');
            end
            
            
        end
        
    end
end

function interval1(hObject, eventdata, handles)
close(gcf);
end

function key_press(varargin)
close(gcf);
end


