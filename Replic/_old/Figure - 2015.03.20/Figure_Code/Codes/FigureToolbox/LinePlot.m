function LinePlot(DATA,opt)
% =======================================================================
% Plots chart of DATA(nobs,nxx,nyy)
% =======================================================================
% lineplot(DATA,opt)
% -----------------------------------------------------------------------
% INPUTS 
%	- DATA    : matrix DATA(i,j)
%
% OPTIONAL INPUTS
%   - opt     : see function PlotOption
% =========================================================================
% Ambrogio Cesa Bianchi, February 2012
% ambrogio.cesabianchi@gmail.com



%% Preliminaries
%--------------------------------------------------------------------------

% Define the dimension of the data vector DATA(nobs,nxx,nyy)...
aux  = size(DATA);
nobs = aux(1);
nxx  = aux(2);

% ... and automatically understand if it's panel or not
junk = max(size(aux));
if junk==3
    nyy = aux(3);
else
    nyy = 1;
end
clear aux junk


%% CHECK BASIC INPUTS
%--------------------------------------------------------------------------

% If no option create default
if ~exist('opt','var')
    opt = PlotOption;
end

% If the are no opt.VariableName, create opt.VariableName
if isempty(opt.VariableName)
    opt.VariableName(1,1:nxx) = {''}; 
    for jj=1:nxx
        opt.VariableName(1,jj) = {['Variable' num2str(jj)]};
    end
end

% If the opt.VariableName are not 1xj, transpose it
if size(opt.VariableName,1)~=1
    opt.VariableName = opt.VariableName';
end

% Initialize the number of comparisons (default is no comparison)
ncompare = 1;

% If opt.compare==1, set up the parameters for the loops
if opt.compare==1
    if isempty(opt.PanelName)
        opt.PanelName(1,1:nyy) = {''};
        for jj=1:nyy
            opt.PanelName(1,jj) = { ['Panel' num2str(jj)] };
        end
    end
    if nyy <= 1
        disp('-------------------------------------------------------')
        disp('Error: there are no series to be compared.')
        disp('Add a third dimension to the matrix DATA(nobs,nxx,???).')
        disp('-------------------------------------------------------')
        return
    else        
        ncompare = nyy;
        nyy = 1;
        if ncompare > 4
            disp('-------------------------------------------------------')
            disp('Error: more than seven series to be compared.')
            disp('Reduce the number of series or plot individually.')
            disp('-------------------------------------------------------')
            return
        end

    end
end

    
    
%% PLOT
%--------------------------------------------------------------------------

x     = [0:nobs-1]'; 
xaxis = zeros(nobs,1);

% Compute the number of figures needed (given opt.row and opt.col)
nfigures = NumTotFigures(opt.row,opt.col,nxx);

% Store in is_empty the NaN column in the plot matrices
is_empty = isnan(DATA(:,:,:));

% Plot
for mm=1:nyy
    jj = 1;
    for nn = 1:nfigures;
        for kk = 1:opt.row*opt.col;
            if jj>nxx % to solve if I put more opt.row*opt.col 
                subplot(opt.row,opt.col,kk)
                plot(x,'LineStyle','none')
                axis off
            else
                if sum(is_empty(:,jj))==nobs
                    while sum(is_empty(:,jj))==nobs && jj<nxx
                        jj=jj+1;
                    end
                end
                    
                subplot(opt.row,opt.col, kk);
                
                % This is the loop for comparison (when no comparison is made ncompare=1)
                for hh=1:ncompare
                    if opt.compare == 0
                        plot(x,DATA(:,jj,mm),opt.LineStyle{hh},'LineWidth',opt.LineWidth(hh),...
                            'Color',rgb(opt.LineColor{hh}));
                    else
                        plot(x,DATA(:,jj,hh),opt.LineStyle{hh},'LineWidth',opt.LineWidth(hh),...
                            'Color',rgb(opt.LineColor{hh}));
                    end
                    hold on
                end
                
                % Default plot the xaxis
                if opt.do_x
                    plot(x,xaxis,'-k')
                end

                message = char(opt.VariableName(:,jj));
                title(message,'FontSize',opt.fontsize+1,'Interpreter',opt.interpr,'FontWeight','Bold','FontName',opt.fontname)

                if opt.grid==1 
                    grid on
                else 
                    grid off
                end
                
                set(gca, 'FontSize',opt.fontsize,'FontName',opt.fontname)
                set(gca, 'Box','off' )
                ticks1 = linspace(1,nobs,opt.NumTicks);
                set(gca, 'XTick', ticks1); % set the number of ticks
                set(gca, 'xLim',[1 nobs])                     %set the maximum a

                if ~isempty(opt.timeline)
                    label = GetDateLabel(opt);
%                     ticks2 = linspace(1,nobs,opt.NumTicks);
                    set(gca,'xTickLabel',label(floor(ticks1)));
                end

    %                 y_sup = max(DATA(:,jj));
    %                 y_inf = min(DATA(:,jj));
    %                 y_jump  = y_sup - y_inf;
    %                 ylim( [y_inf-0.05*y_jump y_sup+0.05*y_jump] )

                xlabel(opt.x_label,'Fontsize',opt.fontsize-2,'FontName',opt.fontname)
                ylabel(opt.y_label,'Fontsize',opt.fontsize-2,'FontName',opt.fontname)
                
                % If more then one plot per chart, create a legend
                if ncompare > 1 && kk==1
                    LegendSubplot(opt.PanelName,opt.SubLegSize)
                    c = findobj(gcf,'Type','axes','Tag','legend');
                    set(c, 'FontSize', opt.fontsize-2, 'FontName',opt.fontname);
                end

                jj=jj+1;
            end
        end

%         % If more then one plot per chart, create a legend
%         if ncompare > 1
%             legend_subplot(opt.PanelName,0.7)
%         end
        
        % insert the super title
        if ~isempty(opt.FigTitle)
            SupTitle(char(opt.FigTitle));
        end

        % if it is a panel data(nobs,nxx,nyy), start enumerating
        if nyy>1
            % if more than one image per country, start enumerating
            if nfigures > 1
                aux_FigName = [opt.FigName '_' num2str(mm) '_' num2str(nn)];
            else
                aux_FigName = [opt.FigName '_' num2str(mm)];
            end
        else
            % if more than one image per country, start enumerating
            if nfigures > 1
                aux_FigName = [opt.FigName '_' num2str(nn)];
            else
                aux_FigName = opt.FigName;
            end
        end

        % Save
        set(gcf, 'Color', 'w');
        export_fig(aux_FigName,'-pdf','-png','-painters')
        clf('reset');

    end

    close all
end