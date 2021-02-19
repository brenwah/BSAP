function remove_stimuli_and_eps

%{
Removes all stimuli from the BSAP .mat file.
This can be useful for saving space
%}

FolderInput = uigetdir(cd, 'Source Folder');
FileNames = dir([FolderInput filesep '*.mat']);

for i = 1:length(FileNames)
    display(['File ' int2str(i) ' of ' int2str(length(FileNames))]);
    try
        load([FolderInput filesep FileNames(i).name]);
        results = rmfield(results,'stimuli');
        save([FolderInput filesep FileNames(i).name],'results','-v7.3');
    catch
        display(['error with: ' FileNames(i).name])
    end
end

FileNames = dir([FolderInput filesep '*.fig']);

for i = 1:length(FileNames)
    display(['File ' int2str(i) ' of ' int2str(length(FileNames))]);
    try
        open([FolderInput filesep FileNames(i).name]);
        saveas(gcf,[FolderInput filesep FileNames(i).name(1:end-3) 'eps'],'epsc');
        close(gcf);
        %delete([FolderInput filesep FileNames(i).name]);
    catch
        display(['error with: ' FileNames(i).name])
    end
end

end
