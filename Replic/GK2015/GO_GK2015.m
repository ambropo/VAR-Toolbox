% Replicates Figure 1 (page 61) of Gertler and Karadi (2015, AEJ:M):
% Cholesky vs. external instrument (proxy SVAR) identification of a
% monetary policy shock in a 4-variable monthly VAR.
% =======================================================================
% Outputs: 4x2 subplot comparing Cholesky (left column, red) and IV
% (right column, black) IRFs to a monetary policy shock, 48-month horizon.
% Requires VAR Toolbox 4.0.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2020. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Clear workspace, suppress warnings, and fix the random seed for
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
% Load the Gertler and Karadi (2015) monthly dataset from Excel. readcell
% imports the full spreadsheet as a cell array (raw). Row 1 holds long
% variable names; row 2 holds short mnemonics; rows 3 onward hold monthly
% date strings and data. Each series is stored as a named field in DATA
% for convenient downstream access. The first observation date is extracted
% for use in date-axis labelling.
raw         = readcell('GK2015_Data.xlsx', 'Sheet', 'Sheet1');
dates       = raw(3:end, 1);
vnames      = raw(1, 2:end);
mnem        = raw(2, 2:end);
nvar        = length(mnem);
% Missing observations are stored as the sentinel value 123456789 in the
% spreadsheet (the instrument is observed over a shorter sample than the
% macro series); Num2NaN restores these entries to NaN. Do not remove.
data        = Num2NaN(cellfun(@double, raw(3:end, 2:end)));

% Store each variable as a named field in the DATA structure
for ii=1:length(mnem)
    DATA.(mnem{ii}) = data(:,ii);
end

% Extract the first observation date for later use
year  = str2double(raw{3,1}(1:4));
month = str2double(raw{3,1}(6));

% Observations
nobs = size(data,1);

%% 3. PLOT SERIES
% -----------------------------------------------------------------------
% Plot all five variables (four endogenous plus the FF4 instrument) at
% monthly frequency over the full sample. The 2x3 subplot grid uses
% DatesPlot for x-axis labelling and SetAxesDual for consistent axis
% styling. The figure is saved to GK_Data before estimation.
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
SaveFigure('GK_Data')

%% 4. VAR ESTIMATION
% -----------------------------------------------------------------------
% Separate the dataset into the four endogenous variables (1-year rate,
% CPI, Industrial Production, Excess Bond Premium) and the external
% instrument (FF4 federal funds futures surprise). Assemble ENDO and IV
% matrices for downstream VARmodel calls. The VAR uses 12 monthly lags
% with a constant; VARoption initialises the options struct with defaults.
VARvnames = {'1yr rate';'CPI';'IP';'EBP';};
VARmnem   = {'gs1';'logcpi';'logip';'ebp';};
VARnvar   = length(VARmnem);

% Define external instrument: federal funds futures surprise (FF4)
IVvnames = {'FF4';};
IVmnem   = {'ff4_tc'};
IVnvar   = length(IVmnem);

% VAR specification: 12 lags with constant
VARnlags = 12; VARconst = 1;

% Create matrix of endogenous variables for the VAR
ENDO = nan(nobs,VARnvar);
for ii=1:VARnvar
    ENDO(:,ii) = DATA.(VARmnem{ii});
end

% Create matrix of instruments
IV = nan(nobs,IVnvar);
for ii=1:IVnvar
    IV(:,ii) = DATA.(IVmnem{ii});
end

% Initialise options
VARopt = VARoption;
VARopt.mnem = VARmnem;   % mnemonics name the VAR.(.) sub-structs

%% 5. CHOLESKY IDENTIFICATION
% -----------------------------------------------------------------------
% Estimate IRFs under Cholesky (recursive short-run) identification for
% comparison with the IV results in Section 6. VARopt.ident = 'short' uses
% the lower-triangular Cholesky factor of sigma as the impact matrix.
% Wild-bootstrap inference (method = 'wild', ndraws = 500) produces
% confidence bands. Results are plotted in the left column of the 4x2
% comparison figure using PlotSwathe with red shading.
disp('Estimate Cholesky IRFs and error bands')
VARopt.ident = 'short';
VARopt.method = 'wild';
VARopt.nsteps = 48;
VARopt.ndraws = 500;

% Compute IRFs and bootstrap error bands
VARopt.inference = 1;
VAR_chol = VARmodel(ENDO,VARnlags,VARconst,VARopt);

% Plot Cholesky IRFs in left column of a 4x2 subplot

%....... NOTES TO FIG/TAB .......
% Cholesky (recursive, short-run) IRFs to a monetary policy shock, for
% comparison with IV results. Variables in order: (1) 1-year Treasury
% rate, (2) CPI, (3) Industrial Production, (4) Excess Bond Premium.
% Red shading: bootstrap confidence bands (wild bootstrap, 500 draws);
% dashed red border lines. Solid red line: bootstrap median. 48-month
% horizon.
%..................................

% Configure swathe: red shading with dashed border lines
SwatheOpt = PlotSwatheOption;
SwatheOpt.swathecol  = [1 0 0];
SwatheOpt.dualaxis   = 0;   % dual-axis applied once per panel via SetAxesDual below
SwatheOpt.swatheonly = 1;
SwatheOpt.transp     = 1;
SwatheOpt.alpha      = 0.15;
SwatheOpt.border     = 1;

% Open a tall 4x2 figure; odd columns will hold Cholesky IRFs
figure
FigSize(24,24)
idx = 1;
for ii=1:VARnvar
    subplot(4,2,idx)
    PlotSwathe(VAR_chol.IRbar(:,ii,1),[VAR_chol.IRinf(:,ii,1) VAR_chol.IRsup(:,ii,1)],SwatheOpt); hold on;
    plot(VAR_chol.IRbar(:,ii,1),'LineWidth',2,'color',pantone('Tomato')); hold on;
    plot(zeros(VARopt.nsteps),'-k','LineWidth',0.5)
    title(['\textbf{' VARvnames{ii} '}'],'FontWeight','bold','FontSize',14)
    axis tight; grid on;
    set(gca,'FontSize',12,'Layer','bottom');
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
    idx = idx + 2;
end
legend('Cholesky')

%% 6. IV IDENTIFICATION
% -----------------------------------------------------------------------
% Estimate IRFs under external instrument (proxy SVAR) identification using
% the FF4 federal funds futures surprise as the instrument. VARopt.ident =
% 'iv' and VARopt.IV = IV select proxy SVAR; all other options carry over
% from Section 5. Results are plotted in the right column of the comparison
% figure with black shading.
disp('Estimate IV IRFs and error bands')
VARopt.ident = 'iv';
VARopt.method = 'wild';

% Compute IRFs and bootstrap error bands
VARopt.IV = IV;
VAR_iv = VARmodel(ENDO,VARnlags,VARconst,VARopt);

%% 7. PLOT & SAVE
% -----------------------------------------------------------------------
% Overlay IV IRFs (right column) on the existing Cholesky figure using
% PlotSwathe with black confidence swathes and a solid black median line.
% The completed 4x2 Cholesky vs. IV comparison figure is then saved.

%....... NOTES TO FIG/TAB .......
% External instrument (proxy SVAR) IRFs to a monetary policy shock
% identified by FF4 federal funds futures surprises. Right column of the
% 4x2 subplot. Variables: (1) 1-year rate, (2) CPI, (3) IP, (4) EBP.
% Black shading: bootstrap confidence bands; dashed black border lines.
% Solid black line: bootstrap median. 48-month horizon. Replicates
% Figure 1 of Gertler and Karadi (2015).
%..................................

% Configure swathe: black shading with dashed border lines
SwatheOpt = PlotSwatheOption;
SwatheOpt.swathecol  = [0 0 0];
SwatheOpt.dualaxis   = 0;   % dual-axis applied once per panel via SetAxesDual below
SwatheOpt.swatheonly = 1;
SwatheOpt.transp     = 1;
SwatheOpt.alpha      = 0.15;
SwatheOpt.border     = 1;

% Fill even columns with IV IRFs, interleaving with the Cholesky panels
idx = 2;
for ii=1:VARnvar
    subplot(4,2,idx)
    PlotSwathe(VAR_iv.IRbar(:,ii,1),[VAR_iv.IRinf(:,ii,1) VAR_iv.IRsup(:,ii,1)],SwatheOpt); hold on;
    plot(VAR_iv.IRbar(:,ii,1),'-k','LineWidth',2); hold on;
    plot(zeros(VARopt.nsteps),'-k','LineWidth',0.5)
    title(['\textbf{' VARvnames{ii} '}'],'FontWeight','bold','FontSize',14)
    axis tight; grid on;
    set(gca,'FontSize',12,'Layer','bottom');
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
    idx = idx + 2;
end
legend('IV')

% -----------------------------------------------------------------------
% Save the 4x2 Cholesky vs. IV comparison figure to file.
SaveFigure('GK_Fig1');

%% 8. SLIDES FIGURES
% -----------------------------------------------------------------------
% Reproduces the Primer §15.4 layout for VAR_Primer_Slides. Produces two
% figures: (1) the standard VARirplot output in slide dimensions [18,12]
% for proxy SVAR IRFs; (2) a custom figure with a near-white swathe and a
% star marker at the impact response (h=1) highlighting monetary policy
% transmission on impact. Both figures are saved with _Slides suffix.

% Configure VARopt for slide-friendly dimensions
VARopt.vnames     = VARvnames;
VARopt.figsize    = [24, 12];
VARopt.pick       = 1;
VARopt.shorttitle = 1;
VARopt.figname    = 'GK_Slides';

%....... NOTES TO FIG/TAB .......
% Gertler and Karadi (2015) IV IRFs in slide dimensions. Proxy SVAR with
% FF4 futures instrument; wild bootstrap bands (500 draws). Variables:
% 1-yr T-Bill, CPI, IP, excess bond premium. 48-month horizon.
%..................................
VARirplot(VAR_iv.IRbar,VARopt,VAR_iv.IRinf,VAR_iv.IRsup);

% Custom figure: near-white swathe background with a star marker at the
% impact response (h=0), highlighting monetary policy transmission on impact.
figure;
FigSize(24,12)
SwatheOpt = PlotSwatheOption;
SwatheOpt.swathecol = [0.97 0.97 0.97];
SwatheOpt.linecol   = [0.97 0.97 0.97];
SwatheOpt.dualaxis  = 0;   % dual-axis applied once per panel via SetAxesDual below
for ii = 1:VARnvar
    subplot(2,2,ii)
    PlotSwathe(VAR_iv.IRbar(:,ii,1),[VAR_iv.IRinf(:,ii,1) VAR_iv.IRsup(:,ii,1)],SwatheOpt); hold on
    plot(zeros(1,VARopt.nsteps),'-k','LineWidth',0.5); hold on
    plot(1,VAR_iv.IRbar(1,ii,1),'LineStyle','-','Color',pantone('Blue'),'LineWidth',2,...
        'Marker','*','MarkerSize',15); hold on
    xlim([1 VARopt.nsteps])
    title(['\textbf{' VARvnames{ii} '}'],'FontWeight','bold','FontSize',14)
    set(gca,'FontSize',12,'Layer','bottom'); grid on
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('GK_alt_Slides')
