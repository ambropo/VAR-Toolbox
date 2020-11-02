function FigFont(font_size,font_small,font)
% =======================================================================
% Set to desired font_size and style the font of a chart. Title is bold, legend
% and axes are font_size-3.
% =======================================================================
% FigFont(font_size,font)
% -----------------------------------------------------------------------
% INPUT
%   font_size : font_size of the font
%   font : style of the font (default: times)
% =======================================================================
% Ambrogio Cesa Bianchi, February 2012
% ambrogio.cesabianchi@gmail.com


if ~exist('font_small','var')
    font_small = font_size - 3;
end

if ~exist('font','var')
    font = 'Palatino';
end

a = findobj(gcf,'Type','axes');
set(a, 'Fontsize', font_small, 'FontWeight', 'light','FontName',font);

if max(size(a))==1
    aux = get(a, 'title');
    set(aux, 'Fontsize', font_size, 'FontWeight', 'light', 'FontName',font);
else
    aux = get(a(1), 'title');
    set(aux, 'Fontsize', font_size, 'FontWeight', 'light', 'FontName',font);
    aux = get(a(2), 'title');
    set(aux, 'Fontsize', font_size, 'FontWeight', 'light', 'FontName',font);
    
end

aux = findobj(gcf,'Type','axes','Tag','legend');
set(aux, 'Fontsize', font_small, 'FontName',font);

aux = get(gca,'YLabel');
if isempty(aux)~=1
    set(aux, 'Fontsize', font_small, 'FontWeight', 'light', 'FontName',font);
end

aux = get(gca,'XLabel');
if isempty(aux)~=1
    set(aux, 'Fontsize', font_small, 'FontWeight', 'light', 'FontName',font);
end