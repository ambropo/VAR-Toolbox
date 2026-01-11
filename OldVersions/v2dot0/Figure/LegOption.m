function opt = LegOption
% =======================================================================
% Optional inputs for SubLegendOption
% =======================================================================
%   - opt.hsize          = default 0.01, horizontal size of the box of the 
%                          legend
%   - opt.vsize          = default 0.01, vertical position of the box of 
%                          the legend (0=bottom, 0.5=middle)
%   - opt.handle         = default [], no handle specified 
%   - opt.interpreter    = default 'Tex',
%   - opt.direction      = default 0, horizontal legend
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

opt.hsize        = 0.01;
opt.vsize        = 0.01;
opt.handle       = [];
opt.interpreter  = 'Tex';
opt.direction    = 1;