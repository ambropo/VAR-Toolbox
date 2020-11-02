function FigSize(x,y)
% =======================================================================
% The default size of an image is 560x420 pixels, which implies a ratio of 
% 1.33. This function set a new size in cm. Notice that the normal page in
% the US is 21,6 × 27,9 cm and margins in a latex document are normally 2.5
% cm or more. A figure spanning all horizontal space is therefore about 16
% cm wide
% =======================================================================
% FigSize(x,y)
% -----------------------------------------------------------------------
% INPUT
%   x: factor on x dimension
%   y: factor on y dimension
% =======================================================================
% Ambrogio Cesa Bianchi, February 2012
% ambrogio.cesabianchi@gmail.com


% Get the position of the figure 
% [left bottom width height] [standard in px: 403 246   560   420]
position = get(gcf, 'Position');

% Place the figure on the south west corner of the screen (in cm)
position(1) = 1; 
position(2) = 2; 

% x dimension in cm
if exist('x','var')
    position(3) = x;
end

% y dimension in cm
if exist ('y','var')
    position(4) = y;
end

% Apply rescaling
set(gcf, 'units', 'centimeters', 'Position', position)