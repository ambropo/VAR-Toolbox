function SaveFigure(path,quality,type)
% =======================================================================
% Save the current figure to a file at the specified path
% =======================================================================
% SaveFigure(path,quality,type)
% -----------------------------------------------------------------------
% INPUT
%   - path: file path (without extension for quality=0/1) [char]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - quality: 0 = standard print, 1 = Ghostscript via export_fig,
%              2 = MATLAB exportgraphics (R2020a+) [dflt = 2] [double]
%   - type   : file format string, e.g. 'pdf', 'png', 'eps' [dflt = 'pdf']
% -----------------------------------------------------------------------
% EXAMPLE
%   plot(1:10); SaveFigure('myfig')
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate required argument and apply defaults for optional arguments.
if ~exist('path','var') || isempty(path)
    error('SaveFigure: a file path must be provided as the first argument')
end
if ~exist('quality','var')
    quality = 2;
end
if ~exist('type','var')
    type = 'pdf';
end

%% 2. SAVE FIGURE
% -----------------------------------------------------------------------
% Dispatch to the appropriate save backend based on the quality flag.
if quality==0
    % Three identical calls work around a known MATLAB issue where a single
    % print() call can produce a blank or corrupted file on some platforms
    print(['-d' type], '-r100', path)
    print(['-d' type], '-r100', path)
    print(['-d' type], '-r100', path)
elseif quality==1
    % Ghostscript via export_fig (legacy path, not recommended)
    set(gcf, 'Color', 'w');
    export_fig(path, ['-' type], '-painters')
elseif quality==2
    % MATLAB built-in exportgraphics (requires R2020a or later)
    exportgraphics(gcf, [path '.' type])
end
