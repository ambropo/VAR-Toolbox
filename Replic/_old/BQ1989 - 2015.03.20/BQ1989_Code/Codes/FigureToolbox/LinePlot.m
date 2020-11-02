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

% If the are no opt.vnames, create opt.vnames
if isempty(opt.vnames)
    opt.vnames(1,1:nxx) = {''}; 
    for jj=1:nxx
        opt.vnames(1,jj) = {['Variable' num2str(jj)]};
    end
end

% If the opt.vnames are not 1xj, transpose it
if size(opt.vnames,1)~=1
    opt.vnames = opt.vnames';
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
        error('There are no series to be compared')
    else        
        ncompare = nyy;
        nyy = 1;
        if ncompare > 4
            error('More than seven series to be compared')
        end

    end
end

    
    
%% PLOT
%--------------------------------------------------------------------------
% Compute x axis
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
                plot(xaxis,'LineStyle','none')
                axis off
            else
%                 if sum(is_empty(:,jj))==nobs
%                     while sum(is_empty(:,jj))==nobs && jj<nxx
%                         jj=jj+1;
%                     end
%                 end
                    
                subplot(opt.row,opt.col, kk);
                
                % This is the loop for comparison (when no comparison is made ncompare=1)
                for hh=1:ncompare
                    if opt.compare == 0
                        plot(DATA(:,jj,mm),opt.LineStyle{hh},'LineWidth',opt.LineWidth(hh),...
                            'Color',rgb(opt.LineColor{hh}));
                    else
                        plot(DATA(:,jj,hh),opt.LineStyle{hh},'LineWidth',opt.LineWidth(hh),...
                            'Color',rgb(opt.LineColor{hh}));
                    end
                    hold on
                end
                
                % Default plot the xaxis
                if opt.do_x
                    plot(xaxis,'-k')
                end

                message = char(opt.vnames(:,jj));
                title(message,'FontSize',opt.fontsize+1,'Interpreter',opt.interpr,'FontWeight','Bold','FontName',opt.fontname)

                if opt.grid==1 
                    grid on
                else 
                    grid off
                end
                
                set(gca, 'FontSize',opt.fontsize,'FontName',opt.fontname)
                set(gca, 'Box','off' )
                ticks1 = linspace(1,nobs,opt.NumTicks);
                set(gca, 'XTick', ticks1);
                set(gca, 'xLim',[1 nobs])

                if ~isempty(opt.timeline)
                    label = GetDateLabel(opt);
%                     ticks2 = linspace(1,nobs,opt.NumTicks);
                    set(gca,'xTickLabel',label(floor(ticks1)));
                end

                if opt.tight==1
                    if sum(is_empty(:,jj))~=nobs
                        for hh=1:ncompare
                            y_sup(hh) = max(DATA(:,jj,hh));
                            y_inf(hh) = min(DATA(:,jj,hh));
                        end
                        ylim( [min(y_inf) max(y_sup)] );
                    end
                end

                xlabel(opt.x_label,'Fontsize',opt.fontsize-2,'FontName',opt.fontname)
                ylabel(opt.y_label,'Fontsize',opt.fontsize-2,'FontName',opt.fontname)
                
                % If more then one plot per chart, create a legend
                if ncompare > 1 && kk==1
                    LegendSubplot(opt.PanelName,0.01,opt.interpr)
                    c = findobj(gcf,'Type','axes','Tag','legend');
                    set(c, 'FontSize', opt.fontsize-2, 'FontName',opt.fontname);
                end
                
                jj=jj+1;
            end
        end
        
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