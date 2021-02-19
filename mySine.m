function [sine] = mySine(amp, freq, phase)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sine = mySine( amp, freq, phase)
% Creates a 1.0-second sinusoid sampled at 44100Hz (discrete)
% amp = amplitude
% freq = frequency in Hz
% phase = phase in radians
% sine = the sinusoid as a column vector
% Author: Ben Kirby
% Date: September 2, 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fs = 44100;           % sample rate in Hz
ts = 1/fs;            % sample period in sec
len = .4;              % length of sine wave in sec
n = [0:1:fs*len-1]';  % discrete-time index


sine = amp*sin(2*pi*freq*n*ts + phase);  % make sinusoid