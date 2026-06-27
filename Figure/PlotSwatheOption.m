function SwatheOpt = PlotSwatheOption
% =======================================================================
% Default options structure for PlotSwathe
% =======================================================================
% SwatheOpt = PlotSwatheOption
% -----------------------------------------------------------------------
% OUTPUT
%   - SwatheOpt: options structure with fields controlling colors, line
%                style, transparency, border lines, date axis, and the
%                custom x-axis vector for PlotSwathe
% -----------------------------------------------------------------------
% EXAMPLE
%   SwatheOpt = PlotSwatheOption; SwatheOpt.linewidth = 3;
%   x = 3*(1:50); PlotSwathe(x,[1*(1:50); 4*(1:50)],SwatheOpt)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. SET DEFAULTS
% -----------------------------------------------------------------------
% Populate every field with a default value. Fields controlling colors
% use pre-defined RGB triplets; all other fields use numeric or string
% scalars. Override individual fields after calling PlotSwatheOption.
SwatheOpt.swathecol  = [138, 178, 212]./255; % swathe fill color (light blue)
SwatheOpt.linecol    = [13, 54, 84]./255;    % central line color (dark blue)
SwatheOpt.do_dates   = 0;                    % 1 to add date labels on x-axis
SwatheOpt.fo         = [];                   % first observation date (for do_dates=1)
SwatheOpt.nticks     = [];                   % number of axis ticks (for do_dates=1)
SwatheOpt.frequency  = 'q';                  % date frequency ('q','m','y')
SwatheOpt.swatheonly = 0;                    % 1 to suppress the central line
SwatheOpt.linewidth  = 2;                    % width of the central line
SwatheOpt.marker     = 'none';               % marker for the central line
SwatheOpt.transp     = 0;                    % 1 to use transparency on the patch
SwatheOpt.alpha      = 1;                    % alpha value for transparent patches
SwatheOpt.border      = 0;                    % 1 to draw lines at swathe borders
SwatheOpt.borderstyle = '--';                 % line style for border lines (only used when border=1)
SwatheOpt.xvec        = [];                  % custom x-axis vector; [] uses 1:nobs
SwatheOpt.dualaxis    = 1;                    % 1 = dual-axis panel style (ticks mirrored
                                              % on both y-axes, box off, closure tick); 0 = off.
                                              % SetAxesDual locks the y-limits, so when several
                                              % swathes are stacked on one axis the limits freeze
                                              % to the first one drawn; draw the widest band first,
                                              % or re-lock the full range afterwards with
                                              % SetAxesDual(gca,yl).
