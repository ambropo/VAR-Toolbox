function LPirplot(IR,LPopt,INF,SUP,INF2,SUP2)
% =======================================================================
% Plot the impulse responses computed with LPmodel
% =======================================================================
% LPirplot(IR,LPopt,INF,SUP,INF2,SUP2)
% -----------------------------------------------------------------------
% INPUT
%   - IR(:,:)  : LP impulse responses (H horizons x N variables); each
%                column is the response of one variable to the same shock
%   - LPopt    : LP options structure (see LPoption); must contain
%                LPopt.vnames (variable labels) and LPopt.snames (shock
%                label, one-element cell array)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - INF:  lower confidence band, outer (H x N) [e.g. 95%]
%   - SUP:  upper confidence band, outer (H x N) [e.g. 95%]
%   - INF2: lower confidence band, inner (H x N) [e.g. 68%]
%   - SUP2: upper confidence band, inner (H x N) [e.g. 68%]
% -----------------------------------------------------------------------
% EXAMPLE
%   LPopt = LPoption;
%   LPopt.vnames = {'GDP','Inflation'};
%   LPopt.snames = {'MP shock'};
%   IR = randn(20,2);
%   LPirplot(IR, LPopt);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Verify that LPopt is supplied and that variable names are defined.
if ~exist('LPopt','var')
    error('You need to provide LP options (LPopt from LPoption)');
end

% Retrieve variable and shock names
vnames = LPopt.vnames;
if isempty(vnames); vnames = LPopt.mnem; end   % fall back to mnemonics
if isempty(vnames)
    error('You need to add variable labels in LPopt.vnames');
end
if ~isempty(LPopt.snames); sname = LPopt.snames{1}; else; sname = ''; end

%% 2. RETRIEVE AND INITIALIZE VARIABLES
% -----------------------------------------------------------------------
% Extract figure-saving settings from LPopt
if isempty(LPopt.figname); filename = 'LP_IR'; else; filename = LPopt.figname; end
quality  = LPopt.quality;
suptitle = LPopt.suptitle;
hstart   = LPopt.hstart;
lstyle   = LPopt.linestyle;
if isfield(LPopt,'latex') && LPopt.latex==1; interp='latex'; else; interp='tex'; end
if isfield(LPopt,'font');  fontname=LPopt.font;  else; fontname='Palatino'; end

% Line and band color: use caller-specified value or fall back to pantone('Blue')
if isempty(LPopt.color)
    plotcol = pantone('Blue');
else
    plotcol = LPopt.color;
end

% Dimensions of the IR array: rows are horizons, columns are variables
[nsteps, nvars] = size(IR);

% Subplot grid: use caller-specified layout or auto from sqrt(nvars)
if ~isempty(LPopt.subplot)
    row = LPopt.subplot(1);
    col = LPopt.subplot(2);
else
    row = round(sqrt(nvars));
    col = ceil(sqrt(nvars));
end

% x-axis vector and zero line; hstart sets whether first horizon is 0 or 1
steps  = hstart : 1 : hstart+nsteps-1;
x_axis = zeros(1,nsteps);

%% 3. PLOT
% -----------------------------------------------------------------------
% Draw one figure with nvars panels. Each panel shows the IRF of variable
% ii to the shock, with optional confidence bands.

% Configure swathe appearance: swatheonly=1 suppresses the built-in line
% so the point estimate with markers is drawn on top instead; xvec aligns
% the band with the IR line when hstart ~= 1.
SwatheOpt = PlotSwatheOption;
SwatheOpt.swathecol  = plotcol;
SwatheOpt.dualaxis   = 0;   % panel styled once below via SetAxesDual, gated by LPopt.dualaxis
SwatheOpt.swatheonly = 1;
SwatheOpt.transp     = 1;
SwatheOpt.alpha      = 0.15;
SwatheOpt.border     = 1;
SwatheOpt.xvec       = steps;

% Detect two-band mode once before the loop
twoband = exist('INF2','var') && exist('SUP2','var');

% Figure visibility: 'off' suppresses display while still allowing saving
if isfield(LPopt,'visible') && LPopt.visible==0; vis='off'; else; vis='on'; end

% Open figure and set size; loop over variables and fill each subplot panel
figure('Visible',vis);
if isempty(LPopt.figsize); FigSize(12*col, 6*row); else; FigSize(LPopt.figsize(1),LPopt.figsize(2)); end
for ii = 1:nvars
    subplot(row,col,ii);

    % Draw confidence bands if provided
    if exist('INF','var') && exist('SUP','var')
        if twoband
            SwatheOpt.alpha = 0.15; SwatheOpt.border = 1;
            PlotSwathe(IR(:,ii),[INF(:,ii) SUP(:,ii)],SwatheOpt); hold on;
            SwatheOpt.alpha = 0.30; SwatheOpt.border = 0;
            H2 = PlotSwathe(IR(:,ii),[INF2(:,ii) SUP2(:,ii)],SwatheOpt); hold on;
            set([H2.swathe],'Visible','off');
        else
            PlotSwathe(IR(:,ii),[INF(:,ii) SUP(:,ii)],SwatheOpt); hold on;
        end
        set(gcf,'renderer','painters')
    end

    % Point estimate line with optional markers
    mk = LPopt.marker;
    if strcmp(mk,'none')
        plot(steps,IR(:,ii),'LineStyle',lstyle,'Color',plotcol,'LineWidth',2); hold on
    else
        plot(steps,IR(:,ii),'LineStyle',lstyle,'Color',plotcol,'LineWidth',2,'Marker',mk,'MarkerSize',7,'MarkerFaceColor',0.5*plotcol+0.5*[1 1 1],'MarkerEdgeColor',plotcol); hold on
    end

    % Zero line
    plot(steps,x_axis,'-k','LineWidth',0.5); hold on

    % x-axis limits: use caller-specified range or auto from steps
    if isfield(LPopt,'xlim') && ~isempty(LPopt.xlim)
        xlim(LPopt.xlim);
    else
        xlim([steps(1) steps(end)]);
    end

    % Optional axis formatting
    if isfield(LPopt,'ylim')  && ~isempty(LPopt.ylim);  ylim(LPopt.ylim);               end
    if isfield(LPopt,'xtick') && ~isempty(LPopt.xtick); set(gca,'XTick',LPopt.xtick);  end

    % Panel title: variable name only if no shock name or shorttitle; else 'var to shock'
    shorttitle = isfield(LPopt,'shorttitle') && LPopt.shorttitle==1;
    if shorttitle || isempty(sname)
        if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} '}']; else; tstr = vnames{ii}; end
    else
        if strcmp(interp,'latex'); tstr = ['\textbf{' vnames{ii} ' to }' sname]; else; tstr = [vnames{ii} ' to ' sname]; end
    end
    title(tstr,'FontWeight','bold','FontSize',14,'Interpreter',interp);
    set(gca,'FontSize',12,'Layer','bottom','TickLabelInterpreter',interp);

    if LPopt.grid; grid on; end

    % Axis labels
    if isfield(LPopt,'xlabel') && ~isempty(LPopt.xlabel); xlabel(LPopt.xlabel); end
    if isfield(LPopt,'ylabel') && ~isempty(LPopt.ylabel); ylabel(LPopt.ylabel); end

    % Disable clipping so markers at the axis boundary render fully
    set(findobj(gca,'Type','line'), 'Clipping', 'off');

    % Dual-axis style: box off, tick marks mirrored on right side
    if LPopt.dualaxis; SetAxesDual(gca); end
end

% Apply font to all text elements in figure before saving
if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end

% Save figure
if quality>=1
    if suptitle==1
        if isempty(sname)
            SupTitle('LP: Impulse Responses')
        else
            SupTitle(['LP: IR to ' sname])
        end
        if ~isempty(fontname); set(findall(gcf,'-property','FontName'),'FontName',fontname); end
    end
    SaveFigure(filename,quality)
elseif quality==0
    print('-dpdf','-r100',filename);
end
