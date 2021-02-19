opts.folders.data = '/Users/mbrennan3/Downloads/';

specs.masker_lv = 90;
specs.masker_lv_calc = 'peak';
tk.start_snr = 95;
tk.signal_lv = 95;
tk.signal_lv_calc = 'peak';
tk.snr = 90

opts.displayGUI = 1;
opts.randomGenerator = 0;
opts.noSound = 0;
opts.position = [.1 .1 .5 .4];
opts.PositionReadyButton = [.5 .5 .4 .4];
opts.pause_interval = .3;
opts.pause_internal_interval = .4
opts.SaveSoundFiles = 'yes';
opts.SoundFileFormat = '.flac';

specs.atten = 0
specs.fs = 22050; %100e3 %fs for carney model
specs.ref = .0000011219 %0.00002 % ref for CARNEY model
ha.switch = 'no'
opts.ear = 'left'
opts.test = 'forward masking'
tk.max_snr = 100
tk.min_snr = 0
tk.OutputLimit = 'no'
specs.cal = -4
opts.folders.signal = 'FM Stimuli/probe tones 4k/10 delay'
opts.folders.masker = 'FM Stimuli/tone maskers 4k'
reward.display = 0
tk.NumTracks = 1
tk.step_size = [12 6 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3]
tk.max_reversals = 4
tk.max_trials = 50
tk.num_up = [1 2]
tk.num_down = [2 1]
