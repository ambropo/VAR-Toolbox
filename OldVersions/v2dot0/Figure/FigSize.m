function FigSize(xdim,ydim)
% =======================================================================
% Sets the figure window to a desired size. The default is full screen
% =======================================================================
% FigSize(xdim,ydim)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - xdim: horizontal size (in cm)
%   - ydim: vertical size (in cm)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

if nargin==0
    figure('units','normalized','outerposition',[0 0.1 1 0.9])
else
    % Get the position of the figure 
    % [left bottom width height] [standard in px: 403 246   560   420]
    position = get(gcf, 'Position');

    % Place the figure on the south west corner of the screen (in cm)
    position(1) = 1; 
    position(2) = 2; 

    % xdim dimension in cm
    if exist('xdim','var')
        position(3) = xdim;
    end

    % ydim dimension in cm
    if exist ('ydim','var')
        position(4) = ydim;
    end

    % Apply rescaling
    set(gcf, 'units', 'centimeters', 'Position', position)
end