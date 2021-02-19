function calibration(options,lv_adj)

if nargin < 1
    options = 1;
end

specs.fs = 22050;
specs.ref = .0000011219; % for josh's 70 dB SPL cal tone
specs.atten = inputdlg('Enter the specs.atten value:','Answer the question',1,{'0'});
specs.atten = str2num(specs.atten{1});

% wait until the subject is ready
fig_uiwait = figure('MenuBar','None','Units','Normalized','Position',...
    [.2 .2 .4 .4]);

uicontrol(fig_uiwait,'Style','PushButton','Tag','pushbutton1','Units','Normalized',...
    'Position',[.3 .3 .4 .4],'FontSize',24,...
    'String','Press to End Cal Tone','CallBack',@interval1)


if options ==1
    try
        % To calibrate stimuli

        [cal_tone, fs] = audioread('HAsim 70 dB CalibrationTone.wav');
        cal_tone = change_spl(cal_tone,specs.atten);
        cal_tone(:,2) = cal_tone;
        
        end_calibration = 0;
        p = audioplayer(cal_tone,fs,24);
        while end_calibration == 0
            playblocking(p);
        end
        
    catch
        msgbox('unable to play');
    end
elseif options ==2
    close(fig_uiwait);
    frequencies=[200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000];
    dur = 10; 
    for freqID = 1:length(frequencies)
        y = noise_gen(frequencies(freqID),frequencies(freqID),1,1,dur,specs.fs,.02);
        y = change_spl(y,80-calculate_spl(y)+specs.atten);
        p=audioplayer(y,specs.fs);
        h=msgbox([int2str(frequencies(freqID)) ' Hz']);
        playblocking(p);
        close(h);
    end
    
elseif options == 3
    
    % setup audiorecorder
    info = audiodevinfo;
    devices = struct2table(info.output); 
    disp(devices);
    numCH = 2;
    numBits = 24;
    devID = 2; %typically 2 for RME, 3 if using RME and RME pro
    recObj = audiorecorder(fs,numBits,numCH,devID);          
    
    uiwait('Run 114 dB SPL calibrator. This will set the calibration level');
    dur = 10; recordblocking(recObj,dur); y = getaudiodata(recObj); y = y(:,2); y_spl = calculate_spl(y,ref);
    lv_adj = 114-y_spl; disp(['calibration adjustment is ' num2str(lv_adj) ' dB']);
    
elseif options == 4

    [cal_tone, fs] = audioread('HAsim 70 dB CalibrationTone.wav');
    cal_tone = change_spl(cal_tone,specs.atten);
    cal_tone(:,2) = cal_tone;
    %dur = length(cal_tone)/specs.fs; % duration of tone is 20 seconds
    
    numCH = 2; numBits = 24; devID = 2; %typically 2 for RME, 3 if using RME and RME pro
    recObj = audiorecorder(fs,numBits,numCH,devID);          

    p = audioplayer(cal_tone,fs);
    play(p);
    for i = 1:3
        recordblocking(recObj,5); %rec for 5 seconds, display level
        pause(1);
        y = getaudiodata(recObj); y = y(:,2); y = change_spl(y,lv_adj);
        y_spl = calculate_1_3_octave(y,fs,specs.ref,1000); %1000 Hz 1/3 octave filter
        disp(['SPL=' num2str(y_spl(1))]); %for y_spl(1) gives fc=1000, (2) for overall SPL
    end


    
end

    function interval1(hObject, eventdata, handles)
        end_calibration = 1;
        close(gcf);
    end

end