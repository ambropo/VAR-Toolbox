function [h, f1, f2] = PlotStatesShaded(Time,qS,LW,color,transparency,onlyswathe)
if ~exist('onlyswathe','var')
    onlyswathe=0;
end

if nargin<5
    transparency = .5;
end;
if nargin < 3
    r=0.8;
    g=0.8;
    b=0.8;
    color = [r g b];
    linecolor = 'k';
else
    linecolor = color*.65;
end;

if size(qS, 2) > 1
    if ~onlyswathe
        f2 = fill([Time;flip(Time)],[qS(:,1); flip(qS(:,5))],.75*color,'Linestyle','none','facealpha',transparency);
        hold on
        f1 = fill([Time;flip(Time)],[qS(:,2); flip(qS(:,4))],.5*color,'Linestyle','none','Linestyle','none','facealpha',transparency);
        hold on
        h = plot(Time,qS(:,3),'-','Color',linecolor,'LineWidth',LW);
        hold on
    else
        f2 = fill([Time;flip(Time)],[qS(:,1); flip(qS(:,5))],.75*color,'Linestyle','none','facealpha',transparency);
        hold on
        f1 = fill([Time;flip(Time)],[qS(:,2); flip(qS(:,4))],.5*color,'Linestyle','none','Linestyle','none','facealpha',transparency);
        hold on
        h=[];
    end
else
    h = plot(Time,qS(:,1),'-','Color',linecolor,'LineWidth',LW);
    hold on
end
plot(Time,Time*0,'k','LineWidth',.25)
hold off;
set(gcf,'Color','w')
% set(gca,'XTick', Time(1:40:end),'XMinorTick','on')
% axis tight; box on;
% datetick('x', 17,'keeplimits', 'keepticks')
%legend([p1 p2],'Median','Realized','Location','Best')