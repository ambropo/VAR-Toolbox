function out = LegPlot(text,opt)
% =======================================================================
% This function creates a legend outside the chart, centered, & below
% =======================================================================
% out = LegPlot(text,opt)
% -----------------------------------------------------------------------
% INPUT
%   - text: cell, containing the legend text
% -----------------------------------------------------------------------
% OPTIONAL INPUTS
%   - opt: options for the legend, output of LegOption function
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% Preliminaries
% =========================================================================
if ~exist('opt','var')
    opt = LegOption;
end

hsize = opt.hsize;
interpreter = opt.interpreter;
direction = opt.direction;
handle = opt.handle;

if hsize<=0 || hsize>1
    disp('Error: hsize must be between zero and one');
    return
end

if isempty(handle)==1
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
% out(1) is the location along the x-axis
% out(2) is the location along the y-axis
% out(3) is the width
% out(2) is the height
out = get(h1,'Position');


% ------------- Examples ------------------------------------
% out(1)	out(2)	Vertical alignment	Horizontal alignment
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
axpos = get(gca,'outerPosition');

% % Increase the hsize of the figure to make room for the legend
% FigSize(figpos(3),figpos(4)*(1+out(4)));

% Reduce the y hsize of the plot and move up to make room for legend
axpos(1) = axpos(1);
axpos(2) = axpos(2) + 1.1*out(4);
axpos(3) = axpos(3);
axpos(4) = 1 - 1.1*out(4);
set(gca,'outerPosition',axpos);

% Determine the position for centering the legend
out(3) = hsize; % First set the width of the legend in relative terms (1=whole figure)
out(1) = (figpos(3)-figpos(3)*out(3)) /2 /figpos(3); % Then compute the center
out(2) = 0.005;

% Place the legend
set(h1,'Position',out);