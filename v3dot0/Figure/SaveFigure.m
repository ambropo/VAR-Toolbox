function SaveFigure(path,quality,type)
% =======================================================================
% Saves figure to specified path 
% =======================================================================
% SaveFig(path,quality)
% -----------------------------------------------------------------------
% INPUT
%   - path: path wehere to save the file [char]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - quality: 0 standard, 1 Ghostscript, 2 exportgraphics [dflt=0] [double]
%   - type: pdf, png, eps [dflt=pdf] [char]
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------

% Check inputs
if ~exist('quality','var')
    quality=0;
end
if ~exist('type','var')
    type='pdf';
end

% file type
if quality==1
    set(gcf, 'Color', 'w');
    export_fig(path,['-' type],'-painters')
elseif quality==2
    exportgraphics(gcf,[path '.pdf'])
elseif quality==0
    print(['-d' type],'-r100',path)
    print(['-d' type],'-r100',path)
    print(['-d' type],'-r100',path)
end