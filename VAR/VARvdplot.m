function VARvdplot(VD, VARopt, INF, SUP)
% =======================================================================
% Plot variance decompositions as stacked area charts or confidence bands
% =======================================================================
% VARvdplot(VD, VARopt)
% VARvdplot(VD, VARopt, INF, SUP)
% -----------------------------------------------------------------------
% INPUT
%   - VD:     (nsteps x nshocks x nvars) variance decomposition matrix;
%             VD(h,j,i) = share of variance of variable i at horizon h
%             explained by shock j [double]
%   - VARopt: options structure (see VARoption) [struct]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - INF: lower confidence band, (nsteps x nshocks x nvars) [dflt = none]
%   - SUP: upper confidence band, (nsteps x nshocks x nvars) [dflt = none]
%       When INF and SUP are supplied, the layout switches to band mode:
%       one figure per shock, one panel per variable, showing the VD
%       fraction due to that shock with confidence bands.
%       In band mode, pick selects the shock (0 = all, j = shock j only).
% -----------------------------------------------------------------------
% EXAMPLE
%   VD = rand(20, 3, 3); VD = VD ./ sum(VD,2) * 100;
%   VARopt = VARoption; VARopt.vnames = {'y','pi','r'};
%   VARvdplot(VD, VARopt);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------


%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Verify that required options are present and variable names are defined.
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end

% If there is VARopt check that vnames is not empty
vnames = VARopt.vnames;
if isempty(vnames); vnames = VARopt.mnem; end   % fall back to mnemonics
if isempty(vnames)
    error('You need to add label for endogenous variables in VARopt');
end

% Define shock names
if isempty(VARopt.snames)
    snames = vnames;
else
    snames = VARopt.snames;
end


%% 2. RETRIEVE AND INITIALIZE VARIABLES
% -----------------------------------------------------------------------
% Extract plotting options from VARopt and determine figure dimensions.
if isempty(VARopt.figname); filename = 'VD'; else; filename = VARopt.figname; end
quality  = VARopt.quality;
suptitle = VARopt.suptitle;
pick     = VARopt.pick;
if isfield(VARopt,'latex') && VARopt.latex==1; interp='latex'; else; interp='tex'; end
if isfield(VARopt,'font');  fontname=VARopt.font;  else; fontname='Palatino'; end

% Initialize VD matrix
[nsteps, nshocks, nvars] = size(VD);

% Detect band mode: activated when both INF and SUP are supplied
bands = exist('INF','var') && exist('SUP','var');

% Area plots stack all shocks; not meaningful when only shock 1 is identified
if isfield(VARopt,'ident') && strcmp(VARopt.ident,'iv') && ~bands
    error('VARvdplot: area plots are not available when ident=''iv''. Only shock 1 is IV-identified; shocks 2:n are zero. Use band plots (pass INF and SUP) to display shock 1 only, or set VARopt.pick to select shock 1.');
end

% Define a timeline and zero line
steps  = 1:1:nsteps;
x_axis = zeros(1,nsteps);

% Figure visibility: 'off' suppresses display while still allowing saving
if isfield(VARopt,'visible') && VARopt.visible==0; vis='off'; else; vis='on'; end


%% 3. PLOT
% -----------------------------------------------------------------------
if bands
    % BAND MODE: one figure per shock, one panel per variable.
    % Central line is VD(:,jj,ii); bands come from INF and SUP.

    % In band mode, pick selects shock (0 = all, j = shock j only)
    if pick<0 || pick>nshocks
        error('VARvdplot: the selected shock index (pick=%d) is out of range [0, %d].', pick, nshocks)
    elseif pick==0
        jstart = 1;
    else
        jstart = pick; nshocks = pick;
    end
    nfigs = nshocks - jstart + 1;

    % Line and band color: use caller-specified value or fall back to pantone('Blue')
    if isfield(VARopt,'color') && ~isempty(VARopt.color)
        plotcol = VARopt.color;
    else
        plotcol = pantone('Blue');
    end

    % Subplot grid: use caller-specified layout or auto from sqrt(nvars)
    if ~isempty(VARopt.subplot)
        row = VARopt.subplot(1); col = VARopt.subplot(2);
    else
        row = round(sqrt(nvars)); col = ceil(sqrt(nvars));
    end

    % Swathe appearance: swatheonly=1 suppresses built-in line; center line drawn separately
    SwatheOpt = PlotSwatheOption;
    SwatheOpt.swathecol  = plotcol;
    SwatheOpt.dualaxis   = 0;   % panel styled once below via SetAxesDual, gated by VARopt.dualaxis
    SwatheOpt.swatheonly = 1;
    SwatheOpt.transp     = 1;
    SwatheOpt.alpha      = 0.15;
    SwatheOpt.border     = 1;
    SwatheOpt.xvec       = steps;

    % One figure per shock
    for jj = jstart:nshocks
        figure('Visible',vis);
        if isempty(VARopt.figsize); FigSize(12*col, 6*row); else; FigSize(VARopt.figsize(1),VARopt.figsize(2)); end
        for ii = 1:nvars
            subplot(row, col, ii);

            % Confidence band
            PlotSwathe(VD(:,jj,ii), [INF(:,jj,ii) SUP(:,jj,ii)], SwatheOpt); hold on;
            set(gcf,'renderer','painters')

            % Central line
            plot(steps, VD(:,jj,ii), 'LineStyle','-', 'Color',plotcol, 'LineWidth',2); hold on

            % Zero line
            plot(steps, x_axis, '-k', 'LineWidth',0.5); hold on

            xlim([1 nsteps]);
            ylim([0 100]);
            if isfield(VARopt,'xlim')  && ~isempty(VARopt.xlim);  xlim(VARopt.xlim);              end
            if isfield(VARopt,'ylim')  && ~isempty(VARopt.ylim);  ylim(VARopt.ylim);              end
            if isfield(VARopt,'xtick') && ~isempty(VARopt.xtick); set(gca,'XTick',VARopt.xtick); end

            % Panel title: variable to shock
            if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} ' to }' snames{jj}]; else; tstr = [vnames{ii} ' to ' snames{jj}]; end
            title(tstr,'FontWeight','bold','FontSize',14,'Interpreter',interp);
            set(gca,'FontSize',12,'Layer','bottom','TickLabelInterpreter',interp);

            if VARopt.grid; grid on; end
            if isfield(VARopt,'xlabel') && ~isempty(VARopt.xlabel); xlabel(VARopt.xlabel); end
            if isfield(VARopt,'ylabel') && ~isempty(VARopt.ylabel); ylabel(VARopt.ylabel); end
            set(findobj(gca,'Type','line'),'Clipping','off');
            if VARopt.dualaxis; SetAxesDual(gca); end
        end

        % Apply font to all text elements in figure before saving
        if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end

        % Save
        if nfigs > 1; FigName = [filename '_' num2str(jj)]; else; FigName = filename; end
        if quality>=1
            if suptitle==1
                Alphabet = char('a'+(1:nshocks)-1);
                SupTitle([Alphabet(jj) ') VD shock: ' snames{jj}])
                if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
            end
            SaveFigure(FigName,quality)
        elseif quality==0
            print('-dpdf','-r100',FigName);
        end
    end

else
    % STACKED AREA MODE (default): one figure with all variables as subplots.

    % Validate pick against nvars; if pick>0, restrict to the first pick variables
    if pick<0 || pick>nvars
        error('The selected variable is non valid')
    else
        if pick==0
            pick=1;
        else
            nvars = pick;
        end
    end

    % Subplot grid: use caller-specified layout or auto from sqrt(nvars)
    if ~isempty(VARopt.subplot)
        row = VARopt.subplot(1);
        col = VARopt.subplot(2);
    else
        row = round(sqrt(nvars));
        col = ceil(sqrt(nvars));
    end

    figure('Visible',vis);
    if isempty(VARopt.figsize); FigSize(12*col, 6*row); else; FigSize(VARopt.figsize(1),VARopt.figsize(2)); end
    for ii=pick:nvars
        ax_panel = subplot(row,col,ii);
        H = AreaPlot(VD(:,:,ii));
        xlim([1 nsteps]);
        if isfield(VARopt,'xlim') && ~isempty(VARopt.xlim); xlim(VARopt.xlim); end
        ylim([0 100]);
        if isfield(VARopt,'ylim') && ~isempty(VARopt.ylim); ylim(VARopt.ylim); end
        if isfield(VARopt,'xtick') && ~isempty(VARopt.xtick); set(gca,'XTick',VARopt.xtick); end
        if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} '}']; else; tstr = vnames{ii}; end
        title(tstr,'FontWeight','bold','FontSize',14,'Interpreter',interp);
        set(gca, 'FontSize', 12, 'Layer', 'bottom', 'TickLabelInterpreter', interp);
        if VARopt.grid; grid on; end
        if isfield(VARopt,'xlabel') && ~isempty(VARopt.xlabel); xlabel(VARopt.xlabel); end
        if isfield(VARopt,'ylabel') && ~isempty(VARopt.ylabel); ylabel(VARopt.ylabel); end
        % Disable clipping so area/line edges at the axis boundary render fully
        set(findobj(gca,'Type','line'), 'Clipping', 'off');
        if VARopt.dualaxis; SetAxesDual(gca); end
    end

    % Save figure at the requested quality level
    FigName = filename;
    if isfield(VARopt,'legloc')  && ~isempty(VARopt.legloc);  legloc  = VARopt.legloc;  else; legloc  = 'best'; end
    if isfield(VARopt,'legcols') && ~isempty(VARopt.legcols); legcols = VARopt.legcols; else; legcols = 1;      end
    ax_last = ax_panel;
    if strcmp(legloc,'best'); legloc = BestCornerLoc(ax_last); end
    if quality>=1
        if suptitle==1
            SupTitle(['a) VD of '  vnames{ii}])
        end
        lh = legend(ax_last, H(1,:), snames, 'Location',legloc, 'Interpreter',interp, 'FontSize',11);
        lh.Box = 'on'; lh.NumColumns = legcols;
        if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
        SaveFigure(FigName,quality)
    elseif quality==0
        lh = legend(ax_last, H(1,:), snames, 'Location',legloc, 'Interpreter',interp, 'FontSize',11);
        lh.Box = 'on'; lh.NumColumns = legcols;
        if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
        print('-dpdf','-r100',FigName);
    end
end

%close all
