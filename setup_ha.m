function [ha] = setup_ha(ha,ear,test)

if nargin < 2
    ear = 'both';
end

switch ear
    case 'left'
        ear_label = {'left'};
    case 'right'
        ear_label = {'right'};
    case 'both'
        ear_label = {'left' 'right'};
end

if strcmpi(test,'ILD')
    ear_label = {'left' 'right'};
end

for earID = 1:length(ear_label)
    load (ha.folder.(ear_label{earID}),'DSL');
    ha.(ear_label{earID}) = DSL;
    try
        ha.(ear_label{earID}).attack = ha.attack;
        ha.(ear_label{earID}).release = ha.release;
    catch
        disp(['user did not enter ha.attack or ha.release value(s). Using values in DSL.mat file(s). You can ignore this message if that was intentional.']);
    end
end
ha.maxdB = 119; % from Josh - max output of the headphones

end