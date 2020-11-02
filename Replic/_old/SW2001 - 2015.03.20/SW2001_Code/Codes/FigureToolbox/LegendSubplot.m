function LegendSubplot(text,vsize,interpreter,direction,handle)
% =======================================================================
% This function creates ONLY one legend for many subplots in one figure.
% The legend is centered below all subplots (you can modify it though)
% =======================================================================
% LegendSubplot(text,hsize,vsize,interpreter,direction,handle)
% -----------------------------------------------------------------------
% INPUT
%   text        : cell, containing the legend text
%
% OPTIONAL INPUT
%   - vsize       : vertical position, percent (0=bottom, 0.5=middle).
%                   Default is 0.01
%   - interpreter : default 'none', change to 'Tex' if needed
%   - direction   : direction of the legend. 1 = horizontal [default], 
%                   2 = vertical
%   - handle      : is the handle to the legend
% =======================================================================
% Ambrogio Cesa Bianchi, July 2011
% ambrogio.cesabianchi@gmail.com


%% Preliminaries
% =========================================================================
hsize = 0.01;

if ~exist('vsize','var')
    vsize = 0.01;
end

if ~exist('interpreter','var')
    interpreter = 'Tex';
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
% legpos(4) is the height
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



% Determine the position for centering the legend
legpos(3) = hsize;                      % First set the width of the legend in relative terms (1=whole figure)
legpos(1) = (figpos(3)-figpos(3)*legpos(3)) /2 /figpos(3); % Then compute the center
legpos(2) = vsize;                       % Bottom

set(h1,'Position',legpos);

