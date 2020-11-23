function SwatheOpt = PlotSwatheOption
% =======================================================================
% Optional inputs for PlotSwathe
% =======================================================================
% SwatheOpt = PlotSwatheOption
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------

%% INITIALIZE VARIABLES
%color = bone(8);
SwatheOpt.swathecol  = [138, 178, 212]./255; % color(6,:);
SwatheOpt.linecol    = [13, 54, 84]./255;    % color(1,:);
SwatheOpt.do_dates   = 0;
SwatheOpt.frequency  = 'q';
SwatheOpt.swatheonly = 0;
SwatheOpt.marker     = 'none';
SwatheOpt.transp     = 0;   % Allow for transparency when plotting multiple swathes
SwatheOpt.alpha      = 1;   % Sets alpha for transparent swathes. Default is 1

