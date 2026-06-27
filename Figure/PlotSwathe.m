function H = PlotSwathe(bar,swathe,SwatheOpt)
% =======================================================================
% Plot a line with a shaded swathe (e.g. for impulse responses)
% =======================================================================
% H = PlotSwathe(bar,swathe,SwatheOpt)
% -----------------------------------------------------------------------
% INPUT
%   - bar   : central line to plot [1 x T] or [T x 1]
%   - swathe: if a vector, draws symmetric swathe around bar; if a matrix,
%             column 1 is the lower bound and column 2 is the upper bound
%             [1 x T], [T x 1], [2 x T], or [T x 2]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - SwatheOpt: options structure from PlotSwatheOption
%     .linecol   : color of the central line, RGB or string [dflt = dark blue]
%     .swathecol : color of the swathe, RGB or string [dflt = light blue]
%     .transp    : 1 to use transparency for the swathe patch [dflt = 0]
%     .alpha     : alpha value when transp=1 [dflt = 1]
%     .border      : 1 to draw lines at the swathe borders [dflt = 0]
%     .borderstyle : line style for border lines [dflt = '--']
%     .frequency : date frequency for x-axis labels [dflt = 'q']
%     .swatheonly: 1 to suppress the central line [dflt = 0]
%     .do_dates  : 1 to add date labels to the x-axis [dflt = 0];
%                  requires SwatheOpt.fo and SwatheOpt.nticks to be set
%     .fo        : first observation date (e.g. 1987.00 = 1987Q1) [dflt = []]
%     .nticks    : number of tick marks for date axis [dflt = []]
% -----------------------------------------------------------------------
% OUTPUT
%   - H.bar    : handle to the central line
%   - H.patch  : handle to the patch
%   - H.swathe : H.swathe(1) = upper edge, H.swathe(2) = lower edge
%   - H.ax     : handle to the current axes
%   - H.nobs   : number of observations
% -----------------------------------------------------------------------
% EXAMPLE
%   x = 3*(1:50);
%   swathe = [1*(1:50); 4*(1:50)];
%   H = PlotSwathe(x,swathe);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Load defaults if no options struct is provided
if ~exist('SwatheOpt','var')
    SwatheOpt = PlotSwatheOption;
end

% Resolve line color: accept either an RGB triplet or a color name string
if isnumeric(SwatheOpt.linecol)
    linecol = SwatheOpt.linecol;
else
    linecol = rgb(SwatheOpt.linecol);
end

% Resolve swathe color: accept either an RGB triplet or a color name string
if isnumeric(SwatheOpt.swathecol)
    swathecol = SwatheOpt.swathecol;
else
    swathecol = rgb(SwatheOpt.swathecol);
end

% Note: argument 'bar' shadows the MATLAB built-in bar() for this function scope.
% Record the number of observations and ensure bar is a row vector
nobs = length(bar); H.nobs = nobs;
if size(bar,1)>1
    bar = bar';
end

% Determine upper and lower error bounds from the swathe argument
if isvector(swathe)
    % Symmetric swathe: ensure swathe is a row vector, then offset bar
    if size(swathe,1)>1
        swathe = swathe';
    end
    low = bar - swathe;
    upp = bar + swathe;
else
    % Asymmetric swathe: row 1 = upper, row 2 = lower; transpose if needed
    if size(swathe,1)>2
        swathe = swathe';
    end
    upp = swathe(1,:);
    low = swathe(2,:);
end

%% 2. PLOT
% -----------------------------------------------------------------------
% Compute the edge color as a lightened version of the swathe color
edgeColor = swathecol+(1-swathecol)*0.55;

% Set patch opacity: fully opaque when transp=0, transparent when transp=1
swathealpha = SwatheOpt.alpha;
if SwatheOpt.transp==1
    faceAlpha  = swathealpha;
    patchColor = swathecol;
    set(gcf,'renderer','opengl')  % lowercase required; 'openGL' is not recognised on all versions
else
    faceAlpha  = 1;
    patchColor = swathecol+(1-swathecol)*(1-swathealpha);
    set(gcf,'renderer','painters')
end

% Plot the central bar line (drawn first, then re-drawn on top of patch)
if isfield(SwatheOpt,'xvec') && ~isempty(SwatheOpt.xvec)
    xaxis = SwatheOpt.xvec(:)';
else
    xaxis = 1:nobs;
end
if SwatheOpt.swatheonly==0
    H.bar = plot(xaxis,bar,'LineWidth',SwatheOpt.linewidth,'Color',linecol,'Marker',SwatheOpt.marker);
end

% Hold axes so subsequent patches and lines are added to the same chart
holdStatus = ishold;
if ~holdStatus, hold on, end

% Build and draw the shaded patch; remove NaNs first (patch requires finite data)
yP = [low,fliplr(upp)];
xP = [xaxis,fliplr(xaxis)];
xP(isnan(yP)) = [];
yP(isnan(yP)) = [];
H.patch = patch(xP,yP,1,'facecolor',patchColor,'edgecolor','none','facealpha',faceAlpha);

% Draw lines at the swathe borders: styled lines when border=1, thin solid
% lines in a lightened color when border=0.
% When border=1, bordercol uses the raw option value (may be a string or RGB);
% when border=0, edgeColor (a resolved RGB triplet) is used instead.
if SwatheOpt.border == 1
    bordercol = SwatheOpt.swathecol;
    H.swathe(1) = plot(xaxis,low,SwatheOpt.borderstyle,'Color',bordercol,'LineWidth',1);
    H.swathe(2) = plot(xaxis,upp,SwatheOpt.borderstyle,'Color',bordercol,'LineWidth',1);
else
    H.swathe(1) = plot(xaxis,low,'-','Color',edgeColor);
    H.swathe(2) = plot(xaxis,upp,'-','Color',edgeColor);
end

% Re-draw the bar on top so it is not obscured by the patch
if SwatheOpt.swatheonly==0
    delete(H.bar)
    H.bar = plot(xaxis,bar,'LineWidth',SwatheOpt.linewidth,'Color',linecol,'Marker',SwatheOpt.marker);
end
if ~holdStatus, hold off, end

% Add date labels to the x-axis if requested; fo and nticks must be set
if SwatheOpt.do_dates==1
    if isempty(SwatheOpt.fo) || isempty(SwatheOpt.nticks)
        error('PlotSwathe: SwatheOpt.fo and SwatheOpt.nticks must be set when do_dates=1')
    end
    DatesPlot(SwatheOpt.fo,nobs,SwatheOpt.nticks,SwatheOpt.frequency)
end
H.ax = gca;

% Apply the dual-axis panel style unless disabled. SetAxesDual locks the
% y-limits: when several swathes are stacked on one axis the limits freeze
% to the first one drawn, so draw the widest band first, or re-lock the full
% range afterwards with SetAxesDual(gca,yl). Missing field defaults to on.
if ~isfield(SwatheOpt,'dualaxis') || SwatheOpt.dualaxis
    SetAxesDual(gca);
end
