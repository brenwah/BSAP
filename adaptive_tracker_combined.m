classdef adaptive_tracker_combined
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        catch_probability (1,1) double {mustBeGreaterThanOrEqual(catch_probability,0), mustBeLessThanOrEqual(catch_probability,1)} = 0; %propability of a trial being a catch trial, from 0 to 1. Each time there is a catch trial, the max number of reversals and trials increases by 1
        catch_snr = -99; %signal level during catch trials. -99 means target is zeros.
        catch_correct = NaN; %was catch trial correct? 0 = no, 1 = yes
        
        correct = [0 0]; % how many in a row where correct for each track?
        CurrentTrack = 1;
        
        data = struct('track1',table(NaN(1000,1),NaN(1000,1),NaN(1000,1),NaN(1000,3),NaN(1000,1),NaN(1000,1),NaN(1000,1),...
            'VariableNames',{'trialID','catch_trial', 'trialData','target_interval', 'response','correctData','trackDirection'}),...
                      'track2',table(NaN(1000,1),NaN(1000,1),NaN(1000,1),NaN(1000,3),NaN(1000,1),NaN(1000,1),NaN(1000,1),...
            'VariableNames',{'trialID','catch_trial', 'trialData','target_interval', 'response','correctData','trackDirection'}));
        direction = {'down'; 'down'}; % what direction are we headed in - down means decreasing gap duration, up means increasing gap duration
        finished = [0 0]; % set to 1 when max trials or reversals reached, for tracks 1 and 2 respectively
        incorrect = [0; 0]; % how many in a row where incorrect?
        
        
        NumTracks = 2; % number of tracks
        
        max_snr = 10;
        method = 'adaptive'; %can be adaptive or constant
        min_snr = -10;
        
        response = NaN; % what did the subject last press?
        response_temp = 0; %used to record response prior to end of trial for swptc.
        response_temp_allowed = 0; % set to 1 to allow a response prior to end of trial. WARNING, subj can hit response key multiple times and prior to next presentation
        reversals = []; % reversal points
        reversalID = [1; 1];
        
        snr = [NaN NaN]; %current snr of each track

        trialData = NaN(2,200); %target level for each trial
        trialID = [1; 1]; % trial ID for each track
        
        correctData = NaN(2,200); %and whether the response was correct
        PhonemeScore = NaN(3,200,2); %(phonemeID,trialID,trackID) whether the initial or final phoneme was correct
        
        white = [0.7020    0.7020    0.7020]; % default background color for later
        keypress_ok = 0; %0 = no, 1 = yes
        quit = 0; % does the user want to continue (0) pause (1) or quit (2)?
        
        % used for speech in quiet, FM
        signal_lv = [];
        signal_lv_calc = []; % can be 'peak' or 'overall'
        masker_lv_calc = []; % can be 'peak' or 'overall'
        OutputLimit = 105; % max output (computed over entire length of stimuli)
        
        stimuli % used to store the data
        
        
        
        
        
        
        start_snr = [20 10]; % start SNR for track 1 and 2, respectively
        step_size = [9 6 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3]; % step size
        step_size_procedure = 'standard';% standard = adjust by dB, multiply = multiply by a factor after correct responses; divide after incorrect responses , divide = opposite of multiply.
        swptc_f = NaN; % the masker frequency for each trial for SWPTC test
        max_reversals = 6; % max num reversals
        threshold_calc_num = 4;
        max_trials = 50;
        num_up = [1 2]; % number of incorrects needed to go up for track 1 and 2, respectively
        num_down = [2 1]; % number of correct responses needed to go down for tracks 1 & 2, respectively
        
        % the 1st row is the first track, 2nd row is the second track
        %reversals = NaN(NumTracks,max_reversals); % reversal points
        fs = 22050;
        
        
        
    end
    
    methods
        
        function obj = setup_1track(obj)
            obj.finished = 0;
            obj.trialID = 1;
            obj.correct = 0; % how many in a row where correct?
            obj.incorrect = 0; % how many in a row where incorrect?
            obj.reversalID = 1;
            obj.trialData = obj.trialData(1,:); %target level for each trial
            obj.correctData = obj.correctData(1,:); %and whether the response was correct
        end
        
        function obj = track_speech(obj,~)
            %{
2 AFC tracker
    tk is the tracker data
    test is the test
            %}
            
            %record the trial data
            temp_track = ['track' int2str(obj.CurrentTrack)]; %to use the correct track to record data
            temp_trialID = obj.trialID(obj.CurrentTrack);
            obj.data.(temp_track).trialID(temp_trialID) = obj.trialID(obj.CurrentTrack);
            obj.data.(temp_track).trialData(temp_trialID) = obj.snr(obj.CurrentTrack);
            obj.data.(temp_track).correctData(temp_trialID) = obj.correct(obj.CurrentTrack);
            if strcmpi(obj.direction{obj.CurrentTrack},'down')
                obj.data.(temp_track).trackDirection(temp_trialID) = 0;
            else
                obj.data.(temp_track).trackDirection(temp_trialID) = 1;
            end
            % figure out the next presentation level, etc
            if obj.data.(temp_track).catch_trial(temp_trialID) == 0 %skip figuring out things if a catch trial
                if obj.correct(obj.CurrentTrack) > 0
                    
                    % do this if track is going down
                    if strcmpi(obj.direction{obj.CurrentTrack},'down')
                        % decrease signal level if needed
                        if obj.correct(obj.CurrentTrack) == obj.num_down(obj.CurrentTrack)
                            if strcmpi(obj.step_size_procedure,'divide')
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)/obj.step_size(obj.reversalID(obj.CurrentTrack));
                            elseif strcmpi(obj.step_size_procedure, 'multiply')
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)*obj.step_size(obj.reversalID(obj.CurrentTrack));
                            else
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack) - ...
                                    obj.step_size(obj.reversalID(obj.CurrentTrack));
                            end
                            obj.correct(obj.CurrentTrack) = 0; % reset correct count
                        end
                        
                    else % do this if track is going up
                        
                        if obj.correct(obj.CurrentTrack) ==obj.num_down(obj.CurrentTrack)
                            obj.reversals((obj.CurrentTrack),obj.reversalID(obj.CurrentTrack)) = ...
                                obj.snr(obj.CurrentTrack); % record reversal point
                            if ~isnan(obj.swptc_f(1))
                                obj.reversals(2,obj.reversalID(obj.CurrentTrack)) = obj.swptc_f(obj.trialID(obj.CurrentTrack));
                            end
                            obj.reversalID(obj.CurrentTrack) = ...
                                obj.reversalID(obj.CurrentTrack)+1; % increase reversal Index
                            obj.direction{obj.CurrentTrack} = 'down';
                            
                            if strcmpi(obj.step_size_procedure,'divide')% decrease signal level
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)/obj.step_size(obj.reversalID(obj.CurrentTrack));
                            elseif strcmpi(obj.step_size_procedure, 'multiply')
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)*obj.step_size(obj.reversalID(obj.CurrentTrack));
                            else
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)...
                                    - obj.step_size(obj.reversalID(obj.CurrentTrack));
                            end
                            obj.correct(obj.CurrentTrack) = 0;
                        end
                    end
                    
                else % nope, they got it wrong
                    
                    if strcmpi(obj.direction{obj.CurrentTrack},'down') % what do we do if we are going down?
                        % increase signal level if we need to
                        if obj.incorrect(obj.CurrentTrack) == obj.num_up(obj.CurrentTrack)
                            obj.reversals((obj.CurrentTrack),obj.reversalID(obj.CurrentTrack)) ...
                                = obj.snr(obj.CurrentTrack); % record reversal point
                            if ~isnan(obj.swptc_f(1))
                                obj.reversals(2,obj.reversalID(obj.CurrentTrack)) = obj.swptc_f(obj.trialID(obj.CurrentTrack));
                            end
                            obj.reversalID(obj.CurrentTrack)...
                                = obj.reversalID(obj.CurrentTrack)+1; % increase reversal Index
                            obj.direction{obj.CurrentTrack} = 'up';
                            
                            % increase signal level
                            if strcmpi(obj.step_size_procedure,'divide')
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)*obj.step_size(obj.reversalID(obj.CurrentTrack));
                            elseif strcmpi(obj.step_size_procedure,'multiply')
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)/obj.step_size(obj.reversalID(obj.CurrentTrack));
                            else
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)...
                                    + obj.step_size(obj.reversalID(obj.CurrentTrack));
                            end
                            obj.incorrect(obj.CurrentTrack) = 0; % reset incorrect counter
                        end
                        
                    else % what do we do if we are going up?
                        % increase signal level if needed
                        if obj.incorrect(obj.CurrentTrack) == obj.num_up(obj.CurrentTrack)
                            if strcmpi(obj.step_size_procedure,'divide')
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)*obj.step_size(obj.reversalID(obj.CurrentTrack));
                            elseif strcmpi(obj.step_size_procedure,'multiply')
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack)/obj.step_size(obj.reversalID(obj.CurrentTrack));
                            else
                                obj.snr(obj.CurrentTrack) = obj.snr(obj.CurrentTrack) + obj.step_size(obj.reversalID(obj.CurrentTrack));
                            end
                            obj.incorrect(obj.CurrentTrack) = 0; % reset incorrect counter
                        end
                    end
                end
                
                % ensure signal is appropriate
                if obj.snr(obj.CurrentTrack) > obj.max_snr
                    obj.snr(obj.CurrentTrack) = obj.max_snr;
                end
                if obj.snr(obj.CurrentTrack) < obj.min_snr
                    obj.snr(obj.CurrentTrack) = obj.min_snr;
                end
                
                %increment by one, change to other track, determine if we
                %continue
                obj.trialID(obj.CurrentTrack) = obj.trialID(obj.CurrentTrack)+1;
                if obj.NumTracks > 1
                    if obj.CurrentTrack == 1
                        obj.CurrentTrack = 2;
                    else
                        obj.CurrentTrack = 1;
                    end
                end
                
                
                % are we finished with this track?
                if obj.trialID(obj.CurrentTrack) > obj.max_trials(obj.CurrentTrack) || obj.reversalID(obj.CurrentTrack) > obj.max_reversals(obj.CurrentTrack);
                    obj.finished(obj.CurrentTrack) = 1;
                    if obj.NumTracks >1 % if we are finished, switch to the other track and also check if finished there too.
                        if obj.CurrentTrack == 1
                            obj.CurrentTrack = 2;
                        else
                            obj.CurrentTrack = 1;
                        end
                        if obj.trialID(obj.CurrentTrack) > obj.max_trials(obj.CurrentTrack) || obj.reversalID(obj.CurrentTrack) > obj.max_reversals(obj.CurrentTrack);
                            obj.finished(obj.CurrentTrack) = 1;
                        end
                    end
                end
                
                % determine if we are doing a catch trial                
                temp_track = ['track' int2str(obj.CurrentTrack)]; %to use the correct track to record data
                temp_trialID = obj.trialID(obj.CurrentTrack); %to use the correct trialID to record data
                if obj.finished(obj.CurrentTrack) == 0;
                    
                    if size(obj.data.(temp_track),1) < temp_trialID
                        obj.data.(temp_track){temp_trialID,:} = NaN;
                    end
                    
                    if rand < obj.catch_probability
                        obj.data.(temp_track).catch_trial(temp_trialID) = 1; % this indicates a catch trial
                    else
                        obj.data.(temp_track).catch_trial(temp_trialID) = 0;
                    end
                    
                    obj.signal_lv = obj.snr(obj.CurrentTrack);
                    
                end
                
            
            else %this was a catch trial
                obj.data.(temp_track).correctData(temp_trialID) = obj.catch_correct;
                obj.trialData = [obj.trialData NaN(size(obj.trialData,1),1)];
                obj.data.(temp_track){end+1,:} = NaN;
                obj.swptc_f = [obj.swptc_f(1:obj.trialID(obj.CurrentTrack)) obj.swptc_f(obj.trialID(obj.CurrentTrack)) obj.swptc_f(obj.trialID(obj.CurrentTrack)+1:end)];
                obj.max_reversals(obj.CurrentTrack) = obj.max_reversals(obj.CurrentTrack)+1;
                obj.max_trials(obj.CurrentTrack) = obj.max_trials(obj.CurrentTrack) + 1;  
                obj.trialID(obj.CurrentTrack) = obj.trialID(obj.CurrentTrack)+1; % increment trial by one, stay on same track
                obj.data.(temp_track).catch_trial(obj.trialID(obj.CurrentTrack)) = 0;
            end           
       
        end
        
        function obj = track_constant(obj,~)
            %record the trial data
            obj.trialData(obj.CurrentTrack,obj.trialID(obj.CurrentTrack)) ...
                = obj.snr(obj.CurrentTrack);
            obj.correctData(obj.CurrentTrack,obj.trialID(obj.CurrentTrack))...
                = obj.correct(obj.CurrentTrack);
            
            %adjust SNR here
            obj.snr(obj.CurrentTrack) = obj.step_size(obj.trialID(obj.CurrentTrack));
            
            % ensure signal is appropriate
            if obj.snr(obj.CurrentTrack) > obj.max_snr
                obj.snr(obj.CurrentTrack) = obj.max_snr;
            end
            if obj.snr(obj.CurrentTrack) < obj.min_snr
                if obj.data.(temp_track).catch_trial(temp_trialID) == 1 % only change if not a catch trial
                else
                    obj.snr(obj.CurrentTrack) = obj.min_snr;
                end
            end
            
            %increment by one and change to other track
            obj.trialID(obj.CurrentTrack) = obj.trialID(obj.CurrentTrack)+1;
            if obj.NumTracks > 1
                if obj.CurrentTrack == 1
                    obj.CurrentTrack = 2;
                else
                    obj.CurrentTrack = 1;
                end
            end
            obj.signal_lv = obj.snr(obj.CurrentTrack);
            
            
        end
        
    end
    
end

