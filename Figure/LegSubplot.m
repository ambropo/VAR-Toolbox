function LegSubplot(text,opt)
% =======================================================================
% Creates a single legend for a figure that contains subplots
% =======================================================================
% LegSubplot(text,opt)
% -----------------------------------------------------------------------
% INPUT
%   - text: cell array of legend labels [cell]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - opt: options structure from LegOption
% -----------------------------------------------------------------------
% EXAMPLE
%   subplot(1,2,1); plot(rand(10,2)); subplot(1,2,2); plot(rand(10,2));
%   opt = LegOption;
%   LegSubplot({'Plot of \alpha','Plot of \beta'},opt)
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
hsize       = opt.hsize;
vsize       = opt.vsize;
interpreter = opt.interpreter;
direction   = opt.direction;
handle      = opt.handle;

% Validate hsize range
if hsize<=0 || hsize>1
    error('LegSubplot: hsize must be between 0 (exclusive) and 1 (inclusive)');
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

% Compute the centered horizontal position and place the legend.
% The legend is created on gca (the last active subplot); for a multi-panel
% figure it is logically attached to that subplot, not the figure as a whole.
legpos(3) = hsize;   % set legend width as a fraction of the figure width
legpos(1) = (figpos(3)-figpos(3)*legpos(3)) /2 /figpos(3);  % center it
legpos(2) = vsize;
set(h1,'Position',legpos,'Box','off');
