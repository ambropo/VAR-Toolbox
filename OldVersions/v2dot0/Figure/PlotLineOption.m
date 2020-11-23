function opt = PlotLineOption
% =======================================================================
% Optional inputs for PlotLine
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

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
opt.interpr      = 'None';                  % Change to Latex if needed
opt.fontsize     = 11;                      % font size for charts
opt.x_label      = {};                      % label x axis 
opt.y_label      = {};                      % label y axis 
opt.compare      = 0;                       % set to 1 to compare panels
opt.savename     = 'FIG';                   % figname
opt.quality      = 0;                       % set to 1 for high quality
opt.bins         = 40;                      % number of bins for HistfitPlot
