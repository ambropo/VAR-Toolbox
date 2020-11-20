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
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi, March 2015
% ambrogiocesabianchi@gmail.com
% -----------------------------------------------------------------------

% Check inputs
if ~exist('quality','var')
    quality=0;
end
if ~exist('type','var')
    type='pdf';
end

% file type
if quality 
    set(gcf, 'Color', 'w');
    export_fig(path,['-' type],'-painters')
else
    print(['-d' type],'-r100',path)
    print(['-d' type],'-r100',path)
    print(['-d' type],'-r100',path)
end