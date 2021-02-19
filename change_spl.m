function y_out = change_spl(y_in,new_spl_diff)

%try
% noise: the acoustic signal you want to change the dB SPL of
% new_spl_diff: the SPL difference to change the signal by

% created by marc brennan in Jan of 2010

if max(abs(y_in)) ~= 0
    Pr = .000002; % reference pressure
    y_in_rms = sqrt(sum(y_in.^2)/length(y_in));
    new_spl = 20*log10(y_in_rms/Pr) + new_spl_diff;

    new_spl = 10^(new_spl/20 + log10(Pr));

    y_out = y_in.*(Pr/y_in_rms); % set signal to a reference of 0 dB SPL in nominal units
    y_out = y_out.*(new_spl/Pr); % now set to new reference pressure, which is 10^(20/20+log10(.000002))
else
    y_out = y_in;
end
end