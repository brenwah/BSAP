function [fig_interval handles] = figure_interval(displayGUI,num_monitor)
%{
creates interval figures, returns the figure and it's handles

%}

if displayGUI == 0
    % open the figure and hide it
    fig_interval = figure('MenuBar','None','Units','Normalized','Position',[.1 .5 .5 .8]...
        ,'Visible','off');
    
else
    % open the figure
    
    if num_monitor == 1
        
        fig_interval = figure('MenuBar','None','Units','Normalized',...
            'Position',[0 0.25 0.8 0.2],...
            'Name','Hit the button that sounded different',...
            'DeleteFcn',@delete_fig);
        
    else
        
        fig_interval = figure('MenuBar','None','Units','Normalized',...
            'Position',[1 0.25 0.8 0.2],...
            'Name','Hit the button that sounded different',...
            'DeleteFcn',@delete_fig);
    end
    
    % Used to plot reward images
    %fig_interval_axis = axes('Units','Normalized','Position',[.25 .35 .5 .5],...
        %'XTick',[],'YTick',[]);
    %hold all;
    
    % create GUI Objects
    %uicontrol(fig_interval,'Style','Text','Tag','text1','Units','Normalized',...
     %   'Position',[.3 .88 .4 .1],'FontSize',24,...
      %  'String','Select the interval that sounds different')
    
    uicontrol(fig_interval,'Style','PushButton','Tag','pushbutton1','Units','Normalized',...
        'Position',[.1 .1 .2 .8],'FontSize',24,...
        'String','1','CallBack',@interval1)
    
    uicontrol(fig_interval,'Style','PushButton','Tag','pushbutton2','Units','Normalized',...
        'Position',[.4 .1 .2 .8],'FontSize',24,...
        'String','2','CallBack',@interval2)
    
    uicontrol(fig_interval,'Style','PushButton','Tag','pushbutton3','Units','Normalized',...
        'Position',[.7 .1 .2 .8],'FontSize',24,...
        'String','3','CallBack',@interval3)
    handles = guihandles(fig_interval);
    
    % prevent subject from pressing a button
    set(handles.pushbutton1,'Enable','Off')
    set(handles.pushbutton2,'Enable','Off')
    set(handles.pushbutton3,'Enable','Off')
    
end

%% interval functions
    function interval1(tk)
        tk.response = 1;
        track(tk);
    end

    function interval2(tk)
        tk.response = 2;
        track(tk);
    end

    function interval3(tk)
        tk.response = 3;
        track(tk);
    end

end