function FigFont(opt)
% =======================================================================
% Set font in a figure to desired font size and font style
% =======================================================================
% FigFont(opt)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - opt: output of FigFontOption(fsize)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% CHECK INPUT
% =======================================================================
if ~exist('opt','var')
    opt = FigFontOption;
end


%% SET FONT STYLE 
% =======================================================================
% AXES
aux = findobj(gcf,'Type','axes');
set(aux,'Fontsize',opt.axes_size,'FontWeight',opt.axes_weight,'FontName',opt.axes_name);

% TITLES
if max(size(aux))==1
    aux = get(aux, 'title');
    set(aux,'Fontsize',opt.title_size,'FontWeight',opt.title_weight,'FontName',opt.title_name);
else
    aux1 = get(aux(1), 'title');
    set(aux1, 'Fontsize', opt.title_size,'FontWeight',opt.title_weight,'FontName',opt.title_name);
    aux2 = get(aux(2), 'title');
    set(aux2, 'Fontsize',opt.title_size,'FontWeight',opt.title_weight,'FontName',opt.title_name);
end

% SUPTITLE
aux = findobj(gcf,'tag','suptitleText');
set(aux,'Fontsize',opt.suptitle_size,'FontWeight',opt.suptitle_weight,'FontName',opt.suptitle_name);

% LEGEND
aux = findobj(gcf,'Type','axes','Tag','legend');
set(aux,'Fontsize',opt.legend_size, 'FontWeight',opt.legend_weight,'FontName',opt.legend_name);

% Y LABEL
aux = get(gca,'YLabel');
if isempty(aux)~=1
    set(aux,'Fontsize',opt.ylabel_size, 'FontWeight',opt.ylabel_weight,'FontName',opt.ylabel_name);
end

% X LABEL
aux = get(gca,'XLabel');
if isempty(aux)~=1
    set(aux,'Fontsize',opt.xlabel_size, 'FontWeight',opt.xlabel_weight,'FontName',opt.xlabel_name);
end