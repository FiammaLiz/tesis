function equispace(fighandle)

    %makes row subplots of figure same height
    %operates on figure handle of figure with subplots
    %removes xlabels of all but bottom
    
    %EXAMPLE:
%     f1=figure(1);clf;
%     subplot(2,1,1);plot(sin(1:100));
%     subplot(2,1,2);plot(cos(1:100));
%     equispace(f1)
    
%     axes=get(fighandle,'Children');
    axes=findobj(fighandle,'type','axes');
    axes=flipud(axes);
    numaxes=length(axes);
    
    pos=get(axes(1:numaxes),'position');
    bottom=pos{numaxes}(2);
    top=pos{1}(2)+pos{1}(4);
    plotspace=top-bottom;

    for a=1:numaxes
        pos{a}(4)=plotspace/numaxes;
        pos{a}(2)=bottom+(numaxes-a)*plotspace/numaxes;
        set(axes(a),'position',pos{a});
        if a ~= numaxes
         set(axes(a),'xtick',[])
         set(axes(a),'xticklabel',[])
        end
    end

end