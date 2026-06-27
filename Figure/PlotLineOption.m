function opt = PlotLineOption
% =======================================================================
% Default options structure for PlotLine
% =======================================================================
% opt = PlotLineOption
% -----------------------------------------------------------------------
% OUTPUT
%   - opt: options structure with the fields listed below
% -----------------------------------------------------------------------
% EXAMPLE
%   opt = PlotLineOption;
%   opt.row = 2; opt.col = 3;
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. SET DEFAULTS
% -----------------------------------------------------------------------
opt.row          = 3;                       % rows for subplot
opt.col          = 4;                       % columns for subplot
opt.fo           = [];                      % first observation (1989Q2 => 1989.25)
opt.frequency    = 'q';                     % frequency 'q' quarterly, 'y' annual
opt.nticks       = 5;                       % number of ticks on x axis
opt.ynames       = {};                      % variable names in DATA(nobs,y,z)
opt.znames       = {};                      % variable names in DATA(nobs,y,z)
opt.do_x         = 1;                       % plot x axis
opt.LineWidth    = [3  1  1  1];            % line width
opt.LineStyle    = {'-', '--', '-', ':'};   % line style
opt.LineColor    = {'slightly dark red';... % line color
                    'slightly light blue';...
                    'dark grey'; 'grey'};
opt.grid         = 0;                       % plot grid
opt.box          = 0;                       % plot box
opt.dualaxis     = 1;                       % 1 = dual-axis panel style (ticks
                                            % mirrored on both y-axes, box off,
                                            % closure tick); 0 = off. Each panel
                                            % holds a single PlotLine call, so it
                                            % is styled once (see SetAxesDual).
opt.fontsize     = 11;                      % font size for charts
opt.x_label      = {};                      % label x axis
opt.y_label      = {};                      % label y axis
opt.compare      = 0;                       % set to 1 to compare panels
opt.savename     = 'FIG';                   % figure file name
opt.quality      = 0;                       % set to 1 for high quality export
