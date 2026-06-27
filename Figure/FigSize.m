function FigSize(xdim,ydim)
% =======================================================================
% Set the figure window to a desired size in centimetres. With no
% arguments, maximises the window to near full-screen.
% =======================================================================
% FigSize(xdim,ydim)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - xdim: horizontal size in cm [double]
%   - ydim: vertical size in cm [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   FigSize(12,6)
%   plot(1:10)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. SET FIGURE SIZE
% -----------------------------------------------------------------------
if nargin==0
    % No arguments: expand to near full-screen using normalised units.
    % [left bottom width height] in normalised figure coords:
    %   left=0, bottom=0.1 (leave taskbar room), width=1, height=0.9
    figure('units','normalized','outerposition',[0 0.1 1 0.9])
else
    % Retrieve the current figure position [left bottom width height]
    % Default MATLAB position in pixels: [403 246 560 420]
    position = get(gcf, 'Position');

    % Anchor the figure to the lower-left corner of the screen (in cm):
    % position(1) = 1 cm from the left edge; position(2) = 2 cm from the bottom
    position(1) = 1;
    position(2) = 2;

    % Override width and height if arguments are supplied
    if nargin >= 1
        position(3) = xdim;
    end
    if nargin >= 2
        position(4) = ydim;
    end

    % Apply the new position in centimetre units
    set(gcf, 'units', 'centimeters', 'Position', position)
end
