% Run the VAR Toolbox primer examples.
% =======================================================================
% This script demonstrates VAR estimation and identification via: zero
% short-run and long-run restrictions, sign restrictions, narrative sign
% restrictions, external instruments, exogenous-variable identification,
% and local projections. Requires VAR Toolbox 4.0.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated: 2026-06-03
% -----------------------------------------------------------------------

%% 0. PRELIMINARIES
% -----------------------------------------------------------------------
% Resolve the Primer folder and toolbox root from the script location so
% relative file paths work regardless of the folder from which the script
% is launched.
clear; close all; clc
warning off all
format short g
rng('default'); rng(4);

% Set LaTeX as the default interpreter for all figure text, tick labels,
% and legend entries throughout this script.
set(groot,'defaultTextInterpreter',          'latex')
set(groot,'defaultAxesTickLabelInterpreter', 'latex')
set(groot,'defaultLegendInterpreter',        'latex')

% Identify the toolbox root from this file's location (one up from Primer)
root = fileparts(fileparts(mfilename('fullpath')));

% Add each relevant subfolder explicitly
addpath(fullfile(root, 'VAR'));
addpath(fullfile(root, 'Figure'));
addpath(fullfile(root, 'Stats'));
addpath(fullfile(root, 'Utils'));
addpath(fullfile(root, 'Primer'));
addpath(fullfile(root, 'Auxiliary'));
disp('VAR Toolbox 4.0 path set.');

% Set working folder where primer is located
cd(fileparts(mfilename('fullpath')));


%% 1. LOAD AND STORE DATA
% -----------------------------------------------------------------------
% Loads US macro data from Primer_Data.xlsx for the bivariate example.
% The spreadsheet contains two series at quarterly frequency: real GDP
% (gdp) and the 1-year Treasury Bill yield (i1yr). Variable mnemonics
% and full labels are read from the header rows; numeric data are stored
% in matrix data, then unpacked into the DATA struct keyed by mnemonic
% for retrieval throughout sections 2–9.

% Load data from the Primer_Data spreadsheet
raw         = readcell('data/Primer_Data.xlsx', 'Sheet', 'Sheet1');
dates       = raw(3:end, 1);   % vector of dates in string format
datesnum    = Date2Num(dates); % vector of dates in numeric format
vnames = raw(1, 2:end);   % full variable names (display labels)
mnem   = raw(2, 2:end);   % variable mnemonics (valid identifiers)
nvar   = length(mnem);    % number of variables in spreadsheet
data   = cellfun(@double, raw(3:end, 2:end)); % numeric data matrix

% Store each variable in the DATA struct, keyed by mnemonic
for ii=1:length(mnem)
    DATA.(mnem{ii}) = data(:,ii);
end

% Record the number of observations in the spreadsheet (raw, pre-trim)
nobs_raw = size(data,1);

% Helper for bold epsilon shock labels in figure text with latex inteRpreter
bfeps = @(s) ['${\bf \epsilon}_{t}^{\mathrm{' s '}}$'];

%% 2. TREAT DATA
% -----------------------------------------------------------------------
% Transforms raw series before VAR estimation. Real GDP is log-differenced
% (ttreat=3) and scaled by 100 to express growth rates in percentage
% points. The 1-year T-Bill yield is first-differenced (ttreat=2) without
% rescaling. datatreat writes the transformed series back into the DATA
% struct following its naming convention (ln/d/dln/g prefixes), here as
% dlngdp (log-diff) and di1yr (first diff), available for variable
% selection in sections 3–9.

% Variable mnemonics, transformation codes, and rescaling factors
tnames = {'gdp','i1yr'};  % variable mnemonics
ttreat = {3, 2};          % transformation: 3=log-diff, 2=diff
tscale = [100 1];         % rescaling factor

% Apply transformations; results stored in DATA as dlngdp and di1yr
DATA = datatreat(DATA,tnames,ttreat,tscale);

%% 3. VAR ESTIMATION
% -----------------------------------------------------------------------
% Estimates a bivariate VAR in GDP growth (dlngdp) and the 1-year T-Bill
% yield (i1yr) with one lag and a constant. Variables are
% assembled into matrix X and aligned to a common sample via CommonSample,
% which strips leading and trailing NaNs and returns the trim indices fo
% and lo. VARmodel returns the estimated VAR struct (companion matrix F,
% residual covariance sigma) and the options struct VARopt. VARprint
% displays OLS coefficients; the coefficient matrix beta is also returned
% for downstream use.

% 3.1 Select variables and plot data
% -----------------------------------------------------------------------
% Select the bivariate variable set, assemble matrix X from the DATA
% struct, balance it to a common sample, and plot the series.

% Endogenous variable mnemonics and display labels for plots
Xmnem = {'dlngdp','i1yr'};
Xvnames = {'Real GDP Growth','1-year Int. Rate'};

% Number of endogenous variables
Xnvar = length(Xmnem);

% Assemble matrix X by pulling columns from the DATA struct
X = nan(nobs_raw,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA.(Xmnem{ii});
end

% Balance the sample via CommonSample: strip leading/trailing NaNs (here
% the first row, where dlngdp is missing because of log-differencing) and
% return the counts of removed leading (fo) and trailing (lo) rows
[X, fo, lo] = CommonSample(X);

% Trim date vectors to stay aligned with the common-sample data
nobs     = size(X, 1);
dates    = dates(fo+1 : fo+nobs);
datesnum = datesnum(fo+1 : fo+nobs);

% Plot the common-sample series
figure;
FigSize(24,6)
for ii=1:Xnvar
    subplot(1,2,ii)
    H(ii) = plot(X(:,ii),'LineWidth',3,'Color',pantone('Blue'));
    title(['\textbf{' Xvnames{ii} '}'],'FontWeight','bold','FontSize',14);
    DatesPlot(datesnum(1),nobs,6,'q') % Set the x-axis labels
    set(gca,'FontSize',12,'Layer','bottom'); grid on;
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end

% Save figure
SaveFigure('graphics/data',2)

% 3.2 Estimate VAR
% -----------------------------------------------------------------------
% Set the lag order and deterministic component, then estimate by OLS.

% Initialise VAR options. VARopt is optional in VARmodel (a reduced-form OLS
% fit can be run as VARmodel(X,nlags,detc)); we set it here to pass mnem, which
% names the per-equation sub-structs VAR_redform.dlngdp, .i1yr (else .eq1, .eq2).
VARopt = VARoption;
VARopt.mnem = Xmnem;

% Deterministic component: 1=constant, 2=constant+trend
detc = 1;

% Lag order
nlags = 1;

% Estimate VAR by OLS (reduced form only)
VAR_redform = VARmodel(X,nlags,detc,VARopt);

% 3.3 Inspect results
% -----------------------------------------------------------------------
% Display the estimated VAR struct fields on screen and print the OLS
% coefficient table.

% Display estimated VAR struct fields, companion matrix, and residual covariance
format short
disp(VAR_redform)
disp(VAR_redform.F)
disp(VAR_redform.sigma)
disp(VARopt)

% Add display labels to VARopt before printing the coefficient table.
% vnames provides the table/figure text; mnem (set above) names the
% VAR.(.) sub-structs.
VARopt.vnames = Xvnames;

% Print OLS coefficient table and return the raw beta matrix
[TABLE, beta] = VARprint(VAR_redform,VARopt);

disp(VAR_redform.maxEig)

disp(eig(VAR_redform.Fcomp))


%% 4. IDENTIFICATION WITH ZERO CONTEMPORANEOUS RESTRICTIONS
% -----------------------------------------------------------------------
% Cholesky identification imposes a recursive causal ordering: GDP growth
% is ordered first (contemporaneously exogenous to the interest rate) and
% the 1-year yield is ordered second. Setting VARopt.ident = 'short'
% instructs VARmodel to compute the lower-triangular Cholesky factor of the
% residual covariance matrix as the impact matrix B. The demand shock is
% shock 1 and the MP shock is shock 2. Structural shocks eps_short are
% recovered as B^{-1} * resid and are orthogonal by construction.

% 4.1 Identification setup
% -----------------------------------------------------------------------
% Select Cholesky identification and populate VARopt with IRF horizon,
% figure settings, date labels, frequency, and shock names.

% Select zero short-run identification
VARopt.ident = 'short';

% Additional options
VARopt.inference = 0;                    % Point estimates only
VARopt.mnem   = Xmnem;                   % mnemonics name the VAR.(.) sub-structs
VARopt.vnames = Xvnames;                 % variable names in plots
VARopt.nsteps = 20;                      % max horizon of IRF
VARopt.figsize = [24,6];                 % size of window (figures)
VARopt.firstdate = datesnum(1);          % first date in plots
VARopt.frequency = 'q';                  % frequency of the data
VARopt.snames = {bfeps('Demand'), bfeps('MonPol')}; % shock names
VARopt.figname = 'graphics/short';

% 4.2 Impulse responses
% -----------------------------------------------------------------------
% Compute IRFs, plot the MP shock, and display B with the first four rows
% of the MP shock IRF.

% Compute impulse responses and plot the MP shock (pick=2)
VAR_short = VARmodel(X,nlags,detc,VARopt);
VARopt.pick = 2;
VARirplot(VAR_short.IR,VARopt);

% Display impact matrix B and first four rows of the MP shock IRF
format short
disp(VAR_short.B)
disp(VAR_short.IR(1:4,:,2))

% 4.3 Structural shocks
% -----------------------------------------------------------------------
% Recover structural shocks as B^{-1} * resid and verify orthogonality
% via the correlation matrix.

% Recover structural shocks as B^{-1} * reduced-form residuals; verify orthogonality
eps_short = (VAR_short.B\VAR_short.resid')';
disp(corr(eps_short))

%% 5. IDENTIFICATION WITH ZERO LONG-RUN RESTRICTIONS
% -----------------------------------------------------------------------
% Blanchard-Quah identification (Blanchard and Quah, 1989) restricts the
% long-run cumulative response of GDP growth to the MP shock to zero,
% embodying long-run monetary neutrality. Setting VARopt.ident = 'long'
% instructs VARmodel to compute B by lower-triangular factorisation of the
% long-run covariance (eye - Fcomp)^{-1} * sigma * (eye - Fcomp)^{-T}.
% Supply and demand shocks are shock 1 and 2 respectively. The restriction
% is verified by extending the horizon to 150 quarters and plotting the
% cumulative GDP response, which should converge to zero.

% 5.1 Identification and impulse responses
% -----------------------------------------------------------------------
% Select long-run identification and compute IRFs. Display B and the
% long-run multiplier matrix (eye - F)^{-1} * B.

% Select zero long-run (Blanchard-Quah) identification
VARopt.ident = 'long';

% Update shock names and figure path
VARopt.figname = 'graphics/long';
VARopt.snames = {bfeps('Supply'), bfeps('MonPol')}; % shock names

% Compute impulse responses; plot the MP shock (pick=2)
VAR_long = VARmodel(X,nlags,detc,VARopt);
VARopt.pick = 2;
VARirplot(VAR_long.IR,VARopt);

% Display impact matrix B and the long-run multiplier matrix (eye - F)^{-1} * B
format short
disp(VAR_long.B)
disp((eye(2)-VAR_long.Fcomp)\VAR_long.B)

% 5.2 Verify long-run restriction
% -----------------------------------------------------------------------
% Re-compute IRFs at 150 quarters, plot cumulative responses to the MP
% shock (should converge to zero for GDP growth), and recover structural
% shocks under long-run identification.

% Extend horizon to 150 quarters to verify the long-run zero restriction visually
VARopt.nsteps = 150;
VAR_long_chk = VARmodel(X,nlags,detc,VARopt);
figure;
FigSize(24,6)
subplot(1,2,1)
plot(cumsum(VAR_long_chk.IR(:,1,2)),'LineWidth',4,'Color',[rgb('gray') 0.8]); hold on
plot(zeros(VARopt.nsteps),'-k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title(['\textbf{Real GDP level to }' bfeps('MonPol')],'FontWeight','bold','FontSize',14);
set(gca,'FontSize',12,'Layer','bottom'); grid on
set(findobj(gca,'Type','line'),'Clipping','off');
SetAxesDual(gca);
subplot(1,2,2)
plot(cumsum(VAR_long_chk.IR(:,2,2)),'LineWidth',4,'Color',[rgb('gray') 0.8]); hold on
plot(zeros(VARopt.nsteps),'-k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title(['\textbf{Cumulative 1-year rate to }' bfeps('MonPol')],'FontWeight','bold','FontSize',14);
set(gca,'FontSize',12,'Layer','bottom'); grid on
set(findobj(gca,'Type','line'),'Clipping','off');
SetAxesDual(gca);
SaveFigure('graphics/longCum');
% Recover structural shocks under long-run identification
eps_long = (VAR_long.B\VAR_long.resid')';


%% 6. IDENTIFICATION WITH SIGN RESTRICTIONS
% -----------------------------------------------------------------------
% Set-identification via sign restrictions (Uhlig, 2005): demand shocks
% raise both GDP growth and the interest rate; MP shocks lower GDP growth
% and raise the interest rate. Restrictions are encoded in R as +1
% (positive), -1 (negative), or 0 (unrestricted) for each variable-shock
% pair. SR draws ndraws=1000 random rotations from the space of orthogonal
% matrices and retains those consistent with R over sr_hor=1 horizon.
% Results include all accepted IRs (VAR_sr.IRall), the pointwise median
% (VAR_sr.IRmed), and the Fry-Pagan median-target rotation (VAR_sr.IRfp).

% 6.1 Define restrictions and identify
% -----------------------------------------------------------------------
% Encode sign restrictions in R and run SR to generate accepted
% orthogonal rotations. Print acceptance rate as a diagnostic.

% Sign restriction matrix: positive 1, negative -1, unrestricted 0
R = [ 1, -1;  % Real GDP
      1,  1]; % 1-year rate

% AddItional options
VARopt.ndraws = 1000;     % number of desired accepted draws
VARopt.sr_hor = 1;        % horizon over which restrictions hold
VARopt.nsteps = 20;       % horizon of impulse responses
VARopt.figsize = [24, 6]; % size of window (figures)
VARopt.snames = {bfeps('Demand'), bfeps('MonPol')}; % shock names

% Identify with sign restrictions
VARopt.ident = 'sign';
VARopt.R = R;
VAR_sr = VARmodel(X,nlags,detc,VARopt);

% Print acceptance rate as a diagnostic
disp(['Acceptance rate: ' num2str(100*VAR_sr.accept_rate,'%.1f') '% of draws accepted'])

% 6.2 Identification uncertainty: all accepted rotations
% -----------------------------------------------------------------------
% Plot IRF swathes across the first 250 accepted draws to illustrate the
% width of the identified set for the MP shock.

% Plot all rotations for MP shock
figure;
FigSize(24,6)
subplot(1,2,1)
plot(squeeze(VAR_sr.IRall(:,1,2,1:250))); hold on
plot(zeros(VARopt.nsteps),'-k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title(['\textbf{Real GDP growth to }' bfeps('MonPol')],'FontWeight','bold','FontSize',14);
set(gca,'FontSize',12,'Layer','bottom'); grid on
set(findobj(gca,'Type','line'),'Clipping','off');
SetAxesDual(gca);
subplot(1,2,2)
plot(squeeze(VAR_sr.IRall(:,2,2,1:250))); hold on
plot(zeros(VARopt.nsteps),'-k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title(['\textbf{1-year rate to }' bfeps('MonPol')],'FontWeight','bold','FontSize',14);
set(gca,'FontSize',12,'Layer','bottom'); grid on
set(findobj(gca,'Type','line'),'Clipping','off');
SetAxesDual(gca);
SaveFigure('graphics/signAll');

% 6.3 Median rotation
% -----------------------------------------------------------------------
% Plot pointwise median rotation then recover structural shocks using 
% VAR_sr.Bmed.

% Plot MP shock only
VARopt.pick = 2;
figure;
FigSize(24,6)
for ii=1:Xnvar
    subplot(1,2,ii);
    plot(VAR_sr.IRmed(:,ii,VARopt.pick),'LineStyle','-','Color',pantone('Blue'),'LineWidth',2,'Marker','o','MarkerSize',7,'MarkerFaceColor',0.5*pantone('Blue')+0.5*[1 1 1],'MarkerEdgeColor',pantone('Blue')); hold on;
    plot(VAR_sr.IRfp(:,ii,VARopt.pick),'LineStyle','-','Color',pantone('Tomato'),'LineWidth',2,'Marker','d','MarkerSize',7,'MarkerFaceColor',0.5*pantone('Tomato')+0.5*[1 1 1],'MarkerEdgeColor',pantone('Tomato')); hold on;
    plot(zeros(1,VARopt.nsteps),'-k','LineWidth',0.5); hold on
    xlim([1 VARopt.nsteps]);
    title(['\textbf{' Xvnames{ii} ' to }' VARopt.snames{VARopt.pick}], ...
        'FontWeight','bold','FontSize',14);
    set(gca, 'FontSize', 12, 'Layer', 'bottom'); grid on
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
legend({'Median','Median target'},'Location','northeast')
SaveFigure('graphics/signMed')
% Recover structural shocks using the point-wise median (VAR_sr.Bmed)
eps_sign = (VAR_sr.Bmed\VAR_sr.resid')';

%% 7. IDENTIFICATION WITH NARRATIVE SIGN RESTRICTIONS
% -----------------------------------------------------------------------
% Narrative sign restrictions (Antolin-Diaz and Rubio-Ramirez, 2018)
% augment sign restrictions with additional constraints tied to specific
% historical episodes. R from section 6 is combined with narrative
% restrictions in a struct R with R.sign, narr_sign, and narr_dom fields.
% Four restrictions across two episodes: (1-2) 1994q1 — Greenspan's first
% hike in five years (Feb 4, 1994): MP shock positive and dominant driver of
% i1yr; (3-4) 2001q1 — January 3 unscheduled inter-meeting cut: MP shock
% negative and dominant driver of i1yr. Periods are specified as date strings.

% Clear previous section restrictions
clear R

% 7.1 Sign and narrative restrictions
% -----------------------------------------------------------------------
% Build R struct combining sign restrictions from section 6 with narrative
% restrictions. Sign of the MP shock at each episode: positive at 1994q1
% (Greenspan's Feb 1994 hike) and negative at 2001q1 (unscheduled
% inter-meeting cut). Dominant-driver restriction applied at 1994q1 only.

% Sign restrictions
R.sign = [ 1, -1;  % Real GDP
           1,  1]; % 1-year rate

% Sign of MP shock for both episodes
R.narr_sign.shock  = [2;        2      ];
R.narr_sign.period = {'1994q1'; '2001q1'};
R.narr_sign.sign   = [1;       -1      ];

% MP shock is the dominant driver of i1yr only in 1994q1
R.narr_dom.shock  = [2;        ];
R.narr_dom.period = {'1994q1'; };
R.narr_dom.var    = [2;        ];

% Set options for the sign restriction routine
VARopt.R 	   = R;      % assign R to VARopt
VARopt.dates   = dates;  % date strings aligned with VAR input data
VARopt.sr_draw = 500000; % total number of draws to attempt
VARopt.figsize = [24, 6];
VARopt.snames  = {bfeps('Demand'), bfeps('MonPol')};

% Identify with sign + narrative restrictions
VAR_nsr = VARmodel(X, nlags, detc, VARopt);

% Print acceptance rate as a diagnostic
disp(['Acceptance rate (sign + narrative): ' num2str(100*VAR_nsr.accept_rate,'%.1f') '% of draws accepted'])

% 7.2 Accepted draws: sign only vs sign + narrative
% -----------------------------------------------------------------------
% Plot the full range (min/max) as a shaded swathe across all accepted
% draws in their raw units. The swathe width is the identification
% uncertainty; narrative restrictions shrink it.

% Median and min/max band across all accepted draws (raw, no normalization)
VARopt.pick  = 2;
IRall_SR     = VAR_sr.IRall(:,:,VARopt.pick,:);
IRall_NSR    = VAR_nsr.IRall(:,:,VARopt.pick,:);

IRmed_SR  = median(IRall_SR,  4);
IRinf_SR  = min(IRall_SR,  [], 4);
IRsup_SR  = max(IRall_SR,  [], 4);
IRmed_NSR = median(IRall_NSR, 4);
IRinf_NSR = min(IRall_NSR, [], 4);
IRsup_NSR = max(IRall_NSR, [], 4);

% Swathe options: swatheonly=1 suppresses the built-in line; median plotted
% separately below to match the marker style used throughout the Primer.
% Transparent swathes (transp=1) show the overlap; renderer is switched
% back to painters before the marker lines are drawn so fill color matches.
SwatheOpt_SR = PlotSwatheOption;
SwatheOpt_SR.swathecol    = pantone('Blue');
SwatheOpt_SR.swatheonly   = 1;
SwatheOpt_SR.transp       = 1;
SwatheOpt_SR.alpha        = 0.15;
SwatheOpt_SR.border       = 1;
SwatheOpt_SR.borderstyle  = '--';
SwatheOpt_SR.dualaxis     = 0;   % two swathes overlaid per panel; dual-axis
                                 % applied once below via SetAxesDual(gca)

SwatheOpt_NSR = PlotSwatheOption;
SwatheOpt_NSR.swathecol   = pantone('Tomato');
SwatheOpt_NSR.swatheonly  = 1;
SwatheOpt_NSR.transp      = 1;
SwatheOpt_NSR.alpha       = 0.30;
SwatheOpt_NSR.border      = 1;
SwatheOpt_NSR.borderstyle = '-.';
SwatheOpt_NSR.dualaxis    = 0;   % see SwatheOpt_SR

% Swathes first (bottom layer), then median lines on top.
% Renderer is reset to painters after the swathes so markers render
% consistently with the rest of the Primer.
figure;
FigSize(24,6)
for ii = 1:Xnvar
    subplot(1,2,ii)
    PlotSwathe(IRmed_SR(:,ii,1),  [IRinf_SR(:,ii,1)  IRsup_SR(:,ii,1)],  SwatheOpt_SR);
    hold on
    PlotSwathe(IRmed_NSR(:,ii,1), [IRinf_NSR(:,ii,1) IRsup_NSR(:,ii,1)], SwatheOpt_NSR);
    set(gcf, 'renderer', 'painters')
    H1 = plot(IRmed_SR(:,ii,1),  'LineStyle', '-', 'Color', pantone('Blue'), 'LineWidth', 2, ...
        'Marker', 'o', 'MarkerSize', 7, 'MarkerFaceColor', 0.5*pantone('Blue')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Blue'));
    H2 = plot(IRmed_NSR(:,ii,1), 'LineStyle', '-', 'Color', pantone('Tomato'), 'LineWidth', 2, ...
        'Marker', 'd', 'MarkerSize', 7, 'MarkerFaceColor', 0.5*pantone('Tomato')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Tomato'));
    plot(zeros(1,VARopt.nsteps), '-k', 'LineWidth', 0.5)
    xlim([1 VARopt.nsteps])
    title(['\textbf{' Xvnames{ii} ' to }' VARopt.snames{VARopt.pick}], ...
        'FontWeight', 'bold', 'FontSize', 14)
    set(gca, 'FontSize', 12, 'Layer', 'bottom'); grid on
    if ii == 1
        legend([H1 H2], {'Sign only', 'Sign + Narrative'}, ...
               'Location', 'southeast')
    end
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('graphics/narr')

% 7.3 Distribution of MP shocks at narrative episodes
% -----------------------------------------------------------------------
% Compare the distribution of the MP shock across accepted draws at each
% narrative episode: sign-only (pantone('Blue')) vs sign + narrative (pantone('Tomato')).

% Collect MP shock at both narrative episodes across all accepted draws
mp_shock  = 2;
t_narr    = [find(strcmp(dates,'1994q1')), find(strcmp(dates,'2001q1'))] - nlags;
ep_labels = {'1994q1 (Feb 1994 hike)', '2001q1 (Jan 2001 cut)'};

% Sing only
ndraws_SR  = size(VAR_sr.Ball, 3);
shocks_SR  = zeros(ndraws_SR, 2);
for dd = 1:ndraws_SR
    e_d = VAR_sr.Ball(:,:,dd) \ VAR_sr.resid';
    shocks_SR(dd,:) = e_d(mp_shock, t_narr);
end

% Repeat for sign + narrative draws
ndraws_NSR  = size(VAR_nsr.Ball, 3);
shocks_NSR  = zeros(ndraws_NSR, 2);
for dd = 1:ndraws_NSR
    e_d = VAR_nsr.Ball(:,:,dd) \ VAR_nsr.resid';
    shocks_NSR(dd,:) = e_d(mp_shock, t_narr);
end

% Plot MP shock distributions at each episode
figure;
FigSize(24,6)
for ii = 1:2
    subplot(1,2,ii)
    histogram(shocks_SR(:,ii),   30, 'FaceColor', pantone('Blue'), 'FaceAlpha', 0.6, 'EdgeColor', 'white')
    hold on
    histogram(shocks_NSR(:,ii), 30, 'FaceColor', pantone('Tomato'), 'FaceAlpha', 0.7, 'EdgeColor', 'white')
    xline(0, '-k', 'LineWidth', 0.5)
    ylabel('Count')
    title(['\textbf{' ep_labels{ii} '}'],'FontWeight','bold','FontSize',14)
    set(gca,'FontSize',12,'Layer','bottom'); grid on
    if ii == 1
        legend({'Sign only','Sign + Narrative'},'Location','northwest')
    end
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('graphics/narr_ShockDist')

%% 8. IDENTIFICATION WITH EXTERNAL INSTRUMENTS
% -----------------------------------------------------------------------
% Proxy SVAR (Stock and Watson, 2012; Mertens and Ravn, 2013): the
% external instrument must be correlated with the target shock (relevance)
% and orthogonal to all other structural shocks (exogeneity). Setting
% VARopt.ident = 'iv' instructs VARmodel to estimate B via IV regression of
% reduced-form residuals on the instrument. An artificial instrument is
% constructed here as the sign-restriction MP shock (eps_sign(:,2)) plus
% standard normal noise, so it is relevant but imperfect. The first column
% of B identified by the instrument is stored in VAR_iv.B(:,1) for section 9.

% 8.1 Construct instrument and compute impulse responses
% -----------------------------------------------------------------------
% Build the artificial proxy, pass it via VARopt.IV, and call VARmodel with
% ident='iv'. The identified MP column is stored in VAR_iv.B(:,1) for section 9.

% Construct the artificial instrument: sign-restriction MP shock plus white noise
noise = randn(nobs_raw,1);          % random vector from N(0,1)
noise = noise(1+fo:end-lo);         % adjust to common sample
mps = [NaN; eps_sign(:,2)] + noise; % add noise to MP shock from sign restrictions

% Set identification to 'iv' and set instrument
VARopt.ident    = 'iv';
VARopt.IV       = mps;
VARopt.snames   = {bfeps('MonPol'), bfeps('Other')};

% Identify with external instrument
VAR_iv = VARmodel(X,nlags,detc,VARopt);

% 8.2 Plot impulse responses
% -----------------------------------------------------------------------
% Plot IRFs with a circle marker along the path and a pentagon marker at
% the impact horizon.

% Plot IRs: circle marker on the line, pentagon marker highlighting the impact response
figure;
FigSize(24,6)
for ii=1:Xnvar
    subplot(1,2,ii);
    plot(VAR_iv.IR(:,ii,1),'LineStyle','-','Color',pantone('Blue'),'LineWidth',2,'Marker','o','MarkerSize',7,'MarkerFaceColor',0.5*pantone('Blue')+0.5*[1 1 1],'MarkerEdgeColor',pantone('Blue')); hold on;
    plot(zeros(1,VARopt.nsteps),'-k','LineWidth',0.5); hold on
    plot(1,VAR_iv.IR(1,ii,1),'LineStyle','-','Color',pantone('Tomato'),'LineWidth',2,...
        'Marker','p','MarkerSize',10,'MarkerFaceColor',pantone('Tomato')); hold on
    xlim([1 VARopt.nsteps]);
    title(['\textbf{' Xvnames{ii} ' to }' VARopt.snames{1}], ...
        'FontWeight','bold','FontSize',14);
    set(gca, 'FontSize', 12, 'Layer', 'bottom'); grid on
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('graphics/iv')

%% 9. IDENTIFICATION WITH EXTERNAL INSTRUMENTS AND SIGN RESTRICTIONS
% -----------------------------------------------------------------------
% Hybrid identification combines the external instrument from section 8
% with sign restrictions. Using ident='sign+iv', a single VARmodel call
% runs the IV stage to pin down the MP shock's impact vector (first column
% of B), then rotates the orthogonal complement to satisfy sign restrictions
% on the remaining shocks. VARopt.IV is already set from section 8. Here a
% single sign restriction identifies the demand shock: both GDP growth and
% the interest rate respond positively. VARopt.pick = 2 selects the demand
% shock for plotting.

% 9.1 Set sign restrictions and identify
% -----------------------------------------------------------------------
% Define sign restrictions for the demand shock and call VARmodel with
% ident='sign+iv'. The IV stage pins column 1 of B; the sign-restriction
% rotation covers the orthogonal complement.
%
% Both VARopt.IV and VARopt.R are required for ident='sign+iv': VARopt.IV
% carries over from section 8 (already in VARopt); VARopt.R is set below.

% Sign restriction for the demand shock (conditional on the IV-identified MP column)
% Positive 1, Negative -1, Unrestricted 0:
R = [ 1;  % Real GDP: positive
      1]; % 1-year rate: positive

% Figure path and shock names
VARopt.figname = 'graphics/iv_sign';
VARopt.snames = {bfeps('MonPol'), bfeps('Demand')};

% Run hybrid identification. VARopt.IV = mps (from section 8) pins column 1
% of B via the IV stage; VARopt.R rotates the orthogonal complement via sign
% restrictions.
VARopt.ident = 'sign+iv';
VARopt.R = R;
VAR_ivsr = VARmodel(X, nlags, detc, VARopt);

% Verify: sign+iv fixes column 1 of B through the IV stage, so VAR_ivsr.Bmed(:,1)
% must equal VAR_iv.B(:,1) from section 8. The two columns are shown side by
% side; numerical agreement confirms the IV constraint is preserved under the
% hybrid scheme.
disp([VAR_iv.B(:,1), VAR_ivsr.Bmed(:,1)])

% 9.2 Plot demand shock
% -----------------------------------------------------------------------
% Plot the point-wsie median demand shock IRF.

% Plot the demand shock IRF (shock 2)
VARopt.pick = 2;
VARirplot(VAR_ivsr.IRmed,VARopt);

%% 10. IDENTIFICATION WITH EXOGENOUS VARIABLE
% -----------------------------------------------------------------------
% Exogenous-variable identification (ident='exog'): the monetary policy
% shock mps from section 8 enters as a contemporaneous regressor in each
% equation of the VAR via VARopt.exoshock. Its OLS coefficient vector,
% scaled to a one-standard-deviation shock, becomes the first column of
% the structural impact matrix B. Unlike the proxy SVAR (section 8), the
% shock enters the estimation directly rather than through a second-stage
% IV projection. Under instrument exogeneity and a common lag structure,
% the two estimators are asymptotically equivalent (Plagborg-Moller and
% Wolf, 2021). Only point estimates are reported here (inference=0);
% bootstrap bands and a local projection comparison are in section 11.

% 10.1 Set up and estimate
% -----------------------------------------------------------------------
% Attach mps via VARopt.exoshock and estimate with ident='exog'. The
% default nlag_exoshock=0 includes only the contemporaneous value.

VARopt_exog = VARoption;
VARopt_exog.inference = 0;          % point estimates only (Section 10)
VARopt_exog.mnem      = Xmnem;
VARopt_exog.vnames    = Xvnames;
VARopt_exog.nsteps    = 20;
VARopt_exog.figsize   = [24, 6];
VARopt_exog.firstdate = datesnum(1);
VARopt_exog.frequency = 'q';
VARopt_exog.ident     = 'exog';
VARopt_exog.exoshock  = mps;
VARopt_exog.snames    = {bfeps('MonPol')};
VAR_exog_pt = VARmodel(X, nlags, detc, VARopt_exog);

% 10.2 Plot impulse responses
% -----------------------------------------------------------------------
% Plot the monetary policy shock IRF with the standard circle-marker style.

VARopt_exog.pick=1;
VARopt_exog.figname='graphics/exog';
VARirplot(VAR_exog_pt.IR,VARopt_exog)

%% 11. STRUCTURAL DYNAMICS ANALYSIS
% -----------------------------------------------------------------------
% Demonstrates the three built-in structural dynamics plotting functions:
% VARirplot (impulse responses), VARvdplot (variance decomposition), and
% VARhdplot (historical decomposition). Builds on the sign-restriction
% identification of section 6; the only change is inference=1, which adds
% identification uncertainty bands to the output struct.
%
% Section structure:
%   11.0  Enable inference and re-estimate
%   11.1  Impulse responses with bands (VARirplot)
%   11.2  Variance decomposition — stacked area (VARvdplot)
%   11.3  Variance decomposition — with error bands (VARvdplot + INF/SUP)
%   11.4  Historical decomposition — stacked area (VARhdplot)
%   11.5  Historical decomposition — with error bands (VARhdplot + INF/SUP)

% 11.0 Reset options, enable inference and re-estimate
% -----------------------------------------------------------------------
% X, nlags, detc are defined in section 3. R and VARopt are from section 6.
% Sections 8-9 modified VARopt.ident, VARopt.R, VARopt.IV, and
% VARopt.snames; those fields are reset here. The only substantive change
% relative to section 6 is inference=1, which adds identification
% uncertainty bands (IRinf/IRsup, VDinf/VDsup, HDinf/HDsup) to the
% output struct.

VARopt.ident     = 'sign';
VARopt.R         = [1, -1;  % Real GDP
                    1,  1]; % 1-year rate
VARopt.IV        = [];
VARopt.snames    = {bfeps('Demand'), bfeps('MonPol')};
VARopt.inference = 1;
VARopt.pick      = 0;
VARopt.firstdate = datesnum(1);
VARopt.frequency = 'q';
rng(4)
VAR_infer = VARmodel(X, nlags, detc, VARopt);

% 11.1 Impulse responses with bands (VARirplot)
% -----------------------------------------------------------------------
% One figure per shock. The element-wise median (VAR_infer.IRmed) is the
% center line; IRinf and IRsup are the identification uncertainty bands
% across all accepted rotations. The Fry-Pagan draw (VAR_infer.IRfp) is
% overlaid after VARirplot returns by directly modifying the open figures.

VARopt.figname = 'graphics/sign_IR';
n_before = length(findobj(0,'Type','figure'));
VARirplot(VAR_infer.IRmed, VARopt, VAR_infer.IRinf, VAR_infer.IRsup);

% findobj returns figures newest-first; new_figs(1) = last shock, new_figs(end) = first
all_figs = findobj(0,'Type','figure');
n_new    = length(all_figs) - n_before;
new_figs = all_figs(1:n_new);
fpcol    = pantone('Tomato');
pcol     = pantone('Blue');
nvars_fp = size(VAR_infer.IRfp, 2);
for k = 1:n_new
    jj   = n_new - k + 1;
    figure(new_figs(k));
    axs  = flipud(findobj(gcf,'Type','axes'));
    Hfp1 = [];
    for ii = 1:nvars_fp
        axes(axs(ii)); hold on;
        Hfp = plot(1:VARopt.nsteps, VAR_infer.IRfp(:,ii,jj), 'LineStyle', '-', 'Color', fpcol, 'LineWidth', 2, ...
            'Marker', 'd', 'MarkerSize', 7, 'MarkerFaceColor', 0.5*fpcol+0.5*[1 1 1], 'MarkerEdgeColor', fpcol);
        if ii == 1; Hfp1 = Hfp; end
    end
    % IRmed: LineWidth=2 distinguishes it from PlotSwathe's border lines (LineWidth=1)
    Hmed = findobj(axs(1), 'Type', 'line', 'Color', pcol, 'LineWidth', 2);
    if k==2
        legend(axs(1), [Hmed(end) Hfp1], {'Point-wise median', 'Median-target'}, ...
        'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 11);
    end 
    SaveFigure([VARopt.figname '_' num2str(jj)], VARopt.quality);
end

% 11.2 Variance decomposition — stacked area (VARvdplot)
% -----------------------------------------------------------------------
% One figure with nvars subplots. Element-wise median VD (VAR_infer.VDmed).
% Note: shares need not sum to exactly 100% at every horizon (element-wise
% median; use VAR_infer.VDfp if exact summability is required). In area
% mode, pick=0 (set above) plots all variables; pick=j restricts to j only.

VARopt.figname = 'graphics/sign_VD';
VARvdplot(VAR_infer.VDmed, VARopt);

% 11.3 Variance decomposition — with error bands (VARvdplot)
% -----------------------------------------------------------------------
% Supplying INF and SUP switches VARvdplot to band mode: one figure per
% shock, one panel per variable. Element-wise median VD as center line. In
% band mode, pick indexes shocks (not variables): pick=2 selects the MonPol
% shock only; pick=0 plots all shocks.

VARopt.figname = 'graphics/sign_VD_bands';
VARopt.pick    = 2;
VARopt.color   = pantone('Tomato');
VARvdplot(VAR_infer.VDmed, VARopt, VAR_infer.VDinf, VAR_infer.VDsup);
VARopt.pick    = 0;
VARopt.color   = [];

% 11.4 Historical decomposition — stacked area (VARhdplot)
% -----------------------------------------------------------------------
% One figure with nvars subplots. Colored bars show each shock's
% contribution to each variable; the black reference line is the observed
% data (HD.endo). The gap between bars and black line = deterministic
% contributions (constant + initial conditions).

% Colors in stack order: const, init, Demand shock, MonPol shock
VARopt.hd_colors = [pantone('Gold_Dark'); % const
                    pantone('Mint_Dark'); % init. cond.
                    pantone('Blue');      % Demand shock
                    pantone('Tomato');];  % MonPol shock
VARopt.legloc = 'southwest';
VARopt.legcols = 1;
VARopt.figname = 'graphics/sign_HD';
VARhdplot(VAR_infer.HDmed, VARopt);

% Now plot only shocks (omit const and init cond)
VARopt.hd_colors = [];
VARopt.hd_detc = 0;
VARopt.figname = 'graphics/sign_HD_ShocksOnly';
VARhdplot(VAR_infer.HDmed, VARopt);

% Reset options
VARopt.hd_detc = 1;

% 11.5 Historical decomposition — with error bands (VARhdplot)
% -----------------------------------------------------------------------
% Supplying INF and SUP switches VARhdplot to band mode: one figure per
% shock, one panel per variable. Element-wise median HD as center line;
% pick=2 selects the MonPol shock only.

VARopt.figname = 'graphics/sign_HD_bands';
VARopt.pick    = 2;
VARopt.color   = pantone('Tomato');
VARhdplot(VAR_infer.HDmed, VARopt, VAR_infer.HDinf, VAR_infer.HDsup);

% Reset options
VARopt.pick    = 0;
VARopt.color   = [];

%% 12. LOCAL PROJECTIONS
% -----------------------------------------------------------------------
% Local projections (LP, Jorda 2005) estimate impulse responses by
% running a direct regression at each horizon h:
%
%   y_{t+h} = alpha_h + beta_h * s_t + gamma_h * w_t + e_{t+h}
%
% Two estimators are demonstrated:
%   (A) LP-OLS: shock s_t = mps enters directly as regressor.
%   (B) LP-IV:  the 1-year Treasury rate r_t = X(:,2) is the endogenous
%               treatment (S argument), instrumented by mps (LPopt.IV),
%               matching the VARopt.IV convention (.IV = instrument).
%
% Both sets of responses are normalized to a 25 bps increase in the
% 1-year Treasury rate and plotted with 90% Newey-West HAC bands.
% Section 12.6-12.7 re-use the exogenous-variable SVAR from Section 10
% to compare LP-OLS vs Exog-SVAR (same figure as in the handbook §7.3).

% 12.1 Set up LP-OLS options
% -----------------------------------------------------------------------
% Initialize LPopt with defaults; set horizon to match the VAR, 90%
% confidence bands, and 1-std-dev shock normalization (impact = 0).
% mnem holds the variable mnemonics: passed to LPmodel they name the
% per-variable sub-structs (LP.dlngdp, LP.i1yr) instead of LP.eq1, LP.eq2.
% vnames holds the display labels used for the LPirplot panels.
LPopt          = LPoption;
LPopt.nsteps   = VARopt.nsteps; % match VAR horizon
LPopt.pctg     = 90;            % 90% confidence bands
LPopt.impact   = 0;             % 1-std-dev shock
LPopt.mnem     = Xmnem;         % mnemonics name per-variable sub-structs (LP.dlngdp, LP.i1yr)
LPopt.vnames   = Xvnames;       % display labels for LPirplot panels

disp(LPopt)

% 12.2 Run LP-OLS for all endogenous variables in a single matrix call
% -----------------------------------------------------------------------
% Pass the full matrix X as ENDO: LPmodel loops the univariate LP over its
% columns, holding the shock (mps), controls (X = lags of all variables),
% nlags, detc, and LPopt fixed. Output: IR/INF/SUP are H x Xnvar; per-variable
% detail nests under LP.dlngdp, LP.i1yr (from LPopt.mnem; LP.eq1,...,LP.eqN
% if no valid mnem), in the column order of X.
ENDO = X;
CTRL = X;
LP = LPmodel(ENDO, mps, CTRL, nlags, detc, LPopt);
LP_IR  = LP.IR;
LP_INF = LP.INF;
LP_SUP = LP.SUP;

disp(LP.dlngdp)


% 12.3 Set up and run LP-IV
% -----------------------------------------------------------------------
% LP-IV: X(:,2) = 1-year Treasury is the endogenous treatment (S argument);
% mps is the external instrument (LPopt_IV.IV), matching VARopt.IV. LPmodel
% internally applies FWL and runs horizon-by-horizon 2SLS. Fstat_fs (first-
% stage F) is stored in each per-horizon sub-struct.
LPopt_IV         = LPoption;
LPopt_IV.nsteps  = VARopt.nsteps;
LPopt_IV.pctg    = 90;
LPopt_IV.impact  = 0;
LPopt_IV.IV      = mps;        % external instrument (high-frequency MP surprise)
LPopt_IV.mnem    = Xmnem;      % mnemonics name per-variable sub-structs (LP_IV.dlngdp, ...)
LPopt_IV.vnames  = Xvnames;    % display labels for LPirplot panels

LP_IV = LPmodel(ENDO, ENDO(:,2), CTRL, nlags, detc, LPopt_IV);
LP_IV_IR  = LP_IV.IR;
LP_IV_INF = LP_IV.INF;
LP_IV_SUP = LP_IV.SUP;

% 12.4 Normalize both to a 25 bps increase in the 1-year Treasury rate
% -----------------------------------------------------------------------
% LP-OLS: scale by 0.25 / (impact response of i1yr to 1-sd MPS).
% LP-IV: scale by 0.25 / std(i1yr), which equals 0.25 / d_norm used
%        internally by LPmodel when impact = 0.
ir_col      = 2;                        % column index of i1yr in X
scale_ols   = 0.25 / LP_IR(1,ir_col);   % LP-OLS normalization
scale_iv    = 0.25 / std(X(:,ir_col));  % LP-IV normalization
LP_IR_n    = LP_IR  * scale_ols;
LP_INF_n   = LP_INF * scale_ols;
LP_SUP_n   = LP_SUP * scale_ols;
LP_IV_IR_n  = LP_IV_IR  * scale_iv;
LP_IV_INF_n = LP_IV_INF * scale_iv;
LP_IV_SUP_n = LP_IV_SUP * scale_iv;

% 12.5 Plot: LP-OLS vs LP-IV with 90% confidence bands (Figure 7.2)
% -----------------------------------------------------------------------
% Both IRFs normalized to 25 bps in i1yr. Blue = LP-OLS; red = LP-IV.
% Transparent swathes show overlap; point estimates plotted on top.
SwatheOpt_OLS = PlotSwatheOption;
SwatheOpt_OLS.swathecol    = pantone('Blue');
SwatheOpt_OLS.swatheonly   = 1;
SwatheOpt_OLS.transp       = 1;
SwatheOpt_OLS.alpha        = 0.15;
SwatheOpt_OLS.border       = 1;
SwatheOpt_OLS.borderstyle  = '--';
SwatheOpt_OLS.dualaxis     = 0;  % two swathes overlaid per panel; dual-axis
                                 % applied once below via SetAxesDual(gca)

SwatheOpt_IV = PlotSwatheOption;
SwatheOpt_IV.swathecol    = pantone('Tomato');
SwatheOpt_IV.swatheonly   = 1;
SwatheOpt_IV.transp       = 1;
SwatheOpt_IV.alpha        = 0.30;
SwatheOpt_IV.border       = 1;
SwatheOpt_IV.borderstyle  = '-.';
SwatheOpt_IV.dualaxis     = 0;   % see SwatheOpt_OLS

figure;
FigSize(VARopt.figsize(1), VARopt.figsize(2))
for ii = 1:Xnvar
    subplot(1, Xnvar, ii)
    PlotSwathe(LP_IR_n(:,ii),    [LP_INF_n(:,ii)    LP_SUP_n(:,ii)],    SwatheOpt_OLS);
    hold on
    PlotSwathe(LP_IV_IR_n(:,ii), [LP_IV_INF_n(:,ii) LP_IV_SUP_n(:,ii)], SwatheOpt_IV);
    set(gcf, 'renderer', 'painters')
    H1 = plot(LP_IR_n(:,ii),    'LineStyle', '-', 'Color', pantone('Blue'),   'LineWidth', 2, ...
        'Marker', 'o', 'MarkerSize', 7, 'MarkerFaceColor', 0.5*pantone('Blue')+0.5*[1 1 1],   'MarkerEdgeColor', pantone('Blue'));
    H2 = plot(LP_IV_IR_n(:,ii), 'LineStyle', '-', 'Color', pantone('Tomato'), 'LineWidth', 2, ...
        'Marker', 'd', 'MarkerSize', 7, 'MarkerFaceColor', 0.5*pantone('Tomato')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Tomato'));
    plot(zeros(1,LPopt.nsteps), '-k', 'LineWidth', 0.5)
    xlim([1 LPopt.nsteps])
    title(['\textbf{' Xvnames{ii} ' to }' bfeps('MonPol')], 'FontWeight', 'bold', 'FontSize', 14)
    set(gca, 'FontSize', 12, 'Layer', 'bottom'); grid on
    if ii == Xnvar
        legend([H1 H2], {'LP-OLS (NW)', 'LP-IV (NW)'}, 'Location', 'southwest')
    end
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('graphics/LP_OLS_IV')

% 12.6 Exog-SVAR: re-estimate VAR with instrument as exogenous variable
% -----------------------------------------------------------------------
% Re-estimate the VAR with mps supplied via VARopt.exoshock (ident='exog').
% Its coefficient vector across equations becomes the first column of B.
% Bootstrap 90% bands with 1000 draws.
VARopt_exog = VARoption;
VARopt_exog.mnem      = Xmnem;
VARopt_exog.vnames    = Xvnames;
VARopt_exog.nsteps    = VARopt.nsteps;
VARopt_exog.figsize   = VARopt.figsize;
VARopt_exog.firstdate = VARopt.firstdate;
VARopt_exog.frequency = VARopt.frequency;
VARopt_exog.ident     = 'exog';
VARopt_exog.exoshock  = mps;
VARopt_exog.snames    = {bfeps('MonPol')};
VARopt_exog.pctg      = 90;    % 90% confidence bands, matching LP
VARopt_exog.ndraws    = 1000;  % bootstrap draws
VARopt_exog.method    = 'bs';  % residual bootstrap
VARopt_exog.inference = 1;     % compute bootstrap bands
VARopt_exog.quality   = 2;
VAR_exog = VARmodel(X, nlags, detc, VARopt_exog);

% 12.7 Plot: LP-OLS vs Exog-SVAR with 90% confidence bands (Figure 7.3)
% -----------------------------------------------------------------------
% LP-OLS responses from 12.2 (1-sd MPS, not normalized to 25 bps here);
% Exog-SVAR bootstrap bands. Legend in last panel only.
SwatheOpt_LP = PlotSwatheOption;
SwatheOpt_LP.swathecol    = pantone('Blue');
SwatheOpt_LP.swatheonly   = 1;
SwatheOpt_LP.transp       = 1;
SwatheOpt_LP.alpha        = 0.15;
SwatheOpt_LP.border       = 1;
SwatheOpt_LP.borderstyle  = '--';
SwatheOpt_LP.dualaxis     = 0;   % two swathes overlaid per panel; dual-axis
                                 % applied once below via SetAxesDual(gca)

SwatheOpt_EX = PlotSwatheOption;
SwatheOpt_EX.swathecol    = pantone('Tomato');
SwatheOpt_EX.swatheonly   = 1;
SwatheOpt_EX.transp       = 1;
SwatheOpt_EX.alpha        = 0.30;
SwatheOpt_EX.border       = 1;
SwatheOpt_EX.borderstyle  = '-.';
SwatheOpt_EX.dualaxis     = 0;   % see SwatheOpt_LP

figure;
FigSize(VARopt_exog.figsize(1), VARopt_exog.figsize(2))
for ii = 1:Xnvar
    subplot(1, Xnvar, ii)
    PlotSwathe(LP_IR(:,ii),           [LP_INF(:,ii)           LP_SUP(:,ii)],           SwatheOpt_LP);
    hold on
    PlotSwathe(VAR_exog.IRbar(:,ii,1), [VAR_exog.IRinf(:,ii,1) VAR_exog.IRsup(:,ii,1)], SwatheOpt_EX);
    set(gcf, 'renderer', 'painters')
    H1 = plot(LP_IR(:,ii),            'LineStyle', '-', 'Color', pantone('Blue'),   'LineWidth', 2, ...
        'Marker', 'o', 'MarkerSize', 7, 'MarkerFaceColor', 0.5*pantone('Blue')+0.5*[1 1 1],   'MarkerEdgeColor', pantone('Blue'));
    H2 = plot(VAR_exog.IRbar(:,ii,1), 'LineStyle', '-', 'Color', pantone('Tomato'), 'LineWidth', 2, ...
        'Marker', 'd', 'MarkerSize', 7, 'MarkerFaceColor', 0.5*pantone('Tomato')+0.5*[1 1 1], 'MarkerEdgeColor', pantone('Tomato'));
    plot(zeros(1,LPopt.nsteps), '-k', 'LineWidth', 0.5)
    xlim([1 LPopt.nsteps])
    title(['\textbf{' Xvnames{ii} ' to }' bfeps('MonPol')], 'FontWeight', 'bold', 'FontSize', 14)
    set(gca, 'FontSize', 12, 'Layer', 'bottom'); grid on
    if ii == Xnvar
        legend([H1 H2], {'LP (NW)', 'SVAR-Exog (Bootstrap)'}, 'Location', 'southwest')
    end
    set(findobj(gca,'Type','line'),'Clipping','off');
    SetAxesDual(gca);
end
SaveFigure('graphics/LP')

close all

