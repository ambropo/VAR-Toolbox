function FigFont(fsize)
% =======================================================================
% Set font in a figure to desired font size
% =======================================================================
% FigFont(fsize)
% -----------------------------------------------------------------------
% INPUT
%	- fsize : size of font (double)
% -----------------------------------------------------------------------
% EXAMPLE
%   plot(1:10); title('A line plot')
%   FigFont(16)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------



%% CHECK INPUT
if ~exist('fsize','var')
    error('Please enter a font size');
end


%% SET FONT STYLE 
% AXES
aux = findobj(gcf,'Type','axes');
set(aux,'Fontsize',fsize,'FontWeight','Light','FontName','Helvetica');
