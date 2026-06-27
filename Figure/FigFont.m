function FigFont(fsize)
% =======================================================================
% Set the font size of all axes in the current figure
% =======================================================================
% FigFont(fsize)
% -----------------------------------------------------------------------
% INPUT
%   - fsize: desired font size [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   plot(1:10); title('A line plot')
%   FigFont(16)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
if nargin < 1
    error('FigFont: please provide a font size as input argument');
end

%% 2. SET FONT STYLE
% -----------------------------------------------------------------------
% Apply font size, weight, and family to every axes object in the figure.
% 'Light' is not a standard MATLAB FontWeight value ('normal' and 'bold'
% are); behaviour is renderer-dependent and may silently fall back to
% 'normal' on some platforms.
aux = findobj(gcf,'Type','axes');
set(aux,'Fontsize',fsize,'FontWeight','Light','FontName','Helvetica');
