% change these with each subject
opts.ear = 'left';
tk.snr = [60 60]; % start SNR or signal level for track 1 and 2, respectively

opts.folders.data = './Data/'; % location of reversal data, etc
ha.switch = 'no'
opts.StringReadyButton = 'Press when ready';
opts.instructions = 'Select the button with a sound';
opts.num_intervals = 3;
opts.num_intervals_displayed = 3;

tk.signal_lv_calc = 'peak';

opts.displayGUI = 1; % 0 = no GUI, 1 = GUI
opts.randomGenerator = 0; % 0 = subject input, 1 = random response
opts.noSound = 0;% 0 = play sound, 1 = no sound
opts.position = [.3 1.1 0.5 0.4];%left, bottom, width, height of feedback screen
opts.PositionReadyButton = [.3 1.1 .4 .4]; % position of GUI to start test
opts.SaveSoundFiles = 'yes';
opts.SoundFileFormat = '.flac';

% please phase out
opts.pause_interval = .3; % the interval where nothing is yellow
opts.pause_internal_interval = .4; % the pause before and after when displaying yellow for pushbutton

specs.atten = 20; % attenuation value, to prevent quantization at low levels, is 0 or 20
specs.cal = 0; % calibration adjustment for unaided (-4) or aided (0);
specs.signal_gen = 'matlab';
specs.signal_dur = .5;
specs.signal_ramp = .02;
specs.signal_freq = [2000 2000];
specs.fs = 22050;
specs.ref = .0000011219; % for josh's 70 dB SPL cal tone



opts.test = 'threshold';
tk.max_snr = 95;
tk.min_snr = -15;
tk.OutputLimit = 'no';


reward.display = 0;
reward.randomize = 0; %1 to randomize
reward.location = '/Users/Shared/COBRE/FeedbackPics' %location of directories with pics
reward.LoadLastPicture = 1; % do you want to start off where we left off?
reward.FigureLocation = [.25 1.5 .5 .5] %location of figure, from 0 to 1; left, bottom, width, height of feedback screen

tk.NumTracks = 2; % number of tracks
tk.step_size = [16 4 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2]; % step size
tk.max_reversals = [3 3]; % max num reversals
tk.max_trials = [20 20];
tk.num_up = [1 2]; % number of incorrect responses needed to go up for track 1 and 2, respectively
tk.num_down = [2 1]; % number of correct responses needed to go down for tracks 1 & 2, respectively


