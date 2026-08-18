function VARhdplot(HD, VARopt, INF, SUP)
% =====================================================================
% Plot the historical decomposition stored in HD as stacked area charts
% (default) or as per-shock contribution bands when INF/SUP are provided.
% =====================================================================
% VARhdplot(HD, VARopt)
% VARhdplot(HD, VARopt, INF, SUP)
% ---------------------------------------------------------------------
% INPUT
%   - HD: historical decomposition structure from VAR.HD [struct]
%       Dimension convention: HD.shock is (nobs+nlag x nvar x nvar) with
%         dim2 = shock index, dim3 = variable index.
%       Required fields (always present from compute_HD):
%         .shock  (nobs+nlag x nvar x nvar) — per-shock contributions;
%                   HD.shock(:,j,i) = contribution of shock j to variable i
%         .endo   (nobs+nlag x nvar)        — actual data (sum of all components)
%       Additional fields used when hd_detc=1:
%         .init   (nobs+nlag x nvar)        — initial conditions
%         .const  (nobs+nlag x nvar)        — constant term
%         .trend  (nobs+nlag x nvar)        — linear trend
%         .exo    (nobs+nlag x nvar x nvar_ex) — exogenous variables
%         .exoshock (nobs+nlag x nvar)     — observed exogenous shock block
%       First nlag rows of all fields are NaN (lag-period padding).
%   - VARopt: options structure from VARoption [struct]
%       Key fields for VARhdplot:
%         .hd_detc    1=stack all components (default); 0=shocks only
%         .hd_colors (ncols x 3) RGB matrix to override bar colors in
%                    stack order (const,trend,trend^2,init,exo,shocks);
%                    empty = use cmap(1), cmap(2), ... in column order
%         .legcols   number of legend columns [dflt = 1]
%         .legloc    legend location [dflt = 'best' = auto-corner]
%         .pick      variable to plot: 0=all, j=variable j only (stacked
%                    area) or shock to plot: 0=all, j=shock j (band mode)
% ---------------------------------------------------------------------
% OPTIONAL INPUT
%   - INF: lower confidence band, full HD struct with a .shock field
%          (nobs+nlag x nvar x nvar) [dflt = none]
%   - SUP: upper confidence band, full HD struct with a .shock field
%          (nobs+nlag x nvar x nvar) [dflt = none]
%       .shock follows the same dimension convention as HD.shock:
%       dim2=shock, dim3=variable. When supplied, switches to band mode.
%       Pass VAR.HDinf / VAR.HDsup directly; for the central line use
%       VAR.HD (point estimate) or VAR.HDmed (median across draws).
%       In band mode, pick selects the shock (0 = all, j = shock j only).
% ---------------------------------------------------------------------
% OUTPUT
%   - Figure(s) displayed on screen and optionally saved to disk.
%       Stacked area mode: one figure with one subplot per variable.
%       Band mode: one figure per shock with one subplot per variable.
% ---------------------------------------------------------------------
% EXAMPLE
%   Y = randn(120, 3);
%   VARopt = VARoption; VARopt.ident = 'short'; VARopt.nsteps = 20;
%   VARopt.vnames = {'y1','y2','y3'}; VARopt.quality = 0;
%   VAR = VARmodel(Y, 2, 1, VARopt);
%   VARhdplot(VAR.HD, VARopt);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. CHECK INPUTS
% ---------------------------------------------------------------------
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
% ---------------------------------------------------------------------
if isempty(VARopt.figname); basename = 'HD'; else; basename = VARopt.figname; end
quality  = VARopt.quality;
suptitle = VARopt.suptitle;
pick     = VARopt.pick;
if isfield(VARopt,'hd_detc'); hd_detc = VARopt.hd_detc; else; hd_detc = 1; end
if isfield(VARopt,'latex') && VARopt.latex==1; interp='latex'; else; interp='tex'; end
if isfield(VARopt,'font');  fontname=VARopt.font;  else; fontname='Palatino'; end

% Extract HD dimensions. HD.shock is (time x shock x variable), so size(.,2)
% is the shock count and size(.,3) is the variable count. For a square VAR
% these are equal; the names nvars/nshocks are used as loop bounds only.
[nsteps, nvars, nshocks] = size(HD.shock);

% Detect band mode: activated when both INF and SUP are supplied
bands = exist('INF','var') && exist('SUP','var');

% Area plots stack all shocks; not meaningful when only shock 1 is identified
if isfield(VARopt,'ident') && strcmp(VARopt.ident,'iv') && ~bands
    error('VARhdplot: area plots are not available when ident=''iv''. Only shock 1 is IV-identified; shocks 2:n are zero. Use band plots (pass INF and SUP) to display shock 1 only, or set VARopt.pick to select shock 1.');
end

% Figure visibility: 'off' suppresses display while still allowing saving
if isfield(VARopt,'visible') && VARopt.visible==0; vis='off'; else; vis='on'; end

%% 3. PLOT
% ---------------------------------------------------------------------
if bands
    % BAND MODE: one figure per shock, one panel per variable.
    % Central line is HD.shock(:,jj,ii) — dim2=shock (jj), dim3=variable (ii).
    % INF/SUP are full HD structs (as produced by VARmodel), so bands are
    % read from their .shock field: INF.shock(:,jj,ii), SUP.shock(:,jj,ii).

    % In band mode, pick selects shock (0 = all, j = shock j only)
    if pick<0 || pick>nshocks
        error('VARhdplot: the selected shock index (pick=%d) is out of range [0, %d].', pick, nshocks)
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
    SwatheOpt.xvec       = 1:nsteps;

    % One figure per shock
    for jj = jstart:nshocks
        figure('Visible',vis);
        if isempty(VARopt.figsize); FigSize(12*col, 6*row); else; FigSize(VARopt.figsize(1),VARopt.figsize(2)); end
        for ii = 1:nvars
            subplot(row, col, ii);

            % HD.shock dim2=shock, dim3=variable — swap indices to get
            % contribution of shock jj to variable ii
            PlotSwathe(HD.shock(:,jj,ii), [INF.shock(:,jj,ii) SUP.shock(:,jj,ii)], SwatheOpt); hold on;
            set(gcf,'renderer','painters')

            % Central line
            plot(HD.shock(:,jj,ii), 'LineStyle','-', 'Color',plotcol, 'LineWidth',2); hold on

            % Zero line
            plot(zeros(1,nsteps), '-k', 'LineWidth',0.5); hold on

            % Date labels on x-axis
            if ~isempty(VARopt.firstdate)
                if isfield(VARopt,'datenticks') && ~isempty(VARopt.datenticks); nt = VARopt.datenticks; else; nt = 5; end
                DatesPlot(VARopt.firstdate, nsteps, nt, VARopt.frequency);
            end

            % Axis limits and optional overrides
            xlim([1 nsteps]);
            if isfield(VARopt,'xlim')  && ~isempty(VARopt.xlim);  xlim(VARopt.xlim);              end
            if isfield(VARopt,'ylim')  && ~isempty(VARopt.ylim);  ylim(VARopt.ylim);              end
            if isfield(VARopt,'xtick') && ~isempty(VARopt.xtick); set(gca,'XTick',VARopt.xtick); end

            % Panel title: variable to shock
            if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} ' to }' snames{jj}]; else; tstr = [vnames{ii} ' to ' snames{jj}]; end
            title(tstr,'FontWeight','bold','FontSize',14,'Interpreter',interp);
            set(gca,'FontSize',12,'Layer','bottom','TickLabelInterpreter',interp);

            % Optional grid, axis labels, and axes style
            if VARopt.grid; grid on; end
            if isfield(VARopt,'xlabel') && ~isempty(VARopt.xlabel); xlabel(VARopt.xlabel); end
            if isfield(VARopt,'ylabel') && ~isempty(VARopt.ylabel); ylabel(VARopt.ylabel); end
            set(findobj(gca,'Type','line'),'Clipping','off');
            if VARopt.dualaxis; SetAxesDual(gca); end
        end

        % Apply font to all text elements in figure before saving
        if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end

        % Save
        if nfigs > 1; FigName = [basename '_' num2str(jj)]; else; FigName = basename; end
        if quality>=1
            if suptitle==1
                Alphabet = char('a'+(1:nshocks)-1);
                SupTitle([Alphabet(jj) ') HD shock: ' snames{jj}])
                if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
            end
            SaveFigure(FigName,quality)
        elseif quality==0
            print('-dpdf','-r100',FigName);
        end
    end
else
    % STACKED AREA MODE (default): one figure, one subplot per variable.

    % Validate pick against nvars; pick selects the variable to plot (0 = all, j = variable j only)
    if pick<0 || pick>nvars
        error('VARhdplot: the selected variable index (pick=%d) is out of range [0, %d].', pick, nvars)
    elseif pick==0
        istart = 1;
    else
        istart = pick; nvars = pick;
    end

    % Detect which deterministic components carry non-zero signal.
    % Used both to decide what to stack and to build the legend name list.
    if hd_detc
        has_const  = isfield(HD,'const')  && any(any(isfinite(HD.const)  & HD.const  ~= 0));
        has_trend  = isfield(HD,'trend')  && any(any(isfinite(HD.trend)  & HD.trend  ~= 0));
        has_init   = isfield(HD,'init')   && any(any(isfinite(HD.init)   & HD.init   ~= 0));
        has_exo    = isfield(HD,'exo')    && size(HD.exo,3) > 0;
        has_exosh  = isfield(HD,'exoshock') && any(any(isfinite(HD.exoshock) & HD.exoshock ~= 0));
    end

    % Build legend name list.
    % Stack order (bottom to top): const → trend → init → exo → exoshock → shocks.
    % Const and init converge toward fixed levels and are naturally at the base.
    if hd_detc
        comp_names = {};
        if has_const;  comp_names{end+1} = 'Const.';      end
        if has_trend;  comp_names{end+1} = 'Trend';        end
        if has_init;   comp_names{end+1} = 'Init. cond.';  end
        if has_exo
            n_exo = size(HD.exo,3);
            if isfield(VARopt,'vnames_ex') && length(VARopt.vnames_ex) >= n_exo
                comp_names = [comp_names, VARopt.vnames_ex(1:n_exo)];
            else
                comp_names = [comp_names, arrayfun(@(k)['Exo ' num2str(k)], 1:n_exo, 'UniformOutput',false)];
            end
        end
        if has_exosh; comp_names{end+1} = 'Exo. shock'; end
        comp_names = [comp_names, snames(:)'];
    else
        comp_names = snames(:)';
    end

    % Pre-allocate DATA_stack with known column count (fixed for all variables).
    % Same order: const → trend → init → exo → shocks (bottom to top).
    if hd_detc
        ncols = has_const + has_trend + has_init + has_exosh;
        if has_exo; ncols = ncols + size(HD.exo,3); end
        ncols = ncols + nshocks;
    else
        ncols = nshocks;
    end
    DATA_stack = nan(nsteps, ncols);

    % Subplot grid: use caller-specified layout or auto from sqrt(nvars)
    if ~isempty(VARopt.subplot)
        row = VARopt.subplot(1); col = VARopt.subplot(2);
    else
        row = round(sqrt(nvars)); col = ceil(sqrt(nvars));
    end

    % Open figure and set its size before entering the subplot loop
    figure('Visible',vis);
    if isempty(VARopt.figsize); FigSize(12*col, 6*row); else; FigSize(VARopt.figsize(1),VARopt.figsize(2)); end
    for ii=istart:nvars
        ax_panel = subplot(row,col,ii);

        % Fill DATA_stack: const → trend → init → exo → shocks.
        % HD.shock: dim2=shock, dim3=variable — use (:,:,ii) for all shocks to var ii.
        if hd_detc
            c = 1;
            if has_const;  DATA_stack(:,c) = HD.const(:,ii);  c = c+1; end
            if has_trend;  DATA_stack(:,c) = HD.trend(:,ii);  c = c+1; end
            if has_init;   DATA_stack(:,c) = HD.init(:,ii);   c = c+1; end
            if has_exo
                n_exo = size(HD.exo,3);
                DATA_stack(:,c:c+n_exo-1) = squeeze(HD.exo(:,ii,:)); c = c+n_exo;
            end
            if has_exosh; DATA_stack(:,c) = HD.exoshock(:,ii); c = c+1; end
            DATA_stack(:,c:end) = squeeze(HD.shock(:,:,ii));
        else
            DATA_stack(:,:) = squeeze(HD.shock(:,:,ii));
        end

        % Draw stacked area chart from filled DATA_stack
        H = AreaPlot(DATA_stack); hold on;

        % Apply caller-supplied colors (VARopt.hd_colors): each row overrides
        % the color of the corresponding DATA_stack column in stack order.
        if isfield(VARopt,'hd_colors') && ~isempty(VARopt.hd_colors)
            nc = min(size(VARopt.hd_colors,1), ncols);
            for kk = 1:nc
                for rr = 1:2
                    H(rr,kk).FaceColor = VARopt.hd_colors(kk,:);
                    H(rr,kk).EdgeColor = VARopt.hd_colors(kk,:);
                end
            end
        end

        % Reference line: full data when hd_detc=1; data minus const and init
        % when hd_detc=0 so shock bars sum exactly to the reference.
        if hd_detc
            h = plot(HD.endo(:,ii),'-k','LineWidth',2);
        else
            baseline_ii = zeros(nsteps,1);
            if isfield(HD,'const'); baseline_ii = baseline_ii + HD.const(:,ii); end
            if isfield(HD,'init');  baseline_ii = baseline_ii + HD.init(:,ii);  end
            h = plot(HD.endo(:,ii) - baseline_ii,'-k','LineWidth',2);
        end
        if ~isempty(VARopt.firstdate); if isfield(VARopt,'datenticks') && ~isempty(VARopt.datenticks); nt = VARopt.datenticks; else; nt = 5; end; DatesPlot(VARopt.firstdate,nsteps,nt,VARopt.frequency); end
        xlim([1 nsteps]);
        if isfield(VARopt,'xlim') && ~isempty(VARopt.xlim); xlim(VARopt.xlim); end
        if isfield(VARopt,'ylim') && ~isempty(VARopt.ylim); ylim(VARopt.ylim); end
        if isfield(VARopt,'xtick') && ~isempty(VARopt.xtick); set(gca,'XTick',VARopt.xtick); end
        set(gca,'FontSize',12,'Layer','bottom','TickLabelInterpreter',interp);
        if VARopt.grid; grid on; end
        if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} '}']; else; tstr = vnames{ii}; end
        title(tstr,'FontWeight','bold','FontSize',14,'Interpreter',interp);
        if isfield(VARopt,'xlabel') && ~isempty(VARopt.xlabel); xlabel(VARopt.xlabel); end
        if isfield(VARopt,'ylabel') && ~isempty(VARopt.ylabel); ylabel(VARopt.ylabel); end
        % Disable clipping so area/line edges at the axis boundary render fully
        set(findobj(gca,'Type','line'), 'Clipping', 'off');
        if VARopt.dualaxis; SetAxesDual(gca); end
    end

    % Save — legend in last subplot, one file
    FigName = basename;
    ax_last = ax_panel;
    if isfield(VARopt,'legloc')  && ~isempty(VARopt.legloc);  legloc  = VARopt.legloc;  else; legloc  = 'best'; end
    if isfield(VARopt,'legcols') && ~isempty(VARopt.legcols); legcols = VARopt.legcols; else; legcols = 1;      end
    if strcmp(legloc,'best'); legloc = BestCornerLoc(ax_last); end
    if hd_detc; ref_label = 'Data'; else; ref_label = 'Data (adj.)'; end
    if quality>=1
        lh = legend(ax_last, [H(1,:) h], [comp_names {ref_label}], 'Location',legloc, 'Interpreter',interp, 'FontSize',11);
        lh.Box = 'on'; lh.NumColumns = legcols;
        if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
        SaveFigure(FigName,quality)
    elseif quality==0
        lh = legend(ax_last, [H(1,:) h], [comp_names {ref_label}], 'Location',legloc, 'Interpreter',interp, 'FontSize',11);
        lh.Box = 'on'; lh.NumColumns = legcols;
        if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
        print('-dpdf','-r100',FigName);
    end
end

%close all
