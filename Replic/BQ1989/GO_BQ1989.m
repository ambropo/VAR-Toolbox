% Replicates Figure 2 (page 662) of Blanchard and Quah (1989, AER):
% long-run identification of supply and demand shocks in a bivariate VAR
% for US GNP growth and the unemployment rate.
% =======================================================================
% Outputs: toolbox IRF plot (all 4 responses with bootstrap bands) and a
% custom Figure 2 replication plot (cumulative GNP and unemployment).
% Requires VAR Toolbox 4.0.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2020. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Clear the workspace, close all figures, and fix the random seed for
% reproducibility of bootstrap inference. The working directory is set to
% the script's own folder so that all relative file paths resolve correctly.
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
% Load the Blanchard-Quah (1989) quarterly dataset from Excel. The DATA
% struct stores each series keyed by its mnemonic. The first observation
% date is extracted from raw for use in date-axis labelling.

raw         = readcell('BQ1989_Data.xlsx', 'Sheet', 'Sheet1');
dates       = raw(3:end, 1);
vnames      = raw(1, 2:end);
mnem        = raw(2, 2:end);
nvar        = length(mnem);
data        = cellfun(@double, raw(3:end, 2:end));

% Store each variable as a named field in the DATA structure
for ii=1:length(mnem)
    DATA.(mnem{ii}) = data(:,ii);
end

% Extract the first observation date (year and quarter) for later use
year    = str2double(raw{3,1}(1:4));
quarter = str2double(raw{3,1}(6));

% Observations and data matrix passed to the VAR
nobs = size(data,1);
X = data;

%% 3. PLOT SERIES
% -----------------------------------------------------------------------
% Plot both variables (GNP growth and unemployment rate) over the full
% sample at quarterly frequency. DatesPlot sets the x-axis tick labels;
% SetAxesDual applies the toolbox dual-spine axis style. The figure is
% saved to BQ_Data before proceeding to estimation.

firstdate = year + (quarter-1)/4;
figure;
FigSize(12,12)
for ii = 1:nvar
    subplot(2,1,ii)
    plot(DATA.(mnem{ii}),'LineWidth',3,'Color',pantone('Blue'));
    title(['\textbf{' vnames{ii} '}'],'FontWeight','bold','FontSize',14);
    DatesPlot(firstdate,nobs,6,'q')
    set(gca,'FontSize',12,'Layer','bottom'); grid on;
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('BQ_Data')

%% 4. VAR ESTIMATION
% -----------------------------------------------------------------------
% Estimate a bivariate reduced-form VAR with 8 lags and a constant by
% OLS. Blanchard and Quah (1989, fn. 3, p. 659) specify 8 quarterly lags.
% VARoption initialises the options struct; VARmodel returns the estimated
% VAR struct (companion matrix F, residual covariance sigma, residuals).

detc = 1;
nlags = 8;

% Initialise options and estimate reduced-form VAR by OLS
VARopt = VARoption;
VARopt.mnem = mnem;   % mnemonics name the VAR.(.) sub-structs
VAR = VARmodel(X,nlags,detc,VARopt);

%% 5. COMPUTE IRF AND FEVD
% -----------------------------------------------------------------------
% Compute impulse responses and bootstrap confidence bands under long-run
% (Blanchard-Quah) identification. VARopt.ident = 'long' instructs VARmodel
% to recover the impact matrix B via lower-triangular factorisation of the
% long-run covariance, imposing that the demand shock has no cumulative
% effect on the output level. Bootstrap inference (inference = 1) produces
% IRinf and IRsup band arrays at each horizon.

% Set IRF horizon, identification scheme, variable labels, and figure size
VARopt.nsteps = 40;
VARopt.ident = 'long';
VARopt.vnames = vnames;
VARopt.firstdate = firstdate;
VARopt.frequency = 'q';
VARopt.figsize = [24,6];

% Enable bootstrap inference and compute IRFs with confidence bands
VARopt.inference = 1;
VAR = VARmodel(X,nlags,detc,VARopt);

% Plot all impulse responses — toolbox standard 2x2 grid (variable x shock)
%....... NOTES TO FIG/TAB .......
% All 4 IRFs (GNP growth and unemployment to supply and demand shock)
% with bootstrap confidence bands. Long-run (Blanchard-Quah) restriction:
% the demand shock has no long-run effect on the output level (cumulative
% GNP growth returns to zero at long horizons after a demand shock).
%..................................
VARopt.figname= 'BQ';
VARirplot(VAR.IRbar,VARopt,VAR.IRinf,VAR.IRsup);

%% 6. REPLICATE FIGURE 2 OF BLANCHARD AND QUAH
% -----------------------------------------------------------------------
% Reproduce Figure 2 of BQ (1989): cumulative GNP response (output level)
% and unemployment response to each structural shock. Supply shock responses
% keep their natural sign; demand shock responses are sign-flipped so that
% a positive demand shock raises output and lowers unemployment.

% Plot cumulative output and unemployment responses to each structural shock
%....... NOTES TO FIG/TAB .......
% Figure 2, Blanchard and Quah (1989, AER, p. 662). Left panel: impulse
% responses to the supply shock; right panel: responses to the demand
% shock. Each panel shows the cumulative GNP growth response (output
% level, cmap color 1) and the unemployment rate response (cmap color 2)
% over 40 quarters. Demand IRFs are sign-flipped (positive demand shock
% raises output and lowers unemployment).
%..................................

figure
FigSize(24,6)

% Plot supply shock responses
subplot(1,2,1)
plot(cumsum(VAR.IR(:,1,1)),'LineWidth',2.5,'Color',pantone('Blue'))
hold on
plot(VAR.IR(:,2,1),'LineWidth',2.5,'Color',pantone('Tomato'))
hold on
plot(zeros(VARopt.nsteps),'--k')
grid on;
title('\textbf{Supply shock}')
legend({'GNP Level';'Unemployment'})
set(gca,'Layer','bottom');
set(findobj(gca,'Type','line'),'Clipping','off');
SetAxesDual(gca);

% Plot demand shock responses (sign-flipped: positive shock raises output)
subplot(1,2,2)
plot(cumsum(-VAR.IR(:,1,2)),'LineWidth',2.5,'Color',pantone('Blue'))
hold on
plot(-VAR.IR(:,2,2),'LineWidth',2.5,'Color',pantone('Tomato'))
hold on
plot(zeros(VARopt.nsteps),'--k')
grid on;
title('\textbf{Demand shock}')
legend({'GNP Level';'Unemployment'})
set(gca,'Layer','bottom');
set(findobj(gca,'Type','line'),'Clipping','off');
SetAxesDual(gca);

% Save figure
SaveFigure('BQ_Fig1Fig2');
