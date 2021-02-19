function test
error = 0;
    [SetupFile.name SetupFile.path] = uigetfile('*.txt');
    try
        [fid message] = fopen([SetupFile.path SetupFile.name],'r');
    catch
        fig.h = msgbox(message);
        error = 1;
        uiwait(fig.h);
    end
    fig.h = msgbox(num2str(error));
    uiwait(fig.h);    
end