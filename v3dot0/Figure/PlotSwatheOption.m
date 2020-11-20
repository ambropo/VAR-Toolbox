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
%color = bone(8);
SwatheOpt.swathecol  = [138, 178, 212]./255; % color(6,:);
SwatheOpt.barcol     = [13, 54, 84]./255;    % color(1,:);
SwatheOpt.do_dates   = 0;
SwatheOpt.frequency  = 'q';
SwatheOpt.swatheonly = 0;
SwatheOpt.marker     = 'none';
SwatheOpt.transp     = 0;           % Allow for transparency when plotting multiple swathes
SwatheOpt.alpha      = 1;           % Sets alpha for transparent swathes. Default is 1

