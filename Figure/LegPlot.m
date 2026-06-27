function LegPlot(text,opt)
% =======================================================================
% Creates a legend centered below the chart, outside the plot area
% =======================================================================
% LegPlot(text,opt)
% -----------------------------------------------------------------------
% INPUT
%   - text: cell array of legend labels [cell]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - opt: options structure from LegOption
% -----------------------------------------------------------------------
% EXAMPLE
%   plot(1:10);
%   opt = LegOption;
%   LegPlot({'Plot of \alpha'},opt)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Load defaults if no options struct provided, then unpack fields
if ~exist('opt','var')
    opt = LegOption;
end

% Unpack all option fields into local variables
vsize       = opt.vsize;
hsize       = opt.hsize;
interpreter = opt.interpreter;
direction   = opt.direction;
handle      = opt.handle;

% Validate hsize range
if hsize<=0 || hsize>1
    error('LegPlot: hsize must be between 0 (exclusive) and 1 (inclusive)');
end

% Determine whether a specific handle vector was provided
if isempty(handle)
    handle_flag = 0;
else
    handle_flag = 1;
end

%% 2. LEGEND
% -----------------------------------------------------------------------
% Retrieve the figure position: [left bottom width height] in pixels
figpos = get(gcf,'Position');

% Create the legend with the requested orientation
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

% Retrieve the legend position: [x y width height] in normalised units
% x=0 left, x=0.5 center, x=0.9 right;  y=0 bottom, y=0.9 top
legpos = get(h1,'Position');

% Shrink and shift the axes upward to make room for the legend below.
% axpos(4) subtracts from the current axes height rather than replacing it,
% so this works even when the axes does not occupy the full figure height.
axpos    = get(gca,'outerPosition');
axpos(2) = axpos(2) + 1.01*legpos(4);
axpos(4) = axpos(4) - 1.1*legpos(4);
set(gca,'outerPosition',axpos);

% Compute the centered horizontal position and place the legend.
% legpos(1) = (1 - legpos(3)) / 2, i.e. (figure_width - legend_width) / 2
% normalised by figure_width; written in full to match the pixel-unit figpos.
legpos(3) = hsize;   % set legend width as a fraction of the figure width
legpos(1) = (figpos(3)-figpos(3)*legpos(3)) /2 /figpos(3);  % center it
legpos(2) = vsize;
set(h1,'Position',legpos,'Box','off');
