function PlotLine(DATA,opt)
% =======================================================================
% Plot a grid of line charts from a three-dimensional data array
% =======================================================================
% PlotLine(DATA,opt)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: data array [nobs x nxx x nyy]
%       nobs = observations, nxx = variables, nyy = panels (optional)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - opt: options structure from PlotLineOption
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = randn(40,6); opt = PlotLineOption; PlotLine(DATA,opt)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Determine the dimensions of DATA(nobs, nxx, nyy)
aux  = size(DATA);
nobs = aux(1);
nxx  = aux(2);

% Detect whether DATA has a third (panel) dimension
if ndims(DATA)==3
    nyy = aux(3);
else
    nyy = 1;
end
clear aux

%% 2. CHECK INPUTS
% -----------------------------------------------------------------------
% Load defaults if no options struct is provided
if ~exist('opt','var')
    opt = PlotLineOption;
end

% If no variable names are specified, generate generic labels
if isempty(opt.ynames)
    opt.ynames(1,1:nxx) = {''};
    for jj=1:nxx
        opt.ynames(1,jj) = {['Variable' num2str(jj)]};
    end
end

% Initialise the comparison counter (1 = no comparison)
ncompare = 1;

% If comparison mode is on, validate that multiple panels exist and set
% up the loop parameters accordingly
if opt.compare==1
    if isempty(opt.znames)
        opt.znames(1,1:nyy) = {''};
        for jj=1:nyy
            opt.znames(1,jj) = {['Panel' num2str(jj)]};
        end
    end
    if nyy <= 1
        error('PlotLine: opt.compare=1 requires DATA to have at least two panels (nyy>1)')
    else
        ncompare = nyy;
        nyy = 1;
        if ncompare > 4
            error('PlotLine: opt.compare=1 supports at most four panels to compare')
        end
    end
end

%% 3. PLOT
% -----------------------------------------------------------------------
% Set the desired font size
fontopt = opt.fontsize;
% Pre-allocate a zero vector to draw the horizontal axis reference line
xaxis = zeros(nobs,1);
% Determine the number of figures needed given the subplot grid
nfigures = NumTotFigures(opt.row,opt.col,nxx);

% Loop over the panel (z) dimension; nyy=1 when compare=0
for mm=1:nyy
    jj = 1;
    for nn = 1:nfigures
        % Open a new figure window and set its size for this page
        FigSize
        for kk = 1:opt.row*opt.col
            if jj>nxx
                % Fill surplus subplot panels with an invisible blank plot
                subplot(opt.row,opt.col,kk)
                plot(xaxis,'LineStyle','none')
                axis off
            else
                subplot(opt.row,opt.col,kk);
                % Inner loop handles comparison mode (ncompare=1 when off)
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
                axis tight
                % Overlay a zero reference line on the horizontal axis
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
                    set(gca,'Box','off')
                end
                % Add date tick labels if a first-observation date is set
                if ~isempty(opt.fo)
                    DatesPlot(opt.fo,nobs,opt.nticks,opt.frequency)
                end
                % Axis labels
                xlabel(opt.x_label)
                ylabel(opt.y_label)
                % Apply font settings
                FigFont(fontopt)
                % Add a shared legend when comparing panels
                if opt.compare
                    legopt = LegOption;
                    LegSubplot(opt.znames,legopt)
                end
                % Dual-axis panel style (box off, ticks mirrored on both
                % y-axes). Each panel holds a single PlotLine call, so it is
                % styled once. Missing field defaults to on.
                if ~isfield(opt,'dualaxis') || opt.dualaxis
                    SetAxesDual(gca);
                end
                jj = jj+1;
            end
        end

        % Build the save name: append panel and figure indices when needed
        if nyy>1
            if nfigures > 1
                aux_savename = [opt.savename '_' num2str(mm) '_' num2str(nn)];
            else
                aux_savename = [opt.savename '_' num2str(mm)];
            end
        else
            if nfigures > 1
                aux_savename = [opt.savename '_' num2str(nn)];
            else
                aux_savename = opt.savename;
            end
        end

        % Save the current figure to disk.
        % quality==0: produces both PNG and PDF at 100 DPI via print().
        % quality==1: produces PDF+PNG via export_fig (requires export_fig on path).
        if opt.quality
            set(gcf, 'Color', 'w');
            export_fig(aux_savename,'-pdf','-png','-painters')
        else
            print('-dpng','-r100',aux_savename)
            print('-dpdf','-r100',aux_savename)
        end
        % clf('reset') is dead code: FigSize at the start of the next loop
        % iteration always creates a new figure, so clearing the current
        % figure has no effect on what gets drawn next.
    end
    close all
end
