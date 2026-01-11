function HistfitPlot(DATA,names,opt)
% =======================================================================
% Plots an histogram of DATA(i,j), where "i" is the number of observations,
% "j" are the variables. Adds to the histogram a fit of the distribution
% =======================================================================
% histplot(DATA,names,row,col,FigTitle,FigName)
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
    opt = PlotLineOption;
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
                h = histfit(DATA(:,jj),opt.bins);
%                 set(h(2), 'Color', rgb(opt.LineColor), 'LineWidth',2)
%                 set(h(1), 'FaceColor', rgb(opt.FaceColor),'EdgeColor',rgb(opt.EdgeColor),'LineWidth',1.25)
                
                title(char(names(jj)));
                set(gca, 'Box','on')                
                x_max = max(DATA(:,jj));
                x_min = min(DATA(:,jj));
                x_jump  = x_max - x_min;
                xlim( [x_min-0.05*x_jump x_max+0.05*x_jump] )
                xlabel(opt.x_label)
                ylabel(opt.y_label)
            
                jj=jj+1;
            end
        end
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


