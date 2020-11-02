function SwatheOpt = PlotSwatheOption
%==========================================================================
% Optional inputs for VAR analysis. This function is run automatically in
% the VARmodel function.
%==========================================================================
% VARopt = VARoption
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa Bianchi, March 2020
% ambrogio.cesabianchi@gmail.com

%% INITIALIZE VARIABLES
SwatheOpt.col = rgb('dark grey');
SwatheOpt.transp = '';
SwatheOpt.do_dates=0;
SwatheOpt.frequency = 'q';
SwatheOpt.swatheonly = 0;
SwatheOpt.marker = 'none';
