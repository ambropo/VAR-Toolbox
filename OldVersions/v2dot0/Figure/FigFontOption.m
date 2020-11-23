function opt = FigFontOption(fsize)
% =======================================================================
% Inputs for FigFont
% =======================================================================
% OPTIONAL INPUT
%   - fsize: size of the font [default 12]
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% CHECK INPUT
% =======================================================================
if ~exist('fsize','var')
    fsize = 12;
end

%% SET OPTIONS
% =======================================================================
opt.fsize       = fsize;

opt.axes_size   = opt.fsize;
opt.axes_weight = 'light';
opt.axes_name   = 'Helvetica';

opt.title_size   = opt.fsize;
opt.title_weight = 'light';
opt.title_name   = 'Helvetica';

opt.suptitle_size   = opt.fsize+2;
opt.suptitle_weight = 'light';
opt.suptitle_name   = 'Helvetica';

opt.legend_size   = opt.fsize;
opt.legend_weight = 'light';
opt.legend_name   = 'Helvetica';

opt.ylabel_size   = opt.fsize;
opt.ylabel_weight = 'light';
opt.ylabel_name   = 'Helvetica';

opt.xlabel_size   = opt.fsize;
opt.xlabel_weight = 'light';
opt.xlabel_name   = 'Helvetica';