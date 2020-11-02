function HistPlot(DATA,names,opt)
% =======================================================================
% Plots an histogram of DATA(i,j), where "i" is the number of observations,
% "j" are the variables. Adds to the histogram a fit of the distribution
% =======================================================================
% histplot(DATA,names,opt)
% -----------------------------------------------------------------------
% INPUTS 
%	- DATA    : matrix DATA(i,j)
%   - names   : cell [1xj], names of the variables
%
% OPTIONAL INPUTS
%   - opt:    : see PlotOption
% =========================================================================
% Ambrogio Cesa Bianchi, August 2011
% ambrogio.cesabianchi@gmail.com


% Preliminaries: define the dimension of the data vector DATA
[nobs, nvars] = size(DATA);


%% CHECK INPUTS
%--------------------------------------------------------------------------


% If the are no names, stop the procedure
if nargin<2
    disp(' ');
    disp('Error: you have to specify a cell array for the series names!' )
    disp(' ');
    return
end

% If no option create default
if ~exist('opt','var')
    opt = PlotOption;
end

% If not specified, suptitle is not plotted
if isempty(opt.FigTitle)
    do_suptitle = 0;      
else
    do_suptitle = 1;
end




%% PLOT
%--------------------------------------------------------------------------

nfigures = NumTotFigures(opt.row,opt.col,nvars);

% Store in is_empty the NaN column in the plot matrices
is_empty = isnan(DATA(:,:));

% Plot
jj=1;
for nn=1:nfigures;
    for kk=1:opt.row*opt.col;
        if jj>nvars % to solve if I put more opt.row*opt.col 
            subplot(opt.row,opt.col,kk)
            x = [0:1:nobs-1]';
            plot(x,'LineStyle','none')
            axis off
        else
            if is_empty(1,jj)==1
                jj=jj+1;
            else
                subplot(opt.row,opt.col, kk);
                hist(DATA(:,jj),opt.bins);
                h = findobj(gca,'Type','patch');
                set(h,'FaceColor',opt.FaceColor)
                
                title(char(names(jj)),'FontSize',opt.font1,'Interpreter',opt.interpr)
                
                set(gca,'FontSize',opt.font2)
                set(gca, 'Box','on')
                
                x_max = max(DATA(:,jj));
                x_min = min(DATA(:,jj));
                x_jump  = x_max - x_min;
                xlim( [x_min-0.05*x_jump x_max+0.05*x_jump] )
                
                xlabel(opt.x_label,'Fontsize',opt.font2)
                ylabel(opt.y_label,'Fontsize',opt.font2)
            
                jj=jj+1;
            end
        end
    end

    % insert the super title
    if do_suptitle==1;
        suptitle(char(opt.FigTitle));
    end

    % if more than one image per country, start enumerating
    if nfigures > 1
        aux_FigName = [opt.FigName num2str(nn)];
    else
        aux_FigName = opt.FigName;
    end

    % Save
    set(gcf, 'Color', 'w');
    export_fig(aux_FigName,'-pdf','-png','-painters')
    clf('reset');

end

close all