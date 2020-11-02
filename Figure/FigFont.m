function FigFont(fsize)
% =======================================================================
% Set font in a figure to desired font size
% =======================================================================
% FigFont(fsize)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% CHECK INPUT
%==========================================================================
if ~exist('fsize','var')
    error('Please enter a font size');
end


%% SET FONT STYLE 
%==========================================================================
% AXES
aux = findobj(gcf,'Type','axes');
set(aux,'Fontsize',fsize,'FontWeight','Light','FontName','Helvetica');
