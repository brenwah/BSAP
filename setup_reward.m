function opts = setup_reward(opts)

opts.rewards.location = 'C:\feedback\'; % location of pictures
opts.rewards.game = dir([opts.rewards.location '*.txt']); % get all directories
opts.rewards.game = {opts.rewards.game.name};
[selection,ok] = listdlg('PromptString','Select Reward',...
    'SelectionMode', 'single',...
    'ListString',opts.rewards.game);
opts.rewards.game = opts.rewards.game{selection};
opts.rewards.duration = .1; % reward display duration in seconds

end