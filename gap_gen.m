function [gap_noise] = gap_gen(noise,gap_dur, ramp_dur, fs)
%GAP_GEN places a gap in the signal
%   noise is the signal
%   gap_dur is the gap duration - defined as 1st and last zero point
%   ramp_dur is the ramp duration of the gap
%   fs is the sampling frequency

%{
updates
    2010.01.29 gap duration is now specified as ramp half way points
%}

% create zero points
gap_noise = ones(1,length(noise)); % create ones
npts = round(gap_dur*fs-ramp_dur*fs); % gap duration in sampling points
if npts < 0
    %warndlg('gap duration too short')
end
onset = round(length(noise)/2 - round(npts/2)); % starting sample point of gap
if onset < 0
    warndlg('gap onset is before signal starts')
    gap_noise = NaN;
    return
end
offset = round(length(noise)/2 + round(npts/2)); % ending sample point of gap
if offset > length(gap_noise)
    warndlg('gap offset is after signal starts')
    gap_noise = NaN;
    return
end
try
    gap_noise(onset:offset) = 0; % set gap portion to zero
catch
    gap_noise = NaN;
    warndlg('unable to create gap stimuli')
end
% apply ramp to onset of gap
npts = round(ramp_dur*fs); % ramp duration in sampling points
onset2 = onset - npts; % starting sample point of gap ramp
offset2 = onset-1; % ending sample point of gap ramp
gap_noise(onset2:offset2) = fliplr((sin(pi/2*[1:npts]./npts)).^2); % apply ramp to onset of gap

% apply ramp to offset of the gap
npts = round(ramp_dur*fs); % ramp duration in sampling points
onset3 = offset + 1; % starting sample point of gap ramp
offset3 = offset + npts; % ending sample point of gap ramp
gap_noise(onset3:offset3) = (sin(pi/2*[1:npts]./npts)).^2; % apply ramp to onset of gap

% apply ramp to noise signal
gap_noise = noise.*gap_noise;
end
