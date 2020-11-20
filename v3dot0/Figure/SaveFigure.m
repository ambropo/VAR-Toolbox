function SaveFigure(path,quality,type)
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
%   - type: pdf, png, eps [dflt=pdf], string
% =======================================================================
% Ambrogio Cesa Bianchi, April 2015
% ambrogio.cesabianchi@gmail.com

if ~exist('quality','var')
    quality=0;
end
if ~exist('type','var')
    type='pdf';
end

if quality 
    set(gcf, 'Color', 'w');
    export_fig(path,['-' type],'-painters')
%     export_fig(path,'-png','-painters')
else
    print(['-d' type],'-r100',path)
    print(['-d' type],'-r100',path)
    print(['-d' type],'-r100',path)
end