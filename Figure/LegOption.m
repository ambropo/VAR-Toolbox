function opt = LegOption
% =======================================================================
% Creates a default options structure for LegPlot and LegSubplot
% =======================================================================
% opt = LegOption
% -----------------------------------------------------------------------
% OUTPUT
%   - opt.hsize      : horizontal width of the legend box [dflt = 0.01]
%   - opt.vsize      : vertical position of the legend box in normalised
%                      figure units (0=bottom of figure, 1=top of figure,
%                      0.5=middle of figure, not middle of plot area) [dflt = 0.01]
%   - opt.handle     : graphics handles to include; [] means use all [dflt = []]
%   - opt.interpreter: text interpreter for legend labels [dflt = 'tex']
%   - opt.direction  : 1 = horizontal legend, 0 = vertical [dflt = 1]
% -----------------------------------------------------------------------
% EXAMPLE
%   plot(1:10);
%   opt = LegOption; opt.interpreter = 'tex'; opt.hsize = 0.4;
%   LegPlot({'Plot of \alpha'},opt)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. SET DEFAULTS
% -----------------------------------------------------------------------
% Populate all fields with their default values. These are passed to
% LegPlot or LegSubplot and can be overridden before calling either.
opt.hsize        = 0.01;
opt.vsize        = 0.01;
opt.handle       = [];
opt.interpreter  = 'tex';
opt.direction    = 1;
