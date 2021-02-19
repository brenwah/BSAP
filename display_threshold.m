function display_threshold(msg)
% wait until the subject is ready
fig_threshold = figure('MenuBar','None','Units','Normalized','Position',...
    [.4 .4 .4 .4]);

uicontrol(fig_threshold,'Style','Text','Tag','text1','Units','Normalized',...
    'Position',[.3 .6 .3 .4],'FontSize',24,'String',msg)

uicontrol(fig_threshold,'Style','PushButton','Tag','pushbutton1','Units','Normalized',...
    'Position',[.3 .1 .3 .4],'FontSize',24,...
    'String','Press to End','CallBack',@interval1)

waitfor(fig_threshold);

    function interval1(hObject, eventdata, handles)
        close(gcf);
    end
end