opts.folders.data = '/Data/'; % location of reversal data, etc

specs.carrier_lv = 80; % carrier level

opts.displayGUI = 1; % 0 = no GUI, 1 = GUI
opts.randomGenerator = 0; % 0 = subject input, 1 = random response
opts.noSound = 0;% 0 = play sound, 1 = no sound
opts.position = [.2 1.4 0.6 0.35];%left, bottom, width, height of feedback screen

% please phase out
opts.pause_interval = .3; % the interval where nothing is yellow
opts.pause_internal_interval = .4; % the pause before and after when displaying yellow for pushbutton

specs.atten = 0; % attenuation value, to prevent quantization at low levels, is 0 or 20
specs.fs = 22050;
specs.ref = .0000011219; % for josh's 70 dB SPL cal tone

ha.switch = 'no' 

opts.ear = 'both';

specs.carrier_freq = [100 8000];
specs.carrier_dur = .4;
specs.carrier_ramp = .005;
specs.gap_ramp = .002; 

tk.max_snr = .2; %max duration
tk.min_snr = .004; %min duration
opts.test = 'gap detection';

% old method
specs.fs = 22050;
tk.snr = .2; % starting duration

tk.NumTracks = 1; % number of tracks
tk.step_size = [1.4 1.4 1.4 1.4 1.4 1.4 1.4 1.4] ; step size
tk.max_reversals = 7; % max num reversals
tk.max_trials = 40;
tk.num_up = [1 2]; % number of incorrects needed to go up for track 1 and 2, respectively
tk.num_down = [2 1]; % number of correct responses needed to go down for tracks 1 & 2, respectively
tk.step_size_procedure = 'divide'; % standard = adjust by dB, multiply = multiply by a factor after correct responses; divide after incorrect responses , divide = opposite of multiply.



