function run_digit_span
% load data
ha = []; opts = []; specs = []; tk = []; ProgError.status = 0; 
reward = rewards;
[ha opts specs tk reward ProgError] = load_data(reward,ProgError);

% error check
if ProgError.status == 1
    fig.h = msgbox({'Unable to Load Setup File' ; ProgError.message});
    return
end

if strcmpi(ha.switch,'yes')
    % load HA data
    ha = setup_ha({ha.folder.left ha.folder.right},ha);
end

if reward.display == 1;
    reward = load_reward_directory(reward)
end

% play digits
[results] = speech_nonadaptive(specs,tk,ha,reward,opts)
save_results(results,specs,opts,tk,ha,reward,opts.folders.data)

end






