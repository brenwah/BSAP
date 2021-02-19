function saveFigAsEPS
%{
Converts BSAP figs as EPS, to save space
%}

FolderInput = uigetdir(cd, 'Source Folder');
FileNames = dir([FolderInput filesep '*.fig']);

for i = 1:length(FileNames)
    display(['File ' int2str(i) ' of ' int2str(length(FileNames))]);
    try
        open([FolderInput filesep FileNames(i).name]);
        saveas(gcf,[FolderInput filesep FileNames(i).name(1:end-3) 'eps'],'epsc');
        close(gcf);
        delete([FolderInput filesep FileNames(i).name]);
    catch
        display(['error with: ' FileNames(i).name])
    end
end

end