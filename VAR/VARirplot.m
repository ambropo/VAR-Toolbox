function VARirplot(IR,VARopt,INF,SUP,INF2,SUP2)
% =====================================================================
% Plot impulse response functions (IRFs) computed by VARmodel, with
% optional confidence bands at one or two coverage levels.
% =====================================================================
% VARirplot(IR,VARopt,INF,SUP,INF2,SUP2)
% ---------------------------------------------------------------------
% INPUT
%   - IR: IRF array (nsteps x nvar x nshocks) [double]
%   - VARopt: options structure from VARoption [struct]
%       Key fields used by VARirplot:
%         .vnames    cell array of variable names (required)
%         .snames    cell array of shock names (empty = use vnames)
%         .pick      shock to plot: 0=all, j=shock j only [dflt = 0]
%         .figname   base filename for saved figures [dflt = 'IR']
%         .quality   save quality: 0=low, 1+=high [dflt = 1]
%         .subplot   [row col] subplot layout (empty = auto)
%         .color     RGB row vector for line and band color
%         .marker    marker style string [dflt = 'none']
%         .grid      1=show grid, 0=no grid
%         .hstart    first horizon label on x-axis [dflt = 1]
% ---------------------------------------------------------------------
% OPTIONAL INPUT
%   - INF:  lower confidence band, outer (nsteps x nvar x nshocks) [dflt = none]
%   - SUP:  upper confidence band, outer (nsteps x nvar x nshocks) [dflt = none]
%   - INF2: lower confidence band, inner (nsteps x nvar x nshocks) [dflt = none]
%   - SUP2: upper confidence band, inner (nsteps x nvar x nshocks) [dflt = none]
%       Outer band is typically the wider interval (e.g. 90% or 95%);
%       inner band is the narrower one (e.g. 68%). Both are optional.
% ---------------------------------------------------------------------
% OUTPUT
%   - Figure(s) displayed on screen and optionally saved to disk.
%       One figure per shock, each with nvar subpanels.
% ---------------------------------------------------------------------
% EXAMPLE
%   Y = randn(120, 3);
%   VARopt = VARoption; VARopt.ident = 'short'; VARopt.nsteps = 20;
%   VARopt.vnames = {'y1','y2','y3'}; VARopt.quality = 0;
%   VAR = VARmodel(Y, 2, 1, VARopt);
%   VARirplot(VAR.IR, VARopt);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. CHECK INPUTS
% ---------------------------------------------------------------------
% Verify that VARopt is supplied and that variable names are defined.
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end

% Retrieve variable and shock names
vnames = VARopt.vnames;
if isempty(vnames); vnames = VARopt.mnem; end   % fall back to mnemonics
if isempty(vnames)
    error('You need to add label for endogenous variables in VARopt');
end
if isempty(VARopt.snames)
    snames = vnames;
else
    snames = VARopt.snames;
end

%% 2. RETRIEVE AND INITIALIZE VARIABLES
% ---------------------------------------------------------------------
% Extract figure-saving settings from VARopt
if isempty(VARopt.figname); basename = 'IR'; else; basename = VARopt.figname; end
quality  = VARopt.quality;
suptitle = VARopt.suptitle;
pick     = VARopt.pick;
if isfield(VARopt,'latex') && VARopt.latex==1; interp='latex'; else; interp='tex'; end
if isfield(VARopt,'font');  fontname=VARopt.font;  else; fontname='Palatino'; end

% Line and band color: use caller-specified value or fall back to pantone('Blue')
if isfield(VARopt,'color') && ~isempty(VARopt.color)
    plotcol = VARopt.color;
else
    plotcol = pantone('Blue');
end

% Line style and first horizon label on x-axis
if isfield(VARopt,'linestyle'); lstyle = VARopt.linestyle; else; lstyle = '-'; end
if isfield(VARopt,'hstart');    hstart = VARopt.hstart;    else; hstart = 1;   end

% IR matrix dimensions
[nsteps, nvars, nshocks] = size(IR);

% Select the shock range to loop over.
% When pick > 0 the loop runs for jj=pick:pick (one iteration), producing
% exactly one figure for the selected shock.
if pick<0 || pick>nvars
    error('The selected shock is non valid')
else
    if pick==0
        pick = 1;
    else
        nshocks = pick;
    end
end

% Number of figures: suffix _N applied only when more than one figure is saved
nfigs = nshocks - pick + 1;

% Subplot grid: use caller-specified layout or auto from sqrt(nvars)
if ~isempty(VARopt.subplot)
    row = VARopt.subplot(1);
    col = VARopt.subplot(2);
else
    row = round(sqrt(nvars));
    col = ceil(sqrt(nvars));
end

% x-axis vector and zero line; hstart sets whether first horizon is 0 or 1
steps  = hstart : 1 : hstart+nsteps-1;
x_axis = zeros(1,nsteps);

%% 3. PLOT
% ---------------------------------------------------------------------
% For each shock jj, draw one figure with nvars panels. Each panel shows
% the IRF of variable ii to shock jj, with optional confidence bands.

% Configure swathe appearance: swatheonly=1 suppresses the built-in line
% so the point estimate with markers is drawn on top instead; xvec aligns
% the band with the IR line when hstart ~= 1.
SwatheOpt = PlotSwatheOption;
SwatheOpt.swathecol  = plotcol;
SwatheOpt.dualaxis   = 0;   % panel styled once below via SetAxesDual, gated by VARopt.dualaxis
SwatheOpt.swatheonly = 1;
SwatheOpt.transp     = 1;
SwatheOpt.alpha      = 0.15;
SwatheOpt.border     = 1;
SwatheOpt.xvec       = steps;

% Detect two-band mode once before the loop
twoband = exist('INF2','var') && exist('SUP2','var');

% Figure visibility: 'off' suppresses display while still allowing saving
if isfield(VARopt,'visible') && VARopt.visible==0; vis='off'; else; vis='on'; end

% Loop over selected shocks; each shock gets its own figure
for jj=pick:nshocks
    figure('Visible',vis);
    if isempty(VARopt.figsize); FigSize(12*col, 6*row); else; FigSize(VARopt.figsize(1),VARopt.figsize(2)); end
    for ii=1:nvars
        subplot(row,col,ii);

        % Draw confidence bands if provided
        if exist('INF','var') && exist('SUP','var')
            if twoband
                SwatheOpt.alpha = 0.15; SwatheOpt.border = 1;
                PlotSwathe(IR(:,ii,jj),[INF(:,ii,jj) SUP(:,ii,jj)],SwatheOpt); hold on;
                SwatheOpt.alpha = 0.30; SwatheOpt.border = 0;
                H2 = PlotSwathe(IR(:,ii,jj),[INF2(:,ii,jj) SUP2(:,ii,jj)],SwatheOpt); hold on;
                set([H2.swathe],'Visible','off');
            else
                PlotSwathe(IR(:,ii,jj),[INF(:,ii,jj) SUP(:,ii,jj)],SwatheOpt); hold on;
            end
            set(gcf,'renderer','painters')
        end

        % Point estimate line with optional markers
        mk = VARopt.marker;
        if strcmp(mk,'none')
            plot(steps,IR(:,ii,jj),'LineStyle',lstyle,'Color',plotcol,'LineWidth',2); hold on
        else
            plot(steps,IR(:,ii,jj),'LineStyle',lstyle,'Color',plotcol,'LineWidth',2,'Marker',mk,'MarkerSize',7,'MarkerFaceColor',0.5*plotcol+0.5*[1 1 1],'MarkerEdgeColor',plotcol); hold on
        end

        % Zero line
        plot(steps,x_axis,'-k','LineWidth',0.5); hold on

        % x-axis limits: use caller-specified range or auto from steps
        if isfield(VARopt,'xlim') && ~isempty(VARopt.xlim)
            xlim(VARopt.xlim);
        else
            xlim([steps(1) steps(end)]);
        end

        % Optional axis formatting
        if isfield(VARopt,'ylim')  && ~isempty(VARopt.ylim);  ylim(VARopt.ylim);               end
        if isfield(VARopt,'xtick') && ~isempty(VARopt.xtick); set(gca,'XTick',VARopt.xtick);  end

        % Panel title: variable name only if no shock names or shorttitle; else 'var to shock'
        shorttitle = isfield(VARopt,'shorttitle') && VARopt.shorttitle==1;
        if shorttitle || isempty(VARopt.snames)
            if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} '}']; else; tstr = vnames{ii}; end
        else
            if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} ' to }' snames{jj}]; else; tstr = [vnames{ii} ' to ' snames{jj}]; end
        end
        title(tstr,'FontWeight','bold','FontSize',14,'Interpreter',interp);
        set(gca,'FontSize',12,'Layer','bottom','TickLabelInterpreter',interp);

        % Optional grid and axis labels
        if VARopt.grid;  grid on;  end
        % Axis labels
        if isfield(VARopt,'xlabel') && ~isempty(VARopt.xlabel); xlabel(VARopt.xlabel); end
        if isfield(VARopt,'ylabel') && ~isempty(VARopt.ylabel); ylabel(VARopt.ylabel); end

        % Disable clipping so markers at the axis boundary render fully
        set(findobj(gca,'Type','line'), 'Clipping', 'off');

        % Dual-axis style: box off, tick marks mirrored on right side
        if VARopt.dualaxis; SetAxesDual(gca); end
    end

    % Apply font to all text elements in figure before saving
    if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end

    % Save figure for this shock
    if nfigs > 1; FigName = [basename '_' num2str(jj)]; else; FigName = basename; end
    if quality>=1
        if suptitle==1
            Alphabet = char('a'+(1:nshocks)-1);
            if isempty(VARopt.snames)
                SupTitle('Impulse Responses')
            else
                SupTitle([Alphabet(jj) ') IR to a shock to '  snames{jj}])
            end
            if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
        end
        SaveFigure(FigName,quality)
    elseif quality==0
        print('-dpdf','-r100',FigName);
    end
end

%close all
