% Replicates Figure 1 and Table 1.B of Stock and Watson (2001, JEP):
% Cholesky identification of monetary policy shocks in a trivariate VAR
% for inflation, unemployment, and the federal funds rate.
% =======================================================================
% Outputs: toolbox IRF and FEVD plots; OLS coefficient table; Table 1.B
% (variance decomposition at horizons 1,4,8,12) printed to screen.
% Requires VAR Toolbox 4.0.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2020. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Clear workspace, close figures, and suppress warnings. Set the random
% seed for reproducibility. Change the working directory to the folder
% containing this script so that data files and figure paths resolve
% correctly regardless of the MATLAB working directory at launch.
clear all; close all; clc
warning off all
rng(42, 'twister');

cd(fileparts(mfilename('fullpath')));

% Set LaTeX as the default interpreter for all figure text
set(groot,'defaultTextInterpreter',          'latex')
set(groot,'defaultAxesTickLabelInterpreter', 'latex')
set(groot,'defaultLegendInterpreter',        'latex')

% Helper for bold epsilon shock labels in figure text
bfeps = @(s) ['${\bf \epsilon}_{t}^{\mathrm{' s '}}$'];

%% 2. LOAD DATA
% -----------------------------------------------------------------------
% Load the Stock and Watson (2001) quarterly dataset from Excel. readcell
% imports the full spreadsheet as a cell array (raw). Row 1 holds long
% variable names; row 2 holds short mnemonics; rows 3 onward hold
% quarterly date strings and data. Each variable is stored as a named
% field in DATA for convenient downstream access.
raw         = readcell('SW2001_Data.xlsx', 'Sheet', 'Sheet1');
data        = cellfun(@double, raw(3:end, 2:end));
X           = data; % data matrix passed to VARmodel
dates       = raw(3:end, 1);
vnames      = raw(1, 2:end);
mnem        = raw(2, 2:end);
nvar        = length(mnem);

% Store each variable as a named field in the DATA structure
for ii=1:length(mnem)
    DATA.(mnem{ii}) = data(:,ii);
end

% Extract the first observation date (year and quarter) for later use
year    = str2double(raw{3,1}(1:4));
quarter = str2double(raw{3,1}(6));

% Observations
nobs = size(data,1);

%% 3. PLOT SERIES
% -----------------------------------------------------------------------
% Plot all three endogenous variables over the full sample at quarterly
% frequency. firstdate encodes the first observation as a decimal year
% (e.g. 1960.25 for 1960Q2). DatesPlot sets x-axis tick labels;
% SetAxesDual applies the toolbox dual-spine axis style. The figure is
% saved to SW_Data before proceeding to estimation.
firstdate = year + (quarter-1)/4;
figure;
FigSize(12,18)
for ii = 1:nvar
    subplot(3,1,ii)
    plot(DATA.(mnem{ii}),'LineWidth',3,'Color',pantone('Blue'));
    title(['\textbf{' vnames{ii} '}'],'FontWeight','bold','FontSize',14);
    DatesPlot(firstdate,nobs,6,'q')
    set(gca,'FontSize',12,'Layer','bottom'); grid on;
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('SW_Data')

%% 4. VAR ESTIMATION
% -----------------------------------------------------------------------
% Estimate the trivariate VAR by OLS with 4 lags and a constant (detc = 1).
% Stock and Watson (2001) specify a quarterly VAR with 4 lags (p. 112).
% This call is reduced-form only — no identification scheme is set.
% VARmodel returns the companion matrix F, the residual covariance sigma,
% and estimated residuals. VARprint displays OLS coefficient estimates and
% returns the raw beta matrix with standard errors.
detc = 1;
nlags = 4;

% Initialise options and estimate VAR by OLS (reduced form only)
VARopt = VARoption;
VARopt.mnem   = mnem;   % mnemonics name the VAR.(.) sub-structs
VARopt.vnames = mnem;   % short headers for the coefficient table
VAR = VARmodel(X,nlags,detc,VARopt);

% Print OLS coefficient table on screen
[TABLE, beta] = VARprint(VAR,VARopt,2);

%% 5. COMPUTE IRF AND FEVD
% -----------------------------------------------------------------------
% Compute impulse responses (IRFs) and forecast error variance
% decompositions (FEVD) under Cholesky (short-run recursive) identification
% with bootstrap error bands. Setting inference = 1 activates wild-bootstrap
% inference; ndraws = 500 replications. A single VARmodel call returns
% IRmed, IRinf, IRsup (pointwise bootstrap median and error bands) and
% VDmed, VD (pointwise and draw-level FEVD). VARirplot plots all IRFs;
% VARvdplot produces the FEVD as a stacked bar chart.

% Set IRF/FEVD options: Cholesky identification, 24-quarter horizon,
% standard bootstrap inference (500 draws), long variable names
VARopt.nsteps = 24;
VARopt.ident = 'short';
VARopt.ndraws = 500;
VARopt.inference = 1;
VARopt.vnames = vnames;
VARopt.firstdate = firstdate;
VARopt.frequency = 'q';
VARopt.snames = {bfeps('\pi'),bfeps('u'),bfeps('i')};
VARopt.figsize = [24,6];
VARopt.subplot = [1,3];

% Compute IRFs and FEVD with bootstrap error bands in a single call
VAR = VARmodel(X,nlags,detc,VARopt);

% Plot impulse responses — toolbox standard 3x3 grid (variable x shock)

%....... NOTES TO FIG/TAB .......
% All 9 IRFs (3 variables x 3 Cholesky shocks) with bootstrap confidence
% bands. Recursive identification; variable order: unemployment,
% inflation, federal funds rate. Replicates Figure 1 of Stock and
% Watson (2001).
%..................................
VARopt.figname = 'SW_Fig1';
VARirplot(VAR.IRbar,VARopt,VAR.IRinf,VAR.IRsup);

% Plot FEVD — toolbox standard bar chart (one panel per variable)
%....... NOTES TO FIG/TAB .......
% FEVD bar chart for all 3 variables over 24 quarters, decomposed by
% Cholesky shock. Toolbox standard output; same identification as IRF.
%..................................
VARopt.figname = 'SW_VD';
VARvdplot(VAR.VDbar,VARopt);

%% 6. PRINT TABLE 1.B ON SCREEN
% -----------------------------------------------------------------------
% Assemble the variance decomposition at horizons 1, 4, 8, and 12 quarters
% for each endogenous variable. VAR.VD is an (nsteps x nvar x nvar)
% array; the third index selects the variable. Rows of FEVD_Table are
% indexed by horizon; columns give each shock's contribution to the
% selected variable's forecast-error variance. The three printed blocks
% replicate Table 1.B of Stock and Watson (2001).
FEVD_Table(1, :) = VAR.VD(1,:,1);
FEVD_Table(2, :) = VAR.VD(4,:,1);
FEVD_Table(3, :) = VAR.VD(8,:,1);
FEVD_Table(4, :) = VAR.VD(12,:,1);

% Rows 5–8: FEVD for the second variable (inflation)
FEVD_Table(5, :) = VAR.VD(1,:,2);
FEVD_Table(6, :) = VAR.VD(4,:,2);
FEVD_Table(7, :) = VAR.VD(8,:,2);
FEVD_Table(8, :) = VAR.VD(12,:,2);

% Rows 9–12: FEVD for the third variable (federal funds rate)
FEVD_Table(9, :) = VAR.VD(1,:,3);
FEVD_Table(10,:) = VAR.VD(4,:,3);
FEVD_Table(11,:) = VAR.VD(8,:,3);
FEVD_Table(12,:) = VAR.VD(12,:,3);

% Print each block on screen

%....... NOTES TO FIG/TAB .......
% Table 1.B, Stock and Watson (2001, JEP). Variance decomposition at
% horizons 1, 4, 8, 12 quarters, printed to screen for each endogenous
% variable in turn. Rows = horizons; columns = each shock's contribution
% to the selected variable's forecast-error variance. Cholesky
% identification; variable order: unemployment, inflation, federal funds
% rate.
%..................................
disp(' ')
disp('Variance Decomposition of Unemployment (t=1,4,8,12)')
disp('---------------------------------------------------')
disp(FEVD_Table(1:4,:));
disp('Variance Decomposition of Inflation (t=1,4,8,12)')
disp('---------------------------------------------------')
disp(FEVD_Table(5:8,:));
disp('Variance Decomposition of Fed Funds (t=1,4,8,12)')
disp('---------------------------------------------------')
disp(FEVD_Table(9:12,:));
