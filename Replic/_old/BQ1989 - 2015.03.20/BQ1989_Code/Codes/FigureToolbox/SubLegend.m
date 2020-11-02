function legpos = SubLegend(text,hsize,handle,interpreter,direction)
% OBSOLETE -- THIS HAS BEEN SUBSTITUTED BY SUBLEG.M
% =======================================================================
% This function creates a legend outside the chart, centered, & below
% =======================================================================
% legpos = SubLegend(text,hsize,handle,interpreter,direction)
% -----------------------------------------------------------------------
% INPUT
%   text : cell, containing the legend text
%   hsize : dimension of the legend in percentage of the figure hsize (0 is 
%          nothing 1 is the whole figure)
%
% OPTIONAL INPUT
%   vsize : vertical position, percent (0=bottom, 0.5=middle, default=0.01)
%   interpreter: default 'none', change to 'Tex' if needed
%   direction: direction of the legend (1=horizontal [default], 2=vertical)
% =======================================================================
% Ambrogio Cesa Bianchi, July 2011
% ambrogio.cesabianchi@gmail.com

%% Preliminaries
% =========================================================================
if hsize<=0 || hsize>1
    disp('Error: hsize must be between zero and one');
    return
end

if ~exist('interpreter','var')
    interpreter = 'none';
end

if ~exist('direction','var')
    direction = 1;
end

if ~exist('handle','var')
    handle_flag = 0;
else
    handle_flag = 1;
end

%% Legend
% =========================================================================
% Retrieve the position of the figure: [a b c d] = get(gcf,'Position')
% a and b are the (x,y) location of the upper left corner; c and d are the width and height of the window
figpos = get(gcf,'Position');

% Create the legend
if direction==1
    if handle_flag==1
        h1 = legend(handle,text,'Orientation','Horizontal','Fontsize',get(gca,'Fontsize')-1,'Interpreter',interpreter);
    else
        h1 = legend(text,'Orientation','Horizontal','Fontsize',get(gca,'Fontsize')-1,'Interpreter',interpreter);
    end
else
    if handle_flag==1
        h1 = legend(handle,text,'Orientation','Vertical','Fontsize',get(gca,'Fontsize')-1,'Interpreter',interpreter);
    else
        h1 = legend(text,'Orientation','Vertical','Fontsize',get(gca,'Fontsize')-1,'Interpreter',interpreter);
    end
end

% Retrieve the position of the legend:
% legpos(1) is the location along the x-axis
% legpos(2) is the location along the y-axis
% legpos(3) is the width
% legpos(2) is the height
legpos = get(h1,'Position');


% ------------- Examples ------------------------------------
% legpos(1)	legpos(2)	Vertical alignment	Horizontal alignment
% 0       0           Bottom              Left
% 0.5     0           Bottom              Center
% 0.9     0           Bottom              Right
% 0       0.5         Center              Left
% 0.5     0.5         Center              Center
% 0.9     0.5         Center              Right
% 0       0.9         Top                 Left
% 0.5     0.9         Top                 Center
% 0.9     0.9         Top                 Right
% ------------------------------------------------------------

% Make room for sublegend if font is different from default
axpos = get(gca,'OuterPosition');

% Increase the hsize of the figure to make room for the legend
% FigSize(figpos(3),figpos(4)*(1+legpos(4)));

% Reduce the y hsize of the plot and move up to make room for legend
axpos(1) = axpos(1);
axpos(2) = axpos(2) + 1.1*legpos(4);
axpos(3) = axpos(3);
axpos(4) = 1 - 1.1*legpos(4);
set(gca,'OuterPosition',axpos);

% Determine the position for centering the legend
legpos(3) = hsize;                      % First set the width of the legend in relative terms (1=whole figure)
legpos(1) = (figpos(3)-figpos(3)*legpos(3)) /2 /figpos(3); % Then compute the center
legpos(2) = 0.005;

% Place the legend
set(h1,'Position',legpos);