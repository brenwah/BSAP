%change with each subject
opts.ear = 'left';
specs.target_lv = 80; %set to target threshold + 10
tk.snr = [90]; % set to target threshold + 5 (starting masker level)

%things that change by condition
tk.swptc_f = [1000:10:3000]; %masker frequency by trial
specs.signal_freq = [2000 2000];


specs.masker_bw = 320;
specs.masker_dur = .7;
specs.masker_ramp = .02;
tk.masker_lv_calc = 'rms';

specs.signal_dur = .5;
specs.signal_ramp = .02;
specs.signal_loc = [2205:13229];
tk.signal_lv_calc = 'peak';


opts.folders.data = './Data/'; % location of reversal data, etc
opts.StringReadyButton = 'Press when ready';
opts.instructions = '1 = heard tone. 2 = did not hear tone.';
opts.instructions_presentation = '1 = heard tone. 2 = did not hear tone.';
opts.num_intervals_displayed = 0;
opts.ProvideFeedback = 'no'; %default is yes.
opts.SaveSoundFiles = 'yes';
opts.SoundFileFormat = '.flac';
opts.BitsPerSample = 24;
opts.randomGenerator = 1;
opts.displayGUI = 1; % 0 = no GUI, 1 = GUI
opts.noSound = 1;% 0 = play sound, 1 = no sound
opts.pause_interval = 0; % the interval where nothing is yellow
opts.pause_internal_interval = 0; % the pause before and after when displaying yellow for pushbutton
opts.position = [.3 1.1 0.5 0.4];%left, bottom, width, height of feedback screen
opts.PositionReadyButton = [0.3 1.1 .4 .4]; % position of GUI to start test
opts.num_intervals = 1;
opts.num_intervals_displayed = 1;

tk.max_snr = 95;
tk.min_snr = -15;

ha.switch = 'no'


specs.atten = 20; % attenuation value, to prevent quantization at low levels, is 0 or 20
specs.cal = 0; % calibration adjustment for NH;

specs.fs = 22050;
specs.ref = .0000011219; % for josh's 70 dB SPL cal tone

opts.test = 'swptc';
tk.OutputLimit = 'no';

reward.display = 0;
reward.randomize = 0; %1 to randomize
reward.location = '/Users/Shared/COBRE/FeedbackPics' %location of directories with pics
reward.LoadLastPicture = 1; % do you want to start off where we left off?
reward.FigureLocation = [.25 1.5 .5 .5] %location of figure, from 0 to 1; left, bottom, width, height of feedback screen

tk.NumTracks = 1; % number of tracks
tk.max_reversals = 201; % max num reversals
tk.max_trials = 201;
tk.step_size = -[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
tk.num_up = [1]; % number of incorrect responses needed to go up for track 1 and 2, respectively
tk.num_down = [1]; % number of correct responses needed to go down for tracks 1 & 2, respectively
tk.catch_probability = .2; %propability of a trial being a catch trial, from 0 to 1. Each time there is a catch trial, the max number of reversals and trials increases by 1
tk.catch_snr = -15; % catch SNR. set to below audibility. default = -15;

