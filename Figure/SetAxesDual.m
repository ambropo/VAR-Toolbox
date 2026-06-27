function SetAxesDual(ax, yl)
% =======================================================================
% Apply dual-axis panel style: box off, tick marks and labels on both
% left and right y-axes, inward ticks, slightly thicker axis lines,
% and a visual closure tick at YLim(2) that is 2x the standard length.
% =======================================================================
% SetAxesDual(ax, yl)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - ax: axes handle to style [dflt = gca]
%   - yl: explicit y-limit [lo hi] to lock both rulers to [dflt = current
%         axis limits]. Supply this when several layers are drawn on one
%         axis (e.g. stacked PlotSwathe calls) so the locked range covers
%         all layers rather than only the first one drawn. When omitted,
%         the function reads the axis's current (auto or user-set) limits.
% -----------------------------------------------------------------------
% NOTES
%   Reads the left ruler's Limits (the user-set ylim) before creating the
%   right ruler, then locks both rulers to identical Limits/TickValues/
%   TickLabels via direct property assignment (ax.YAxis(n).*). Direct
%   assignment is used throughout — not the ylim/yticks/yticklabels
%   convenience functions — to avoid active-ruler routing ambiguity that
%   can silently apply values to the wrong ruler.
%   The left ruler is locked (explicit TickValues + Limits) before yyaxis
%   switches context; this prevents MATLAB from re-auto-ticking the left
%   ruler when the right ruler is first created.
%   Both rulers are locked a second time after switching back to the left,
%   because the switch can trigger a re-auto-tick in some MATLAB configs.
%   Special case: if the top tick is exactly 0 and the range spans negative
%   values and the user has not already set YLim(2) above 0, YLim(2) is
%   nudged to 0.2 x tick_spacing so a zero-reference line at y=0 does not
%   merge with the closure tick drawn at YLim(2).
%   The closure tick at YLim(2) is drawn as a line() only — it is NOT
%   added to TickValues, which would create an unwanted extra gridline.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. INITIALISE AND CAPTURE LEFT AXIS STATE
% -----------------------------------------------------------------------
% Default to gca when no axes handle is supplied. Flush pending renders
% so MATLAB finalises auto-tick values before capture; then read the
% left axis state (limits, ticks, labels) before any ruler manipulation.
if nargin < 1 || isempty(ax); ax = gca; end

% An explicit y-limit overrides the captured limits below
userYL = (nargin >= 2) && ~isempty(yl);

% Set line width and save the tick-label interpreter so it can be
% restored after yyaxis switches active ruler
lw  = 1.0;
tli = ax.TickLabelInterpreter;

% If an explicit y-limit is supplied, apply it before the render flush so
% MATLAB recomputes the tick values for the requested range
if userYL
    ylim(ax, yl);
end

% Flush pending renders so MATLAB finalises auto-tick values before capture
drawnow('nocallbacks');

% Capture left-axis state before any ruler manipulation.
% yl is read from Limits (the user-set ylim, or the explicit limit applied
% above), not derived from tick bounds, so that an explicit ylim is honoured.
yl     = ax.YAxis(1).Limits;
ytk_L  = ax.YAxis(1).TickValues;
ytkl_L = ax.YAxis(1).TickLabels;

% Special case: top tick exactly 0 with negative range and no positive
% headroom — nudge YLim(2) so the zero-reference line at y=0 does not
% merge visually with the closure tick drawn at YLim(2). Skipped when the
% caller supplied an explicit y-limit, which is taken as authoritative.
if ~userYL && ~isempty(ytk_L) && ytk_L(end) == 0 && ytk_L(1) < 0 ...
        && numel(ytk_L) >= 2 && yl(2) <= 0
    yl(2) = 0.2 * (ytk_L(end) - ytk_L(end-1));
end

%% 2. LOCK LEFT RULER
% -----------------------------------------------------------------------
% Explicit TickValues/TickLabels/Limits prevent MATLAB from re-auto-ticking
% the left ruler when yyaxis switches context below.
ax.YAxis(1).Limits        = yl;
ax.YAxis(1).TickValues    = ytk_L;
ax.YAxis(1).TickLabels    = ytkl_L;
ax.YAxis(1).LineWidth     = lw;
ax.YAxis(1).TickDirection = 'in';

%% 3. CONFIGURE RIGHT RULER
% -----------------------------------------------------------------------
% Create the right ruler via yyaxis, then configure it via direct property
% assignment on ax.YAxis(2). Direct assignment avoids active-ruler routing
% (ylim/yticks/yticklabels route to whichever ruler is currently active,
% which is fragile); writing to ax.YAxis(2) is unambiguous regardless of
% which ruler yyaxis has made active.
yyaxis(ax, 'right');
ax.YAxis(2).Limits        = yl;
ax.YAxis(2).TickValues    = ytk_L;
ax.YAxis(2).TickLabels    = ytkl_L;
ax.YAxis(2).Color         = ax.YAxis(1).Color;
ax.YAxis(2).LineWidth     = lw;
ax.YAxis(2).TickDirection = 'in';

%% 4. RESTORE AND RE-LOCK BOTH RULERS
% -----------------------------------------------------------------------
% Switch back to left and restore interpreter
yyaxis(ax, 'left');
ax.TickLabelInterpreter = tli;

% Re-lock both rulers after the switch: switching rulers can trigger a
% re-auto-tick on either ruler in some MATLAB configurations
ax.YAxis(1).Limits     = yl;
ax.YAxis(1).TickValues = ytk_L;
ax.YAxis(1).TickLabels = ytkl_L;
ax.YAxis(2).Limits     = yl;
ax.YAxis(2).TickValues = ytk_L;
ax.YAxis(2).TickLabels = ytkl_L;

%% 5. AXES-LEVEL FORMATTING
% -----------------------------------------------------------------------
ax.LineWidth = lw;
ax.Box       = 'off';

%% 6. DRAW CLOSURE TICK
% -----------------------------------------------------------------------
% Drawn as line() at YLim(2); NOT added to TickValues (would create an
% unwanted extra gridline near the top). Tick length is computed from
% pixel dimensions so the mark is visually 2× the standard tick length
% regardless of figure aspect ratio.
% Read current axis limits after any YLim nudge applied above
yl = ax.YLim;
xl = ax.XLim;

% Retrieve figure position in pixels to convert normalised tick-length
% fractions into data-coordinate distances for drawing the closure tick
fig       = ancestor(ax, 'figure');
old_units = get(fig, 'Units');
set(fig, 'Units', 'pixels');
fig_px    = get(fig, 'Position');
set(fig, 'Units', old_units);

% Tick-length conversion: ax.TickLength(1) is a normalised fraction of the
% longer axis dimension (max(width, height) in pixels). Multiplying by
% max(ax_w_px, ax_h_px) converts to pixels; then scaling by diff(xl)/ax_w_px
% converts from horizontal-pixel units to x-data units so the line() call
% below can be placed in data coordinates. The closure tick is drawn at 2×
% the standard tick length.
ax_w_px    = ax.Position(3) * fig_px(3);
ax_h_px    = ax.Position(4) * fig_px(4);
std_tick_x = ax.TickLength(1) * max(ax_w_px, ax_h_px) * diff(xl) / ax_w_px;
tk_long    = 2.0 * std_tick_x;

% Draw two short line segments at YLim(2) — one from each side of the
% x-axis — to form the closure tick at the top of both y-rulers
lcolor = ax.YAxis(1).Color;
line(ax, [xl(1),         xl(1)+tk_long], [yl(2), yl(2)], ...
     'Color', lcolor, 'LineWidth', lw, 'HandleVisibility', 'off', 'Clipping', 'off');
line(ax, [xl(2)-tk_long, xl(2)        ], [yl(2), yl(2)], ...
     'Color', lcolor, 'LineWidth', lw, 'HandleVisibility', 'off', 'Clipping', 'off');

%% 7. TITLE SPACING
% -----------------------------------------------------------------------
% Add a small fixed gap between the panel and its title, applied here (the
% last styling step) so it survives the yyaxis switches above — those reset
% the title to its default position. Applied to every panel styled by this
% function so all toolbox figures share the same title spacing. TitlePad
% sets the position absolutely (idempotent), and is a no-op on empty titles.
th = get(ax, 'Title');
if ~isempty(th) && ~isempty(get(th, 'String'))
    TitlePad(th, 2);
end
