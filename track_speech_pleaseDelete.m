    function tk = track_speech(tk,test)
%{
    2 AFC tracker
    tk is the tracker data
    test is the test (threshold, forward masking, gap detection
%}
        
        %record the trial data
        tk.trialData(tk.CurrentTrack,tk.trialID(tk.CurrentTrack)) ...
            = tk.snr(tk.CurrentTrack);
        tk.correctData(tk.CurrentTrack,tk.trialID(tk.CurrentTrack))...
            = tk.correct(tk.CurrentTrack);
        
        % figure out the next presentation level, etc
        if tk.correct(tk.CurrentTrack) > 0
            
            % do this if track is going down
            if strcmpi(tk.direction{tk.CurrentTrack},'down')
                % decrease signal level if needed
                if tk.correct(tk.CurrentTrack) == tk.num_down(tk.CurrentTrack)
                    if strcmpi(test,'speech_in_noise')
                        tk.snr(tk.CurrentTrack)...
                            = tk.snr(tk.CurrentTrack) - ...
                            tk.step_size(tk.reversalID(tk.CurrentTrack));
                    end
                    tk.correct(tk.CurrentTrack) = 0; % reset correct count
                end
                
            else % do this if track is going up
                
                if tk.correct(tk.CurrentTrack) ==tk.num_down(tk.CurrentTrack)
                    tk.reversals((tk.CurrentTrack),tk.reversalID(tk.CurrentTrack)) = ...
                        tk.snr(tk.CurrentTrack); % record reversal point
                    tk.reversalID(tk.CurrentTrack) = ...
                        tk.reversalID(tk.CurrentTrack)+1; % increase reversal Index
                    tk.direction{tk.CurrentTrack} = 'down';
                    % decrease signal
                    if strcmpi(test,'speech_in_noise')
                        tk.snr(tk.CurrentTrack) = tk.snr(tk.CurrentTrack)...
                            - tk.step_size(tk.reversalID(tk.CurrentTrack)); 
                    end
                    tk.correct(tk.CurrentTrack) = 0;
                end
            end
            
        else % nope, they got it wrong
            
            if strcmpi(tk.direction{tk.CurrentTrack},'down') % what do we do if we are going down?
                % increase signal level if we need to
                if tk.incorrect(tk.CurrentTrack) == tk.num_up(tk.CurrentTrack)
                    tk.reversals((tk.CurrentTrack),tk.reversalID(tk.CurrentTrack)) ...
                        = tk.snr(tk.CurrentTrack); % record reversal point
                    tk.reversalID(tk.CurrentTrack)...
                        = tk.reversalID(tk.CurrentTrack)+1; % increase reversal Index
                    tk.direction{tk.CurrentTrack} = 'up';
                    % increase signal level
                    if strcmpi(test,'speech_in_noise')
                        tk.snr(tk.CurrentTrack) = tk.snr(tk.CurrentTrack)...
                            + tk.step_size(tk.reversalID(tk.CurrentTrack)); 
                    end
                    tk.incorrect(tk.CurrentTrack) = 0; % reset incorrect counter
                end
                
            else % what do we do if we are going up?
                % increase signal level if needed
                if tk.incorrect(tk.CurrentTrack) == tk.num_up(tk.CurrentTrack)
                    if strcmpi(test,'speech_in_noise')
                        tk.snr(tk.CurrentTrack) = tk.snr(tk.CurrentTrack)...
                            + tk.step_size(tk.reversalID(tk.CurrentTrack)); 
                    end     
                    tk.incorrect(tk.CurrentTrack) = 0; % reset incorrect counter
                end
            end
        end
        
        % ensure signal is appropriate
        if tk.snr(tk.CurrentTrack) > tk.max_snr
            tk.snr(tk.CurrentTrack) = tk.max_snr;
        end
        if tk.snr(tk.CurrentTrack) < tk.min_snr
            tk.snr(tk.CurrentTrack) = tk.min_snr;
        end        
        
        %increment by one and change to other track
        tk.trialID(tk.CurrentTrack) = tk.trialID(tk.CurrentTrack)+1;
        if tk.CurrentTrack == 1
            tk.CurrentTrack = 2;
        else
            tk.CurrentTrack = 1;
        end
        
    end
