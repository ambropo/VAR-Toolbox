function opt = LegOption
% =======================================================================
% Creates structure of inputs for LegPlot or LegSubplot
% =======================================================================
% opt = LegOption
% -----------------------------------------------------------------------
% OUTPUT
%   - opt.hsize : default 0.01, horizontal size of the box of the legend
%   - opt.vsize : default 0.01, vertical position of the box of the legend
%           (0=bottom, 0.5=middle)
%   - opt.handle : default [], no handle specified 
%   - opt.interpreter : default 'Tex', otherwise chamge to 'none'
%   - opt.direction : default 1, horizontal legend
% -----------------------------------------------------------------------
% EXAMPLE
%   plot(1:10); 
%   opt = LegOption; opt.interpreter = 'Tex'; opt.hsize = 0.4
%   legpos = LegPlot({'Plot of \alpha'},opt)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------

opt.hsize        = 0.01;
opt.vsize        = 0.01;
opt.handle       = [];
opt.interpreter  = 'Tex';
opt.direction    = 1;