function remove_eps

%{
Removes all stimuli from the BSAP .mat file.
This can be useful for saving space
%}

FolderInput = uigetdir(cd, 'Source Folder');
FileNames = dir([FolderInput filesep '*.fig']);
close all
for i = 1:length(FileNames)
    display(['File ' int2str(i) ' of ' int2str(length(FileNames))]);
    try
        open([FolderInput filesep FileNames(i).name]);
        saveas(1,[FolderInput filesep FileNames(i).name(1:end-3) 'eps'],'epsc');
        close all;
        %delete([FolderInput filesep FileNames(i).name]);
    catch
        display(['error with: ' FileNames(i).name])
    end
end

end
