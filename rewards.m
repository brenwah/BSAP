classdef rewards
    % Reward data setup
    properties
        randomize = 0; % 1 to randomize
        StarGameLoc % Location of StarGame.dll
        display = 0; % are we going to display the rewards? 0 = no, 1 = yes
        location = 'C:\feedback' % location of the folder with the reward text file
        game % the text file
        GameType % the type of game
        duration = .1 % reward display duration in seconds
        FileNames = {}; % names and directory of the picture files
        
        CurrentPicture = 0; % the current picture we are displaying
        FigureLocation = [.2 .2 .5 .5]; % location of the figure
        fig % the figure
        ProgError = [];
        LoadLastPicture = 0; % Continue with the last picture played
    end
    
    methods
        function obj = rewards
            obj.ProgError.status = 0;
            obj.ProgError.message = [];
            obj.fig.main = [];
            obj.fig.axis = [];
        end
        function obj = load_reward_directory(obj)
            % select directory with feedback
            try
                obj.location = uigetdir(obj.location,'Select Feedback Directory'); % get all directories
                obj.FileNames = dir([obj.location filesep '*.bmp']);
                if obj.LoadLastPicture == 1;
                    load([obj.location filesep ...
                        'LastPicture.mat']);
                    obj.CurrentPicture = LastPicture;
                end
            catch
                obj.ProgError.status = 1;
                obj.ProgError.message = 'unable to open directory';
            end
            if isempty(obj.FileNames)
                obj.ProgError.status = 1;
                obj.ProgError.message = 'No Pictures in that directory';
            end
        end
        function obj = load_reward_files(obj)
            [SetupFile.name SetupFile.path] = uigetfile([obj.location '*.txt']);
            try
                [fid message] = fopen([SetupFile.path SetupFile.name],'r');
            catch
                obj.ProgError.message = message;
                obj.ProgError.status = 1;
            end
            
            EndOfFile = 0; % are we at the end?
            LineIDfile = 1;
            LineID = 1;
            LineData = {};
            
            try
                while EndOfFile == 0
                    LineData{LineID} = fgetl(fid);
                    
                    
                    %check for end of the file
                    LineID = LineID + 1;
                    LineIDfile = LineIDfile + 1;
                    if feof(fid) == 1
                        EndOfFile = 1;
                    end
                end
            catch
                obj.ProgError.message = 'Unable to Read the Data in Setup File';
                obj.ProgError.status = 1;
            end
            
            % Assign data
            try
                obj.GameType = LineData{1} ;
                obj.FileNames = LineData(2:end);
            catch
                obj.ProgError.message = 'Unable to Assign the Data in Setup File';
                obj.ProgError.status = 1;
            end
            
        end
        function obj = CreateRewardFigure(obj)
            try
                obj.fig.main = figure('MenuBar','None','Units','Normalized',...
                    'Position',obj.FigureLocation);
                obj.fig.axis = axes('Units','Normalized','Visible','off',...
                    'xTickLabel',' ');
            catch
                obj.ProgError.status = 1;
                obj.ProgError.message = 'Unable to create figure'
            end
        end
        function obj = DisplayPicture(obj)
                % do we need to create a figure?
                if ishandle(obj.fig.main)
                else
                    obj = CreateRewardFigure(obj);
                end
            try

                % find a random picture or advance by 1
                if obj.randomize == 1
                    obj.CurrentPicture = randperm(length(obj.FileNames));
                    obj.CurrentPicture = obj.CurrentPicture(1);
                else
                    obj.CurrentPicture = obj.CurrentPicture + 1;
                    if obj.CurrentPicture > length(obj.FileNames)
                        obj.CurrentPicture = 1;
                    end
                end

                % display picture
                x = imread([obj.location filesep obj.FileNames(obj.CurrentPicture).name]);
                image(x,'Parent',obj.fig.axis);
                set(obj.fig.axis,'xTickLabel',' ','yTickLabel', ' ','XTick',0, ...
                    'YTick',0);

                % write the last picture played
                LastPicture = obj.CurrentPicture;
                save([obj.location filesep 'LastPicture.mat'],'LastPicture'); 
            catch ME
                obj.ProgError.status = 1;
                obj.ProgError.message = 'unable to display picture';
                obj.ProgError.catch = ME;
            end
        end
    end
end
