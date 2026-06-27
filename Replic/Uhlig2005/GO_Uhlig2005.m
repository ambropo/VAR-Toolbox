% Replicates Figure 6 (page 397) of Uhlig (2005, JME): sign restriction
% identification of a contractionary monetary policy shock in a 6-variable
% monthly VAR for the US economy.
% =======================================================================
% Outputs: swathe plot of IRFs to the monetary policy shock (median and
% 68% credible interval, 60-month horizon). Requires VAR Toolbox 4.0.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2020. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Clear workspace, suppress warnings, and fix the random seed for
% reproducibility of sign-restriction draws. The working directory is set
% to the script's own folder so that all relative file paths resolve correctly.
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
% Load the Uhlig (2005) monthly dataset from Excel. Each variable is stored
% as a named field in DATA. Log-level variables (y, pi, comm, nbres, res)
% are rescaled by 100 after loading so that all series are expressed in
% percent, consistent with the paper's Figure 6 axis units.

raw         = readcell('Uhlig2005_Data.xlsx', 'Sheet', 'Sheet1');
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
nobs = size(data,1);

% Rescale selected log-level variables by 100 to express in percent
tempnames = {'y','pi','comm','nbres','res'};
tempscale = [100,100,100,100,100];
for ii=1:length(tempnames)
    DATA.(tempnames{ii}) = tempscale(ii)*DATA.(tempnames{ii});
end

%% 3. PLOT SERIES
% -----------------------------------------------------------------------
% Plot all six variables over the full sample at monthly frequency to
% inspect the raw data before estimation. Log-level variables are shown
% rescaled by 100 (units: percent). The 2x3 subplot grid uses DatesPlot
% for x-axis labelling and SetAxesDual for consistent axis styling.
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
SaveFigure('Uhlig_Data')

%% 4. VAR ESTIMATION
% -----------------------------------------------------------------------
% Assemble the 6-variable endogenous data matrix X from the DATA struct,
% set 12 monthly lags and a constant (detc = 1), and initialise the VARopt
% options struct. Identification-specific options are set in Section 5.
% Estimation is deferred to the first VARmodel call in Section 5.

% Construct the endogenous data matrix from the DATA structure
Xmnem   = mnem;
Xvnames = vnames;
Xnvar   = length(Xmnem);

% Build matrix X column by column
X = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA.(Xmnem{ii});
end

% Set deterministics and lag order
detc = 1;
nlags = 12;

% Initialise options
VARopt = VARoption;

%% 5. SIGN RESTRICTIONS
% -----------------------------------------------------------------------
% Identify the monetary policy shock via sign restrictions following
% Uhlig (2005). A contractionary MP shock raises the fed funds rate and
% lowers the price level, commodity prices, and non-borrowed reserves;
% Real GDP and total reserves are unrestricted. Restrictions are imposed for the
% first 6 months (sr_hor = 6). ndraws = 500 accepted rotations are used
% to compute the pointwise median and 68% credible bands. Variable columns
% are reordered for plotting to match the paper's 3x2 layout.

% Set plotting and identification options
VARopt.mnem   = Xmnem;   % mnemonics name the VAR.(.) sub-structs
VARopt.vnames = Xvnames;
VARopt.nsteps = 60;
VARopt.ndraws = 500;
VARopt.inference = 1;     % draw reduced-form parameters from the posterior
VARopt.figsize = [24,12];
VARopt.firstdate = year+(month-1)/12;
VARopt.frequency = 'm';

% Define sign restrictions: +1 positive, -1 negative, 0 unrestricted.
% A contractionary monetary policy shock raises the fed funds rate and
% lowers the price level, commodity prices, and non-borrowed reserves.
SIGN = [ 0,0,0,0,0,0;  % Real GDP
        -1,0,0,0,0,0;  % Deflator
        -1,0,0,0,0,0;  % Commodity Price
         0,0,0,0,0,0;  % Total Reserves
        -1,0,0,0,0,0;  % NonBorr. Reserves
         1,0,0,0,0,0]; % Fed Fund

% Impose restrictions for the first 6 months
VARopt.sr_hor = 6;

% Set credible interval coverage
VARopt.pctg = 68;

% Run sign restrictions; all results stored in SRout
VARopt.ident = 'sign';
VARopt.R = SIGN;
SRout = VARmodel(X,nlags,detc,VARopt);

% Reorder variables to match paper layout: left column = y, pi, comm;
% right column = res, nbres, ff. VARirplot fills subplots row-first, so
% the desired column-first arrangement requires reordering [1 4 2 5 3 6].
ord = [1 4 2 5 3 6];
VARopt.vnames  = Xvnames(ord);
VARopt.figsize = [24,18];
VARopt.subplot = [3,2];
VARopt.color = pantone('Stone');
VARopt.pick = 1;
VARopt.figname = 'Uhlig_Fig6';

% Plot IRFs using swathe (median with 68% credible interval)
%....... NOTES TO FIG/TAB .......
% Figure 6, Uhlig (2005, JME, p. 397). IRFs to a contractionary monetary
% policy shock identified by sign restrictions. 3x2 layout: left column =
% y, pi, comm; right column = res, nbres, ff. Shaded swathe: median with
% 68% credible interval (sign restrictions, 500 draws). Log-level
% variables scaled by 100 (units: percent). 60-month horizon.
%..................................
VARirplot(SRout.IRmed(:,ord,:), VARopt, SRout.IRinf(:,ord,:), SRout.IRsup(:,ord,:))

%% 6. SLIDES FIGURES
% -----------------------------------------------------------------------
% Produces three figures for slide use, following the Primer §13.5–13.6
% layout. Figure 1 (Uhlig_Slides): standard swathe plot in slide dimensions
% [24,12] with original variable order. Figure 2 (Uhlig_500rot_Slides):
% first 100 accepted rotations overlaid to show how the credible swathe
% builds draw by draw. Figure 3 (Uhlig_1rot_Slides / Uhlig_2rot_Slides):
% individual rotations plotted to illustrate sign-restriction mechanics.

% Reset VARopt to slide-friendly layout and original variable order
VARopt.vnames     = Xvnames;
VARopt.figsize    = [24,12];
VARopt.subplot    = [2,3];
VARopt.color      = [];
VARopt.pick       = 1;
VARopt.shorttitle = 1;
VARopt.figname    = 'Uhlig_Slides';

%....... NOTES TO FIG/TAB .......
% Uhlig (2005, JME) Fig. 6 in slide dimensions. IRFs to a contractionary
% monetary policy shock (sign restrictions, 500 draws). Variables in
% spreadsheet order. 68% credible interval. 60-month horizon.
%..................................
VARirplot(SRout.IRmed,VARopt,SRout.IRinf,SRout.IRsup);

% Plot first 100 accepted rotations to show how the swathe builds up draw by draw
store = zeros(Xnvar, 2);
figure;
FigSize(24,12)
for ii = 1:Xnvar
    subplot(2,3,ii)
    plot(squeeze(SRout.IRall(:,ii,1,1:100))); hold on
    plot(zeros(VARopt.nsteps),'-k'); hold on
    title(['\textbf{' Xvnames{ii} '}'],'FontWeight','bold','FontSize',14);
    set(gca,'FontSize',12,'Layer','bottom'); axis tight; grid on
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
    store(ii,:) = ylim;
end
SaveFigure('Uhlig_500rot_Slides')

% Plot first rotation alone
figure;
FigSize(24,12)
for ii = 1:Xnvar
    subplot(2,3,ii)
    plot(SRout.IRall(:,ii,1,1)); hold on
    plot(zeros(VARopt.nsteps),'-k');
    title(['\textbf{' Xvnames{ii} '}'],'FontWeight','bold','FontSize',14);
    set(gca,'FontSize',12,'Layer','bottom'); axis tight; grid on
    ylim(store(ii,:))
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('Uhlig_1rot_Slides')

% Plot first two rotations together
figure;
FigSize(24,12)
for ii = 1:Xnvar
    subplot(2,3,ii)
    plot(SRout.IRall(:,ii,1,1)); hold on
    plot(SRout.IRall(:,ii,1,3)); hold on
    plot(zeros(VARopt.nsteps),'-k');
    title(['\textbf{' Xvnames{ii} '}'],'FontWeight','bold','FontSize',14);
    set(gca,'FontSize',12,'Layer','bottom'); axis tight; grid on
    ylim(store(ii,:))
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('Uhlig_2rot_Slides')
