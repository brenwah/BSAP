function spl = calculate_spl(y,ref,bw)

%{
 calculates spl of y, ref is the reference pressure level (assummed
% .0000011219?Josh's reference) & BW is the BW of y (if desired to compute spectrum level)

 created by marc brennan in Jan of 2010
updates -
05/2011 - added reference pressure level
11/2014 - added BW so that you can compute spectrum level
%}

if nargin < 2
    ref = .0000011219; %0.000002;
end
y_in_rms = sqrt(sum(y.^2)/length(y));
spl = 20*log10(y_in_rms/ref);

% compute spectrum level
if nargin == 3 
    if ~isempty(bw)
        spl = spl-10*log10(bw)
    end
end

end