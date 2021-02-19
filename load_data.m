function [ha, opts, specs, tk, reward, ProgError] = load_data(reward,tk,ProgError)
[SetupFile.name, SetupFile.path] = uigetfile('*.*','Select Setup File');

if strcmpi(SetupFile.name(end-2:end),'mat')
    load([SetupFile.path SetupFile.name]); names=fieldnames(SetupInfo);
    for i = 1:length(names)
        switch names{i}
            case 'ha'
                ha=SetupInfo.ha;
            case 'opts'
                opts=SetupInfo.opts;
            case 'specs'
                specs=SetupInfo.specs;
            case 'tk'
                tk=SetupInfo.tk;
            case 'reward'
                reward=SetupInfo.reward;
            case 'ProgError'
                ProgError=SetupInfo.ProgError;
            otherwise
                warning(['Unexpected variable: ' names{i}]);
        end
    end
else
    temp_proceed = 1;
%     if strcmpi(SetupFile.name(end-1:end),'.m')
%         try
%             
%             temp_proceed = 0;
%         catch
%             temp_proceed = 1;
%         end
%     end
    
    if temp_proceed == 1
        try
            [fid, MessageTemp] = fopen([SetupFile.path SetupFile.name],'r');
            opts.SetupFile = SetupFile;
        catch
            ProgError.message = MessageTemp;
            ProgError.status = 1;
            warning(ProgError.message);
        end
        
        EndOfFile = 0; % are we at the end?
        LineIDfile = 1;
        LineID = 1;
        LineData = {};
        ParsedLineData = {};
        
        
        while EndOfFile == 0
            try
                
                LineData{LineID} = fgetl(fid);
                
                % remove empty lines or anything after ; or %
                removeID = strfind(LineData{LineID},';'); LineData{LineID}(removeID:end) = [];
                removeID = strfind(LineData{LineID},'%'); LineData{LineID}(removeID:end) = [];
                if isempty(LineData{LineID})
                    LineData(LineID) = [];
                    LineID = LineID -1;
                else
                    % split by the equal sign; determine if string or numbers after equal
                    % sign
                    EqualSignID = strfind(LineData{LineID},'=');
                    ParsedLineData{LineID,1} = LineData{LineID}(1:EqualSignID-2);
                    ParsedLineData{LineID,2} = LineData{LineID}(EqualSignID+2:end);
                    numORstring = strfind(ParsedLineData{LineID,2},'''');
                    if ~isempty(numORstring)
                        numORstring(1) = numORstring(1) + 1;
                        numORstring(2) = numORstring(2) - 1;
                        ParsedLineData{LineID,2} = ParsedLineData{LineID,2}(numORstring(1):numORstring(2));
                    else
                        ParsedLineData{LineID,2} = str2num(ParsedLineData{LineID,2});
                    end
                end
                
                %check for end of the file
                LineID = LineID + 1;
                LineIDfile = LineIDfile + 1;
                if feof(fid) == 1
                    EndOfFile = 1;
                end
            catch
                ProgError.message = ['Unable to Read the Data in Setup File, line'...
                    int2str(LineIDfile) ': ' LineData{LineID}];
                ProgError.status = 1;
                warning(ProgError.message);
            end
        end
        
        
        % Assign data
        
        for LineID = 1:length(LineData)
            try
                CurrentLineData = {};
                fields = strfind(ParsedLineData{LineID,1},'.');
                structure = ParsedLineData{LineID,1}(1:fields(1)-1);
                fields = fields+1;
                fields(end+1) = length(ParsedLineData{LineID,1})+2;
                for i = 1:length(fields)-1
                    CurrentLineData{i} = ParsedLineData{LineID,1}(fields(i):fields(i+1)-2);
                end
                switch structure
                    case 'ha'
                        switch length(CurrentLineData)
                            case 1
                                ha.(CurrentLineData{1}) = ParsedLineData{LineID,2};
                            case 2
                                ha.(CurrentLineData{1}).(CurrentLineData{2}) = ...
                                    ParsedLineData{LineID,2};
                            case 3
                                ha.(CurrentLineData{1}).(CurrentLineData{2}). ...
                                    (CurrentLineData{3}) = ParsedLineData{LineID,2};
                        end
                    case 'opts'
                        switch length(CurrentLineData)
                            case 1
                                opts.(CurrentLineData{1}) = ParsedLineData{LineID,2};
                            case 2
                                opts.(CurrentLineData{1}).(CurrentLineData{2}) = ...
                                    ParsedLineData{LineID,2};
                            case 3
                                opts.(CurrentLineData{1}).(CurrentLineData{2}). ...
                                    (CurrentLineData{3}) = ParsedLineData{LineID,2};
                        end
                    case 'specs'
                        switch length(CurrentLineData)
                            case 1
                                specs.(CurrentLineData{1}) = ParsedLineData{LineID,2};
                            case 2
                                specs.(CurrentLineData{1}).(CurrentLineData{2}) = ...
                                    ParsedLineData{LineID,2};
                            case 3
                                specs.(CurrentLineData{1}).(CurrentLineData{2}). ...
                                    (CurrentLineData{3}) = ParsedLineData{LineID,2};
                        end
                    case 'tk'
                        switch length(CurrentLineData)
                            case 1
                                tk.(CurrentLineData{1}) = ParsedLineData{LineID,2};
                            case 2
                                tk.(CurrentLineData{1}).(CurrentLineData{2}) = ...
                                    ParsedLineData{LineID,2};
                            case 3
                                tk.(CurrentLineData{1}).(CurrentLineData{2}). ...
                                    (CurrentLineData{3}) = ParsedLineData{LineID,2};
                        end
                    case 'reward'
                        switch length(CurrentLineData)
                            case 1
                                reward.(CurrentLineData{1}) = ParsedLineData{LineID,2};
                            case 2
                                reward.(CurrentLineData{1}).(CurrentLineData{2}) = ...
                                    ParsedLineData{LineID,2};
                            case 3
                                reward.(CurrentLineData{1}).(CurrentLineData{2}). ...
                                    (CurrentLineData{3}) = ParsedLineData{LineID,2};
                        end
                    otherwise % don't do anything
                end
            catch
                ProgError.message = ['Unable to Assign the Data in Setup File line' int2str(LineID) ' '  CurrentLineData{1}];
                ProgError.status = 1;
                warning(ProgError.message);
                
            end
        end
    end
    
end
end