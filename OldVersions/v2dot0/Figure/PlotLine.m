function PlotLine(DATA,opt)
% =======================================================================
% Plots chart of DATA(nobs,nxx,nyy)
% =======================================================================
% PlotLine(DATA,opt)
% -----------------------------------------------------------------------
% INPUTS 
%	- DATA: matrix of DATA (nobs,nxx,nyy)
% -----------------------------------------------------------------------
% OPTIONAL INPUTS
%   - opt: see function PlotLineOption
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com



%% Preliminaries
%--------------------------------------------------------------------------
% Define the dimension of the data vector DATA(nobs,nxx,nyy)...
aux  = size(DATA);
nobs = aux(1);
nxx  = aux(2);  

% ... and understand if it's panel or not
junk = max(size(aux));
if junk==3
    nyy = aux(3);
else
    nyy = 1;
end
clear aux junk


%% CHECK BASIC INPUTS
%--------------------------------------------------------------------------
% If no option is inputed create default
if ~exist('opt','var')
    opt = PlotLineOption;
end

% If the are no opt.ynames, create opt.ynames
if isempty(opt.ynames)
    opt.ynames(1,1:nxx) = {''}; 
    for jj=1:nxx
        opt.ynames(1,jj) = {['Variable' num2str(jj)]};
    end
end

% % If the opt.ynames are not 1xj, transpose it
% if size(opt.ynames,1)~=1
%     opt.ynames = opt.ynames';
% end

% Initialize the number of comparisons (default is no comparison)
ncompare = 1;

% If opt.compare==1, set up the parameters for the loops
if opt.compare==1
    if isempty(opt.znames)
        opt.znames(1,1:nyy) = {''};
        for jj=1:nyy
            opt.znames(1,jj) = { ['Panel' num2str(jj)] };
        end
    end
    if nyy <= 1
        error('There are no series to be compared')
    else        
        ncompare = nyy;
        nyy = 1;
        if ncompare > 4
            error('More than four series to be compared')
        end

    end
end
   
%% PLOT
%--------------------------------------------------------------------------
% Set the desired font
fontopt = FigFontOption(opt.fontsize);
% Compute x axis
xaxis = zeros(nobs,1);
% Compute the number of figures needed (given opt.row and opt.col)
nfigures = NumTotFigures(opt.row,opt.col,nxx);
% Plot
for mm=1:nyy
    jj = 1;
    for nn = 1:nfigures;
        FigSize
        for kk = 1:opt.row*opt.col;
            if jj>nxx % to solve if I put more opt.row*opt.col 
                subplot(opt.row,opt.col,kk)
                plot(xaxis,'LineStyle','none')
                axis off
            else
                subplot(opt.row,opt.col,kk);
                % This is the loop for comparison (when no comparison, ncompare=1)
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
                title(opt.ynames(:,jj))
                if opt.grid==1 
                    grid on
                else 
                    grid off
                end
                if opt.box==1 
                    set(gca,'Box','on')
                else 
                    set(gca, 'Box','off')
                end                
                % Dates
                if ~isempty(opt.fo)
                    DatesPlot(opt.fo,nobs,opt.nticks,opt.frequency)
                end
                % Axis labels
                xlabel(opt.x_label)
                ylabel(opt.y_label)
                % Font
                FigFont(fontopt)
                % If more then one plot per chart, create a legend
                if opt.compare
                    legopt = LegOption;
                    LegSubplot(opt.znames,legopt)
                end
                jj=jj+1;
            end
        end
        
        % if it is a panel data(nobs,nxx,nyy), start enumerating
        if nyy>1
            % if more than one image per country, start enumerating
            if nfigures > 1
                aux_savename = [opt.savename '_' num2str(mm) '_' num2str(nn)];
            else
                aux_savename = [opt.savename '_' num2str(mm)];
            end
        else
            % if more than one image per country, start enumerating
            if nfigures > 1
                aux_savename = [opt.savename '_' num2str(nn)];
            else
                aux_savename = opt.savename;
            end
        end

        % Save
        if opt.quality
            set(gcf, 'Color', 'w');
            export_fig(aux_savename,'-pdf','-png','-painters')
        else
            print('-dpng','-r100',aux_savename)
            print('-dpdf','-r100',aux_savename)
        end
        clf('reset');
    end
    close all
end