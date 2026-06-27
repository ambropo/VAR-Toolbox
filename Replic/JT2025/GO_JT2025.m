% Replicates Figure 5a and Figure 6a of Jordà and Taylor (2025, JEL):
% LP and LP-IV impulse responses to a monetary policy shock.
% =======================================================================
% Figure 5a: LP-OLS response of log CPI (x100) to a unit Romer-Romer
%   shock (quarterly, 1985Q1-2007Q4, 18-horizon). Plotted with 68% and
%   95% Newey-West confidence bands.
% Figure 6a: LP-IV response of the unemployment rate to a unit federal
%   funds rate shock, instrumented by the Romer-Romer shock
%   (monthly, 1985M1-2000M1, 49-horizon). Plotted with 68% and 95%
%   Newey-West confidence bands.
% Requires VAR Toolbox 4.0 and LPmodel with longdiff and IV support.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% May 2025. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Clear workspace, suppress warnings, and fix the random seed for
% reproducibility. The working directory is set to the script's own folder
% so that all relative file paths resolve correctly.
clear all; close all; clc
warning off all
rng(42, 'twister');

cd(fileparts(mfilename('fullpath')));

% Apply LaTeX interpreter to all figure text in this session
set(groot,'defaultTextInterpreter',          'latex')
set(groot,'defaultAxesTickLabelInterpreter', 'latex')
set(groot,'defaultLegendInterpreter',        'latex')

%% 2. LP-OLS ESTIMATION: CPI RESPONSE TO ROMER-ROMER SHOCK
% -----------------------------------------------------------------------
% LP-OLS of log CPI (x100) on the Romer-Romer shock (quarterly,
% 1985Q1-2007Q4). LHS is the long-difference lcpi_{t+h} - lcpi_{t-1}.
% Controls: 4 lags of dlrgdp, dlcpi, dstir. NW bandwidth = h-1.

% Load quarterly data from Ex5 tab; variables follow toolbox header format
xlstext_OLS = readcell('JT2025_Data.xlsx',   'Sheet', 'Ex5');
data_OLS   = readmatrix('JT2025_Data.xlsx', 'Sheet', 'Ex5', 'Range', 'B3');
dates_OLS  = xlstext_OLS(3:end,1);
vnames_OLS = xlstext_OLS(1,2:end);
mnem_OLS   = xlstext_OLS(2,2:end);
nobs_OLS   = size(data_OLS,1);

% Store each variable as a named field in DATA_OLS
for ii = 1:length(mnem_OLS)
    DATA_OLS.(mnem_OLS{ii}) = data_OLS(:,ii);
end

% Parse quarterly dates (format: '1960q1') and restrict to 1985Q1-2007Q4
year_OLS = zeros(nobs_OLS,1);
qtr_OLS  = zeros(nobs_OLS,1);
for ii = 1:nobs_OLS
    dstr = dates_OLS{ii};
    qpos = strfind(dstr,'q');
    year_OLS(ii) = str2double(dstr(1:qpos-1));
    qtr_OLS(ii)  = str2double(dstr(qpos+1:end));
end
idx_OLS_start = find(year_OLS == 1985 & qtr_OLS == 1);
idx_OLS_end   = find(year_OLS == 2007 & qtr_OLS == 4);

% Plot only the variables used in the LP-OLS regression (outcome, shock, controls
% except dlcpi which is excluded per user request): lcpi, rr_shock, dlrgdp, dstir
plot_OLS_vars = {'lcpi','rr_shock','dlrgdp','dstir'};
plot_OLS_long = cellfun(@(v) vnames_OLS{strcmp(mnem_OLS,v)}, plot_OLS_vars, 'UniformOutput', false);
firstdate_OLS = year_OLS(1) + (qtr_OLS(1)-1)/4;
figure;
FigSize(24,12)
for ii = 1:length(plot_OLS_vars)
    subplot(2,2,ii)
    plot(DATA_OLS.(plot_OLS_vars{ii}),'LineWidth',3,'Color',pantone('Blue'));
    title(['\textbf{' plot_OLS_long{ii} '}'],'FontWeight','bold','FontSize',14);
    DatesPlot(firstdate_OLS,nobs_OLS,6,'q')
    set(gca,'FontSize',12,'Layer','bottom'); grid on;
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('JT_Data_OLS')

% Extract sample variables; scale lcpi to percent
lcpi     = 100 * DATA_OLS.lcpi(idx_OLS_start:idx_OLS_end);
rr_shock = DATA_OLS.rr_shock(idx_OLS_start:idx_OLS_end);
dlrgdp   = DATA_OLS.dlrgdp(idx_OLS_start:idx_OLS_end);
dlcpi    = DATA_OLS.dlcpi(idx_OLS_start:idx_OLS_end);
dstir    = DATA_OLS.dstir(idx_OLS_start:idx_OLS_end);

% Set LP options and run LP-OLS estimation
LPopt_OLS          = LPoption;
LPopt_OLS.nsteps   = 18;
LPopt_OLS.longdiff = 1;
LPopt_OLS.impact   = 1;
LPopt_OLS.pctg     = 95;
LPopt_OLS.IV       = [];

% Assemble control matrix and run LP-OLS; extract point estimates and bands
CTRL_OLS = [dlrgdp dlcpi dstir];
LP_OLS   = LPmodel(lcpi, rr_shock, CTRL_OLS, 4, 1, LPopt_OLS);
IR_OLS     = LP_OLS.IR;
INF95_OLS  = LP_OLS.INF;
SUP95_OLS  = LP_OLS.SUP;

% Derive 68% bands by rescaling the 95% bands via Normal quantile ratio
c95 = norminv(0.975);
c68 = norminv(0.84);
INF68_OLS = IR_OLS - (IR_OLS - INF95_OLS) * (c68/c95);
SUP68_OLS = IR_OLS + (SUP95_OLS - IR_OLS) * (c68/c95);

% Set display options (figure produced in section 4)
%....... NOTES TO FIG/TAB .......
% Figure 5a, Jordà and Taylor (2025, JEL). LP-OLS impulse response of
% log CPI (x100) to a unit Romer-Romer monetary policy shock. LHS:
% cumulative change lcpi_{t+h} - lcpi_{t-1}. Controls: 4 lags of
% dlrgdp, dlcpi, dstir. Sample: 1985Q1-2007Q4. Green shading: 95%
% (light) and 68% (dark) Newey-West confidence bands.
%..................................
LPopt_OLS.vnames   = {'CPI'};
LPopt_OLS.snames   = {'Romer-Romer shock'};
LPopt_OLS.color    = cmap(4);
LPopt_OLS.marker   = 'none';
LPopt_OLS.hstart   = 0;
LPopt_OLS.xtick    = 0:5:15;
LPopt_OLS.xlim     = [0 17];
LPopt_OLS.ylim     = [-6 2];
LPopt_OLS.ylabel   = 'Percent';

%% 3. LP-IV ESTIMATION: UNEMPLOYMENT RESPONSE TO FFR SHOCK
% -----------------------------------------------------------------------
% LP-IV of unemployment on the FFR, instrumented by the Romer-Romer RRCG
% shock (monthly, 1985M1-2000M1). LHS: urate_{t+h} - urate_{t-1}.
% Controls: 6 lags of urate, infl, ffr. Instruments: RRCGShock and 6 lags.

% Load monthly data from Ex6 tab
xlstext_IV = readcell('JT2025_Data.xlsx',   'Sheet', 'Ex6');
data_IV   = readmatrix('JT2025_Data.xlsx', 'Sheet', 'Ex6', 'Range', 'B3');
dates_IV  = xlstext_IV(3:end,1);
vnames_IV = xlstext_IV(1,2:end);
mnem_IV   = xlstext_IV(2,2:end);
nobs_IV   = size(data_IV,1);

% Store each variable as a named field in DATA_IV
for ii = 1:length(mnem_IV)
    DATA_IV.(mnem_IV{ii}) = data_IV(:,ii);
end

% Parse monthly dates (format: '1965m12') and restrict to 1985M1-2000M1
year_IV = zeros(nobs_IV,1);
mon_IV  = zeros(nobs_IV,1);
for ii = 1:nobs_IV
    dstr = dates_IV{ii};
    mpos = strfind(dstr,'m');
    year_IV(ii) = str2double(dstr(1:mpos-1));
    mon_IV(ii)  = str2double(dstr(mpos+1:end));
end
idx_IV_start = find(year_IV == 1985 & mon_IV == 1);
idx_IV_end   = find(year_IV == 2000 & mon_IV == 1);

% Plot only the variables used in the LP-IV regression (outcome, controls,
% endogenous treatment, instrument): urate, infl, ffr, RRCGShock
plot_IV_vars = {'urate','infl','ffr','RRCGShock'};
plot_IV_long = cellfun(@(v) vnames_IV{strcmp(mnem_IV,v)}, plot_IV_vars, 'UniformOutput', false);
firstdate_IV = year_IV(1) + (mon_IV(1)-1)/12;
figure;
FigSize(24,12)
for ii = 1:length(plot_IV_vars)
    subplot(2,2,ii)
    plot(DATA_IV.(plot_IV_vars{ii}),'LineWidth',3,'Color',pantone('Blue'));
    title(['\textbf{' plot_IV_long{ii} '}'],'FontWeight','bold','FontSize',14);
    DatesPlot(firstdate_IV,nobs_IV,6,'m')
    set(gca,'FontSize',12,'Layer','bottom'); grid on;
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('JT_Data_IV')

% Extract sample variables
urate     = DATA_IV.urate(idx_IV_start:idx_IV_end);
infl      = DATA_IV.infl(idx_IV_start:idx_IV_end);
ffr       = DATA_IV.ffr(idx_IV_start:idx_IV_end);
RRCGShock = DATA_IV.RRCGShock(idx_IV_start:idx_IV_end);

% Set LP-IV options and run estimation
% S = ffr (endogenous treatment); LPopt_IV.IV = RRCGShock (external instrument)
% nlag_iv = 6 adds lags 1-6 of RRCGShock as extra instruments, matching
% Stata: instruments(rz l(1/6).rz) wmatrix(unadjusted) twostep
LPopt_IV          = LPoption;
LPopt_IV.nsteps   = 49;
LPopt_IV.longdiff = 1;
LPopt_IV.impact   = 1;
LPopt_IV.pctg     = 95;
LPopt_IV.IV       = RRCGShock;
LPopt_IV.nlag_iv  = 6;

% Assemble control matrix and run LP-IV; extract point estimates and bands
CTRL_IV = [urate infl ffr];
LP_IV   = LPmodel(urate, ffr, CTRL_IV, 6, 1, LPopt_IV);
IR_IV     = LP_IV.IR;
INF95_IV  = LP_IV.INF;
SUP95_IV  = LP_IV.SUP;

% Derive 68% bands
INF68_IV = IR_IV - (IR_IV - INF95_IV) * (c68/c95);
SUP68_IV = IR_IV + (SUP95_IV - IR_IV) * (c68/c95);

% Set display options (figure produced in section 4)
%....... NOTES TO FIG/TAB .......
% Figure 6a, Jordà and Taylor (2025, JEL). LP-IV impulse response of the
% unemployment rate to a unit 1pp FFR shock, instrumented by the RRCG
% shock (Romer and Romer, 2004, as used by Jordà and Taylor, 2025). LHS:
% cumulative change urate_{t+h} - urate_{t-1}. Controls: 6 lags of urate,
% infl, ffr. Instruments: RRCGShock and 6 lags (overidentified, 2SLS). Sample:
% 1985M1-2000M1. Blue shading: 95% (light) and 68% (dark) NW bands.
%..................................
LPopt_IV.vnames    = {'Unemployment rate'};
LPopt_IV.snames    = {'FFR shock (LP-IV)'};
LPopt_IV.color     = pantone('Blue_Dark');
LPopt_IV.marker    = 'none';
LPopt_IV.hstart    = 0;
LPopt_IV.xtick     = 0:12:48;
LPopt_IV.xlim      = [0 48];
LPopt_IV.ylim      = [-1 2.65];
LPopt_IV.ylabel    = 'Percentage points';

%% 4. FIGURE 1: COMBINED LP-OLS AND LP-IV IMPULSE RESPONSES
% -----------------------------------------------------------------------
% Side-by-side subplot: left panel is the LP-OLS CPI response (Ex5),
% right panel is the LP-IV unemployment response (Ex6). Both use
% Newey-West bands at 95% (light) and 68% (dark).

% x-axis vectors (hstart = 0 for both)
steps_OLS = LPopt_OLS.hstart : 1 : LPopt_OLS.hstart + LPopt_OLS.nsteps - 1;
steps_IV  = LPopt_IV.hstart  : 1 : LPopt_IV.hstart  + LPopt_IV.nsteps  - 1;

% Shared swathe options; swathecol and xvec are updated per panel
SwatheOpt            = PlotSwatheOption;
SwatheOpt.swatheonly = 1;
SwatheOpt.transp     = 1;
SwatheOpt.dualaxis   = 0;   % 95% and 68% swathes overlaid per panel; dual-axis
                            % applied once below via SetAxesDual(gca)

% Open figure and set dimensions
figure;
FigSize(24,6)

% Panel 1: LP-OLS — CPI response to Romer-Romer shock
subplot(1,2,1)
SwatheOpt.swathecol = LPopt_OLS.color;
SwatheOpt.xvec      = steps_OLS;
SwatheOpt.alpha = 0.15; SwatheOpt.border = 1;
PlotSwathe(IR_OLS, [INF95_OLS SUP95_OLS], SwatheOpt); hold on
SwatheOpt.alpha = 0.30; SwatheOpt.border = 0;
H2 = PlotSwathe(IR_OLS, [INF68_OLS SUP68_OLS], SwatheOpt); hold on
set([H2.swathe], 'Visible', 'off');
set(gcf, 'renderer', 'painters')
plot(steps_OLS, IR_OLS, '-', 'Color', LPopt_OLS.color, 'LineWidth', 2); hold on
plot(steps_OLS, zeros(1, LPopt_OLS.nsteps), '-k', 'LineWidth', 0.5);
xlim(LPopt_OLS.xlim); ylim(LPopt_OLS.ylim); set(gca, 'XTick', LPopt_OLS.xtick);
title(['\textbf{' LPopt_OLS.vnames{1} ' to ' LPopt_OLS.snames{1} '}'], 'FontWeight', 'bold', 'FontSize', 14, 'Interpreter', 'latex')
ylabel(LPopt_OLS.ylabel); grid on;
set(gca, 'FontSize', 12, 'Layer', 'bottom', 'TickLabelInterpreter', 'latex')
set(findobj(gca, 'Type', 'line'), 'Clipping', 'off');
SetAxesDual(gca)

% Panel 2: LP-IV — unemployment response to FFR shock
subplot(1,2,2)
SwatheOpt.swathecol = LPopt_IV.color;
SwatheOpt.xvec      = steps_IV;
SwatheOpt.alpha = 0.15; SwatheOpt.border = 1;
PlotSwathe(IR_IV, [INF95_IV SUP95_IV], SwatheOpt); hold on
SwatheOpt.alpha = 0.30; SwatheOpt.border = 0;
H2 = PlotSwathe(IR_IV, [INF68_IV SUP68_IV], SwatheOpt); hold on
set([H2.swathe], 'Visible', 'off');
set(gcf, 'renderer', 'painters')
plot(steps_IV, IR_IV, '-', 'Color', LPopt_IV.color, 'LineWidth', 2); hold on
plot(steps_IV, zeros(1, LPopt_IV.nsteps), '-k', 'LineWidth', 0.5);
xlim(LPopt_IV.xlim); ylim(LPopt_IV.ylim); set(gca, 'XTick', LPopt_IV.xtick);
title(['\textbf{' LPopt_IV.vnames{1} ' to }' LPopt_IV.snames{1}], 'FontWeight', 'bold', 'FontSize', 14, 'Interpreter', 'latex')
ylabel(LPopt_IV.ylabel); grid on;
set(gca, 'FontSize', 12, 'Layer', 'bottom', 'TickLabelInterpreter', 'latex')
set(findobj(gca, 'Type', 'line'), 'Clipping', 'off');
SetAxesDual(gca)

% Apply uniform font and save figure
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Helvetica')
SaveFigure('JT_Fig5a_6a')
