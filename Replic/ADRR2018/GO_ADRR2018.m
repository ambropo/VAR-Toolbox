% Replicates Figure 6 of Antolin-Diaz and Rubio-Ramirez (2018, AER):
% sign restrictions vs. sign + narrative sign restrictions for the Uhlig
% (2005) 6-variable monetary VAR with the October 1979 Volcker episode.
% =======================================================================
% Outputs: comparison plot of IRFs to a contractionary monetary policy
% shock, normalized to a 25bp impact on the federal funds rate at h = 0.
% Requires VAR Toolbox 4.0.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Clear workspace, suppress warnings, and fix the random seed for
% reproducibility of the sign-restriction draws. The working directory is
% set to the script's own folder so that all relative paths resolve correctly.
clear all; close all; clc
warning off all
rng(42, 'twister');

cd(fileparts(mfilename('fullpath')));

% Set LaTeX as the default interpreter for all figure text
set(groot,'defaultTextInterpreter',          'latex')
set(groot,'defaultAxesTickLabelInterpreter', 'latex')
set(groot,'defaultLegendInterpreter',        'latex')

%% 2. LOAD DATA
% -----------------------------------------------------------------------
% Load updated Uhlig dataset (1965m1-2007m11, 515 monthly observations).
% Row 1 of the spreadsheet contains long variable names, row 2 contains
% short names, and rows 3 onward contain date strings and data values.
raw         = readcell('ADRR2018_Data.xlsx', 'Sheet', 'Sheet1');
dates       = raw(3:end, 1);
vnames      = raw(1, 2:end);
mnem        = raw(2, 2:end);
nvar        = length(mnem);
data        = cellfun(@double, raw(3:end, 2:end));

% Store each variable as a named field in the DATA structure
for ii=1:length(mnem)
    DATA.(mnem{ii}) = data(:,ii);
end

% Extract the first observation date (year and month) for later use
year  = str2double(raw{3,1}(1:4));
month = str2double(raw{3,1}(6));
nobs  = size(data, 1);

%% 3. PLOT SERIES
% -----------------------------------------------------------------------
% Plot all six variables over the full sample at monthly frequency to
% inspect the raw data before estimation. Each panel uses DatesPlot to
% label the x-axis and SetAxesDual for consistent axis styling.
firstdate = year + (month-1)/12;
figure;
FigSize(24,18)
for ii = 1:nvar
    subplot(3,2,ii)
    plot(DATA.(mnem{ii}),'LineWidth',3,'Color',pantone('Blue'));
    title(['\textbf{' vnames{ii} '}'],'FontWeight','bold','FontSize',14);
    DatesPlot(firstdate,nobs,6,'m')
    set(gca,'FontSize',12,'Layer','bottom'); grid on;
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('ADRR_Data')

%% 4. VAR ESTIMATION
% -----------------------------------------------------------------------
% Set the lag order to 12 and exclude a constant (detc = 0), following
% footnote 8 of Antolin-Diaz and Rubio-Ramirez (2018, p. 27). Initialise
% the VARopt options struct with defaults; identification-specific options
% are set in Section 5.

nlags = 12;
detc   = 0;

% Initialise options
VARopt = VARoption;
VARopt.mnem = mnem;   % mnemonics name the VAR.(.) sub-structs

%% 5. SIGN RESTRICTION OPTIONS
% -----------------------------------------------------------------------
% Set options governing the sign-restriction algorithm. sr_hor = 6 imposes
% restrictions at horizons 0-5 months. pctg = 68 reports 16th-84th
% percentile credible bands. sr_draw = 500000 provides a generous rotation
% budget to ensure adequate acceptance after the narrative filter reduces it.
% inference = 1 draws from the Bayesian flat-prior posterior, matching the
% paper's conjugate Gibbs sampler. mult = 50 prints a progress message
% every 50 accepted draws.
VARopt.nsteps  = 60;      % 5-year horizon
VARopt.ndraws  = 500;     % paper uses 5000; 500 sufficient for shape
VARopt.sr_hor  = 6;       % restrictions at horizons 0-5 months
VARopt.pctg    = 68;      % 68% credible interval
VARopt.sr_draw = 500000;  % generous budget; narrative filter reduces acceptance rate
VARopt.inference = 1;     % include posterior uncertainty over reduced-form parameters
VARopt.mult    = 50;      % print progress every 50 accepted draws
VARopt.dates   = dates;   % date strings for resolving narrative restriction periods

%% 6. SIGN RESTRICTIONS (BASELINE)
% -----------------------------------------------------------------------
% A contractionary monetary policy shock (column 1 of B) raises the fed
% funds rate and lowers the price level, commodity prices, and non-borrowed
% reserves. Output and total reserves are left unrestricted (Table 3 of
% the paper). Restrictions imposed at horizons 0-5 months.
% Variable order: y(1) pi(2) comm(3) res(4) nbres(5) ff(6)
SIGN = [ 0, 0, 0, 0, 0, 0;   % y:     unrestricted
        -1, 0, 0, 0, 0, 0;   % pi:    falls
        -1, 0, 0, 0, 0, 0;   % comm:  falls
         0, 0, 0, 0, 0, 0;   % res:   unrestricted
        -1, 0, 0, 0, 0, 0;   % nbres: falls
         1, 0, 0, 0, 0, 0];  % ff:    rises

% Run sign restrictions; results stored in SRout
disp('=== Running sign restrictions (baseline) ===')
VARopt.ident = 'sign';
VARopt.R = SIGN;
SRout = VARmodel(data, nlags, detc, VARopt);
disp(['Acceptance rate (sign): ' ...
    num2str(100*SRout.accept_rate,'%.1f') '% of draws accepted'])

%% 7. SIGN + NARRATIVE RESTRICTIONS
% -----------------------------------------------------------------------
% Two narrative restrictions target October 1979 (Volcker reform):
%   NSR 1 (Type 1 - sign of shock): monetary policy shock is positive
%   NSR 2 (Type 2 - dominant shock): monetary policy shock is the
%     overwhelming driver of the unexpected movement in ff in Oct 1979

% Build R struct combining sign matrix with narrative restrictions
R.sign = SIGN;

% narr_sign: mp shock (col 1) positive at October 1979 (Type 1)
R.narr_sign.shock  = 1;
R.narr_sign.period = '1979m10';
R.narr_sign.sign   = 1;

% narr_dom: mp shock is dominant driver of ff (var 6) at October 1979 (Type 2)
R.narr_dom.shock  = 1;
R.narr_dom.period = '1979m10';
R.narr_dom.var    = 6;

% Run sign + narrative restrictions; results stored in NSRout
disp('=== Running sign + narrative restrictions ===')
VARopt.R = R;
NSRout = VARmodel(data, nlags, detc, VARopt);
disp(['Acceptance rate (sign + narrative): ' ...
    num2str(100*NSRout.accept_rate,'%.1f') '% of draws accepted'])

%% 8. NORMALIZE IRFs TO 25bp IMPACT ON FED FUNDS RATE
% -----------------------------------------------------------------------
% Normalization follows Plot_IRFs_Monetary.m from the paper's replication
% code: one scalar per model = 0.25 / median(IRF of ff at h=0), applied
% to all draws before computing percentiles. Resulting units: ff in basis
% points (25bp at h=0 by construction); all other variables in
% log-points x 100 = percent.
ff_var   = 6;   % ff is variable 6
mp_shock = 1;   % monetary policy shock is column 1

% Percentile values for 68% credible bands
pctg_inf_val = (100 - VARopt.pctg) / 2;
pctg_sup_val = 100 - pctg_inf_val;

% Scale baseline draws and compute median and 68% bands
scale_SR   = (0.25 / median(squeeze(SRout.IRall(1, ff_var, mp_shock, :)))) * 100;
IRall_SR_n = SRout.IRall * scale_SR;
IRmed_SR   = median(IRall_SR_n, 4);
aux        = prctile(IRall_SR_n, [pctg_inf_val pctg_sup_val], 4);
IRinf_SR   = aux(:,:,:,1);
IRsup_SR   = aux(:,:,:,2);

% Scale narrative draws and compute median and 68% bands
scale_NSR   = (0.25 / median(squeeze(NSRout.IRall(1, ff_var, mp_shock, :)))) * 100;
IRall_NSR_n = NSRout.IRall * scale_NSR;
IRmed_NSR   = median(IRall_NSR_n, 4);
aux          = prctile(IRall_NSR_n, [pctg_inf_val pctg_sup_val], 4);
IRinf_NSR   = aux(:,:,:,1);
IRsup_NSR   = aux(:,:,:,2);

%% 9. COMPARISON PLOT
% -----------------------------------------------------------------------
% Replicates Figure 6 of Antolin-Diaz and Rubio-Ramirez (2018, AER).
% Layout: 2 rows x 3 columns. Blue swathe = sign restrictions only;
% red swathe = sign + narrative restrictions. 68% credible bands.

%....... NOTES TO FIG/TAB .......
% Figure 6, Antolin-Diaz and Rubio-Ramirez (2018, AER). Impulse responses
% to a contractionary monetary policy shock identified by sign restrictions
% alone (blue) versus sign + narrative restrictions (red). 68% credible
% bands. Normalization: 25bp impact on ff at h = 0 by construction.
% Variables: (1) Real GDP, (2) GDP Deflator, (3) Commodity Prices,
% (4) Total Reserves, (5) Non-Borrowed Reserves, (6) Fed Funds Rate.
% Sample: 1965m1-2007m11; 12 lags; no constant.
%..................................

% Blue swathe for sign-only: light alpha, dashed border, no central line
SwatheOpt_SR = PlotSwatheOption;
SwatheOpt_SR.swathecol   = pantone('Blue');
SwatheOpt_SR.swatheonly  = 1;
SwatheOpt_SR.transp      = 1;
SwatheOpt_SR.alpha       = 0.15;
SwatheOpt_SR.border      = 1;
SwatheOpt_SR.borderstyle = '--';
SwatheOpt_SR.dualaxis    = 0;   % two swathes overlaid per panel; dual-axis
                                % applied once below via SetAxesDual(gca)

% Red swathe for sign + narrative: darker alpha, dash-dot border, no central line
SwatheOpt_NSR = PlotSwatheOption;
SwatheOpt_NSR.swathecol   = pantone('Tomato');
SwatheOpt_NSR.swatheonly  = 1;
SwatheOpt_NSR.transp      = 1;
SwatheOpt_NSR.alpha       = 0.30;
SwatheOpt_NSR.border      = 1;
SwatheOpt_NSR.borderstyle = '-.';
SwatheOpt_NSR.dualaxis    = 0;   % see SwatheOpt_SR

% Open figure and loop over the six variables to build the 2x3 panel
figure
FigSize(24, 18)
for ii = 1:nvar
    subplot(3, 2, ii)

    % Swathes first (bottom layer)
    PlotSwathe(IRmed_SR(:,ii,mp_shock), ...
        [IRinf_SR(:,ii,mp_shock) IRsup_SR(:,ii,mp_shock)], SwatheOpt_SR);
    hold on
    PlotSwathe(IRmed_NSR(:,ii,mp_shock), ...
        [IRinf_NSR(:,ii,mp_shock) IRsup_NSR(:,ii,mp_shock)], SwatheOpt_NSR);

    % Switch to painters so marker fill renders consistently with the swathes
    set(gcf, 'renderer', 'painters')

    % Median lines with markers on top
    H1 = plot(IRmed_SR(:,ii,mp_shock), 'LineStyle', '-', 'Color', pantone('Blue'), ...
        'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 7, ...
        'MarkerFaceColor', 0.5*pantone('Blue')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Blue'));
    H2 = plot(IRmed_NSR(:,ii,mp_shock), 'LineStyle', '-', 'Color', pantone('Tomato'), ...
        'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 7, ...
        'MarkerFaceColor', 0.5*pantone('Tomato')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Tomato'));

    % Zero line
    plot(zeros(1, VARopt.nsteps), '-k', 'LineWidth', 0.5)
    xlim([1 VARopt.nsteps])

    % Set title and axis style for the current panel
    title(['\textbf{' vnames{ii} '}'], 'FontWeight', 'bold', 'FontSize', 14)
    set(gca, 'FontSize', 12, 'Layer', 'bottom'); grid on

    % Label y-axis in basis points for ff; percent for all other variables
    if ii == ff_var
        ylabel('Basis points')
    else
        ylabel('Percent')
    end

    % Add legend to the last panel only to avoid clutter
    if ii == nvar
        legend([H1 H2], {'Sign only', 'Sign + Narrative'}, ...
               'Location', 'best')
    end
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('ADRR_Fig6')


% Figure for slide deck
figure
FigSize(24, 12)
for ii = 1:nvar
    subplot(2, 3, ii)

    % Swathes first (bottom layer)
    PlotSwathe(IRmed_SR(:,ii,mp_shock), ...
        [IRinf_SR(:,ii,mp_shock) IRsup_SR(:,ii,mp_shock)], SwatheOpt_SR);
    hold on
    PlotSwathe(IRmed_NSR(:,ii,mp_shock), ...
        [IRinf_NSR(:,ii,mp_shock) IRsup_NSR(:,ii,mp_shock)], SwatheOpt_NSR);

    % Switch to painters so marker fill renders consistently with the swathes
    set(gcf, 'renderer', 'painters')

    % Median lines with markers on top
    H1 = plot(IRmed_SR(:,ii,mp_shock), 'LineStyle', '-', 'Color', pantone('Blue'), ...
        'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 7, ...
        'MarkerFaceColor', 0.5*pantone('Blue')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Blue'));
    H2 = plot(IRmed_NSR(:,ii,mp_shock), 'LineStyle', '-', 'Color', pantone('Tomato'), ...
        'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 7, ...
        'MarkerFaceColor', 0.5*pantone('Tomato')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Tomato'));

    % Zero line
    plot(zeros(1, VARopt.nsteps), '-k', 'LineWidth', 0.5)
    xlim([1 VARopt.nsteps])

    % Set title and axis style for the current panel
    title(['\textbf{' vnames{ii} '}'], 'FontWeight', 'bold', 'FontSize', 14)
    set(gca, 'FontSize', 12, 'Layer', 'bottom'); grid on

    % Label y-axis in basis points for ff; percent for all other variables
    if ii == ff_var
        ylabel('Basis points')
    else
        ylabel('Percent')
    end

    % Add legend to the last panel only to avoid clutter
    if ii == nvar
        legend([H1 H2], {'Sign only', 'Sign + Narrative'}, ...
               'Location', 'best')
    end
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('ADRR_Fig6_slides')

%% 10. SHOCK DISTRIBUTION AT OCTOBER 1979
% -----------------------------------------------------------------------
% Compares the distribution of the monetary policy shock at October 1979
% across accepted draws: sign restrictions only (blue) vs. sign + narrative
% restrictions (red). Under sign-only, the shock can be positive or
% negative; under sign + narrative, Type 1 forces e > 0 and Type 2 forces
% it to be the dominant driver of ff — concentrating mass on large
% positive values.

%....... NOTES TO FIG/TAB .......
% Distribution of the structural monetary policy shock e(t*, j) at
% October 1979 (t* = t_narr) across accepted draws. Blue histogram: sign
% restrictions only. Red histogram: sign + narrative restrictions. The
% shock is computed as e = inv(B)*u using OLS residuals u and each
% accepted B; units are structural shock units (not normalized to 25bp).
%..................................

% Residual-sample index for October 1979: dates is aligned with raw
% observations (nobs rows), but residuals have nlags fewer rows, so the
% index into the residual array is the date position minus nlags
t_narr = find(strcmp(dates, '1979m10')) - nlags;

% Collect shock at t_narr across all accepted SR draws
ndraws_SR  = size(SRout.Ball, 3);
shocks_SR  = zeros(ndraws_SR, 1);
for dd = 1:ndraws_SR
    e_d = SRout.Ball(:,:,dd) \ SRout.resid';   % nvar x nobs structural shocks
    shocks_SR(dd) = e_d(mp_shock, t_narr);
end

% Collect shock at t_narr across all accepted NSR draws
ndraws_NSR  = size(NSRout.Ball, 3);
shocks_NSR  = zeros(ndraws_NSR, 1);
for dd = 1:ndraws_NSR
    e_d = NSRout.Ball(:,:,dd) \ NSRout.resid';
    shocks_NSR(dd) = e_d(mp_shock, t_narr);
end

% Plot overlapping histograms
figure
FigSize(12, 6)
histogram(shocks_SR, 30, 'FaceColor', pantone('Blue'), 'FaceAlpha', 0.5, 'EdgeColor', 'white')
hold on
histogram(shocks_NSR, 30, 'FaceColor', pantone('Tomato'), 'FaceAlpha', 0.5, 'EdgeColor', 'white')

% Vertical zero line marks the boundary imposed by the Type 1 narrative restriction
xline(0, '--k', 'LineWidth', 0.5)
xlabel('Monetary policy shock')
ylabel('Count')
title('\textbf{Shock distribution at October 1979 (Volcker reform)}', 'FontWeight', 'bold')
legend({'Sign only', 'Sign + Narrative'}, 'Location', 'best')
set(gca,'Layer','bottom');
set(findobj(gca,'Type','line'),'Clipping','off');
SetAxesDual(gca);

% Save figure
SaveFigure('ADRR_Fig5')
