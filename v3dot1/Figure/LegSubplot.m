function LegSubplot(text,opt)
% =======================================================================
% This function creates a single legend for charts created with subplot
% =======================================================================
% LegSubplot(text,opt)
% -----------------------------------------------------------------------
% INPUT
%   text : cell, containing the legend text
% -----------------------------------------------------------------------
% OPTIONAL INPUTS
%   opt  : options for the legend, output of LegOption function
% -----------------------------------------------------------------------
% EXAMPLE
%   subplot(1,2,1); plot(rand(10,2)); subplot(1,2,2); plot(rand(10,2)); 
%   opt = LegOption;
%   LegSubplot({'Plot of \alpha','Plot of \beta'},opt)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------

%% Preliminaries
if ~exist('opt','var')
    opt = LegOption;
end

hsize = opt.hsize;
vsize = opt.vsize;
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
axpos = get(gca,'outerPosition');

% Determine the position for centering the legend
legpos(3) = hsize;                      % First set the width of the legend in relative terms (1=whole figure)
legpos(1) = (figpos(3)-figpos(3)*legpos(3)) /2 /figpos(3); % Then compute the center
legpos(2) = vsize;                       % Bottom

% Place the legend
set(h1,'Position',legpos,'Box','off');
