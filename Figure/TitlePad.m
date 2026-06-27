function TitlePad(th, pad)
% =======================================================================
% Widen the gap between an axes title and its plot box by 'pad' points,
% WITHOUT moving the title higher on the page.
% =======================================================================
% TitlePad(th, pad)
% -----------------------------------------------------------------------
% INPUT
%   - th:  handle to a title text object (output of title(...))
%   - pad: extra gap in points [dflt = 2]
% -----------------------------------------------------------------------
% METHOD
%   The extra space is created by shrinking the axes from the TOP by 'pad'
%   points (lower the top edge, keep the bottom fixed) and then placing the
%   title 'pad' points above the new top — i.e. back at the ORIGINAL axes-
%   top level. Net effect: the panel-to-title gap grows by 'pad', but the
%   title's top never rises above where it sat before, so a tight crop
%   (exportgraphics / SaveFigure) cannot clip it any more than the original
%   un-padded figure. Pushing the title up instead (and leaving the axes
%   alone) clips the top-row titles against the figure edge.
%
%   The title is positioned EXPLICITLY in NORMALIZED units, not by reading
%   and shifting its auto-position: the auto-position is not computed until
%   render (reading it early returns a stale default), and normalized units
%   keep the title tracking the axes through later resizes. Position is set
%   absolutely, so repeated calls are idempotent.
% -----------------------------------------------------------------------
% CAVEAT
%   This changes the axes Position. A caller that later calls
%   subplot(r,c,k) for the SAME cell will not match the resized axes and
%   will create a new empty axes. Reuse the stored axes handle instead of
%   re-calling subplot (see VARvdplot / VARhdplot, which capture ax_panel).
% =======================================================================
% VAR Toolbox
% -----------------------------------------------------------------------

if nargin < 2 || isempty(pad); pad = 2; end

ax = ancestor(th, 'axes');

% Read the axes height in points and shrink the box from the top by 'pad'
old = get(ax, 'Units');
set(ax, 'Units', 'points');
p = get(ax, 'Position');
axHpt = p(4);
if axHpt <= pad; set(ax, 'Units', old); return; end   % too small to shrink
set(ax, 'Position', [p(1), p(2), p(3), axHpt - pad]);  % lower top edge by pad
set(ax, 'Units', old);

% New axes height; place the title 'pad' points above the new top, which is
% the original top level (no net upward movement of the title)
axHnew = axHpt - pad;
set(th, 'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'Position', [0.5, 1 + pad/axHnew, 0]);
