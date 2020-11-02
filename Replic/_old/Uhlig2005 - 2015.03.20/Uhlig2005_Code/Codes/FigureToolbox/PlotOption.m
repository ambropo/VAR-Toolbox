function opt = PlotOption
% =======================================================================
% Optional inputs for LinePlot
% =======================================================================
%   - opt.row          = default 3, number of rows for subplot
%   - opt.col          = default 4, number of columns for subplot
%   - opt.vnames       = default {}, names of each plot
%   - opt.timeline     = a cell array of the type 1999Q1. Default []. You 
%                        can make one with MakeDate
%   - opt.PanelName    = default {}
%   - opt.FigTitle     = default {}. If specified, applies a suptitle
%   - opt.FigName      = default 'FIG'
%   - opt.do_x         = default 1, plot the xaxis. If 0 does not plot
%   - opt.interpr      = default 'None'. Underscore is treated as 
%                        underscore. Change to 'Tex' if needed 
%   - opt.fontsize     = default 11
%   - opt.fontname     = default Palatino
%   - opt.NumTicks     = default 5
%   - opt.pixel        = '-r250';
%   - opt.x_label      = [];
%   - opt.y_label      = [];
%   - opt.LineWidth    = [2  1  1  1];
%   - opt.LineStyle    = {'-', '-', '-', ':'};
%   - opt.LineColor    = {'dark blue'; 'very light blue'; 'dark grey'; 'grey'};
%   - opt.bins         = default 40. Bins for histograms
%   - opt.FaceColor    = bars color in hist fit. Default  = [0.0 1.0 0.0]
%   - opt.EdgeColor    = bars border color in hist fit. Default  = [1.0 1.0 1.0]
%   - opt.YearLabel    = 'short' for 99, 'long' for 1999
%   - opt.QuarterLabel = 'no';
%   - opt.compare      = default 0. Change to 1 to make the comparison 
%   - opt.grid         = default 0. Change to 1 to plot the grid
%   - opt.tight        = default 0. Change to 1 to make tight y axis
%   - opt.PlotNaN      = default 0. Change to 1 to plot missing series
% =========================================================================
% Ambrogio Cesa Bianchi, August 2011opt.tight        = default 0.
% ambrogio.cesabianchi@gmail.com


opt.row          = 3;
opt.col          = 4;
opt.vnames = {};
opt.timeline     = {};
opt.PanelName    = {};
opt.FigTitle     = {};
opt.FigName      = 'FIG';
opt.do_x         = 1;
opt.interpr      = 'None';
opt.fontsize     = 11;
opt.fontname     = 'Palatino';
opt.NumTicks     = 5;
opt.pixel        = '-r250';
opt.x_label      = {};
opt.y_label      = {};
opt.LineWidth    = [2  1  1  1];  
opt.LineStyle    = {'-', '-', '-', ':'};
opt.LineColor    = {'dark blue'; 'very light blue'; 'dark grey'; 'grey'};
opt.bins         = 40;
opt.FaceColor    = [0.0 1.0 0.0];
opt.EdgeColor    = [1.0 1.0 1.0];
opt.YearLabel    = 'short';
opt.QuarterLabel = 'no';
opt.compare      = 0;
opt.grid         = 0;
opt.tight        = 0;
opt.PlotNaN      = 0;