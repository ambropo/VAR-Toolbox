function SaveFigure(path,quality)
% =======================================================================
% Saves figure to specified path 
% =======================================================================
% SaveFig(path,quality)
% -----------------------------------------------------------------------
% INPUT
%   - path: path wehere to save the file
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - quality: 0 standard, 1 high quality [dflt=0]
% =======================================================================
% Ambrogio Cesa Bianchi, April 2015
% ambrogio.cesabianchi@gmail.com

if ~exist('quality','var')
    quality=0;
end

if quality 
    set(gcf, 'Color', 'w');
    export_fig(path,'-pdf','-png','-painters')
else
    print('-dpng','-r100',path)
    print('-deps','-r100',path)
    print('-dpdf','-r100',path)
end