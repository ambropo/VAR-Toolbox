function [h, f1, f2] = PlotStatesShaded(Time,qS,LW,color,transparency,onlyswathe,dualaxis)
% =======================================================================
% Plot a shaded fan chart with an optional median line. When qS has
% multiple columns the outer band uses columns 1 and 5, the inner band
% uses columns 2 and 4, and the median line uses column 3. When qS has
% a single column only the line is drawn.
% =======================================================================
% [h, f1, f2] = PlotStatesShaded(Time,qS,LW,color,transparency,onlyswathe)
% -----------------------------------------------------------------------
% INPUT
%   - Time: time index or date vector [T x 1]
%   - qS  : quantile or series matrix, one column (line) or five columns
%           [lower outer, lower inner, median, upper inner, upper outer]
%           [T x 1] or [T x 5]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - LW          : line width for the median line [dflt = 1]
%   - color       : RGB color for the shading [1 x 3] [dflt = [0.8 0.8 0.8]]
%   - transparency: alpha transparency for the fills [dflt = 0.5]
%   - onlyswathe  : 1 to suppress the median line [dflt = 0]
%   - dualaxis    : 1 to apply the dual-axis panel style [dflt = 1]
% -----------------------------------------------------------------------
% OUTPUT
%   - h : handle to the median line ([] when onlyswathe=1 or qS is single-col)
%   - f1: handle to the inner shaded fill ([] for single-column qS)
%   - f2: handle to the outer shaded fill ([] for single-column qS)
% -----------------------------------------------------------------------
% EXAMPLE
%   T = 40; Time = (1:T)';
%   qS = [randn(T,1)-2, randn(T,1)-1, randn(T,1), randn(T,1)+1, randn(T,1)+2];
%   figure; [h,f1,f2] = PlotStatesShaded(Time,qS,2,[0.6 0.8 1],0.4,0)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: November 2024. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Set defaults for all optional arguments, working from last to first so
% that partial trailing-argument calls are handled correctly.
if ~exist('dualaxis','var')
    dualaxis = 1;
end
if ~exist('onlyswathe','var')
    onlyswathe = 0;
end
if nargin < 5
    transparency = 0.5;
end
if nargin < 3
    % Only Time and qS supplied: use all defaults
    color     = [0.8 0.8 0.8];
    LW        = 1;
    linecolor = 'k';
elseif nargin < 4
    % LW supplied but color not: use default color
    color     = [0.8 0.8 0.8];
    linecolor = 'k';
else
    % LW and color both supplied: darken color slightly for the median line
    % so it stands out from the shaded bands
    linecolor = color * 0.65;
end

%% 2. DRAW SHADED BANDS AND MEDIAN LINE
% -----------------------------------------------------------------------
% Colors: 0.75*color (outer band) is lighter; 0.5*color (inner band) is
% darker. Scaling the RGB triplet toward zero darkens it, creating visual
% depth. Columns of qS: [lower outer, lower inner, median, upper inner,
% upper outer].

% Save hold state so the caller's hold setting is not altered on return
holdStatus = ishold;
hold on

if size(qS, 2) > 1
    % Outer band spans columns 1 and 5
    f2 = fill([Time; flip(Time)], [qS(:,1); flip(qS(:,5))], ...
              0.75*color, 'LineStyle','none', 'FaceAlpha',transparency);
    % Inner band spans columns 2 and 4
    f1 = fill([Time; flip(Time)], [qS(:,2); flip(qS(:,4))], ...
              0.5*color, 'LineStyle','none', 'FaceAlpha',transparency);
    if ~onlyswathe
        h = plot(Time, qS(:,3), '-', 'Color',linecolor, 'LineWidth',LW);
    else
        h = [];
    end
else
    % Single-column input: draw the series as a line only
    h  = plot(Time, qS(:,1), '-', 'Color',linecolor, 'LineWidth',LW);
    f1 = [];
    f2 = [];
end

% Zero reference line (Time*0 constructs a zero vector the same length as Time)
plot(Time, Time*0, 'k', 'LineWidth',0.25)

%% 3. STYLE
% -----------------------------------------------------------------------
% Apply dual-axis style and font settings consistent with VARirplot
set(gca, 'FontSize',12, 'Layer','bottom')
if dualaxis; SetAxesDual(gca); end
set(gcf, 'Color','w')

% Restore the caller's hold state
if ~holdStatus; hold off; end
