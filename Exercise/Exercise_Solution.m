% TSP 2026 exercise solution: Cholesky, sign restrictions, and IV
% identification applied to a monetary policy VAR (Gertler-Karadi data).
% =======================================================================
% The VAR Toolbox 4.0 is required to run this code. To get the
% latest version visit: https://github.com/ambropo/VAR-Toolbox
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% April 2026. Updated: 2026-05-29
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
clear all; close all; clc
warning off all

% Add VAR Toolbox to path (parent of this script's Exercise/ folder)
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))))

% Fix random seed for reproducibility of bootstrap and sign-restriction draws
rng(42, 'twister');

% Set working directory to the script's own folder so relative paths work
cd(fileparts(mfilename('fullpath')));

%% 2. LOAD DATA
% -----------------------------------------------------------------------
% Load the Gertler and Karadi (2015) monthly dataset from Excel. readcell
% imports the full spreadsheet as a cell array (raw). Row 1 holds long
% variable names; row 2 holds short mnemonics; rows 3 onward hold monthly
% date strings and numeric data.
raw         = readcell('GK2015_Data.xlsx', 'Sheet', 'Sheet1');
dates       = raw(3:end, 1);
vnames      = raw(1, 2:end);
mnem        = raw(2, 2:end);
nvar        = length(mnem);
% Missing observations are stored as the sentinel value 123456789 in the
% spreadsheet (the instrument is observed over a shorter sample than the
% macro series); Num2NaN restores these entries to NaN. Do not remove.
data        = Num2NaN(cellfun(@double, raw(3:end, 2:end)));

% Store variables in the structure DATA
for ii=1:length(mnem)
    DATA.(mnem{ii}) = data(:,ii);
end

% Observations
nobs = size(data,1);


%% 3. REDUCED-FORM VAR
% -----------------------------------------------------------------------
% Set endogenous list and names
VARvnames = {'CPI';'IP';'1yr rate';'EBP';};
VARmnem   = {'logcpi';'logip';'gs1';'ebp';};
VARnvar   = length(VARmnem);

% Set instrument list and names
IVvnames = {'FF4';};
IVmnem   = {'ff4_tc'};
IVnvar   = length(IVmnem);

% VAR specification
VARnlags = 12; VARconst = 1;

% Create matrices of variables for the VAR
ENDO = nan(nobs,VARnvar);
for ii=1:VARnvar
    ENDO(:,ii) = DATA.(VARmnem{ii});
end

% Create matrix of variables for the instrument
IV = nan(nobs,IVnvar);
for ii=1:IVnvar
    IV(:,ii) = DATA.(IVmnem{ii});
end

% Estimate reduced-form VAR (no identification, no inference)
VAR = VARmodel(ENDO, VARnlags, VARconst);


%% 4. CHOLESKY IDENTIFICATION
% -----------------------------------------------------------------------
% Recursive (short-run) identification. The ordering CPI -> IP -> Rate -> EBP
% implies that monetary policy (Rate) responds contemporaneously to CPI and IP
% but not to EBP; EBP responds to all variables within the month.
% The monetary policy shock is shock 3.

% Set options: Cholesky identification with standard bootstrap inference
VARoptchol           = VARoption;
VARoptchol.ident     = 'short';
VARoptchol.nsteps    = 48;
VARoptchol.inference = 1;
VARoptchol.ndraws    = 500;
VARoptchol.method    = 'bs';
VARoptchol.mnem      = VARmnem;
VARoptchol.vnames    = VARvnames;

% Estimate VAR, identify via Cholesky, and compute bootstrap bands
VARchol = VARmodel(ENDO, VARnlags, VARconst, VARoptchol);

% Plot responses to monetary shock (shock 3): median and 90% bands
VARoptchol.pick      = 3;
VARoptchol.figname   = 'chol';
VARirplot(VARchol.IRbar,VARoptchol,VARchol.IRinf,VARchol.IRsup)


%% 5. SIGN RESTRICTIONS IDENTIFICATION
% -----------------------------------------------------------------------
% Set-identification via sign restrictions. The SIGN matrix defines the
% expected impact signs for each shock (columns) on each variable (rows):
%   +1 = positive,  -1 = negative,  0 = unrestricted
% Restrictions are imposed for the first sr_hor periods.
% The monetary policy shock is shock 3 (columns: Demand, Supply, Monetary, Unidentified).

%  Demand  Supply  Monetary  Unident.
SIGN = [ 1,   -1,     -1,      0;   % CPI
         1,    1,     -1,      0;   % IP
         1,    0,      1,      0;   % Rate
        -1,   -1,      1,      0];  % EBP

% Set options: sign-restriction identification
VARoptsr           = VARoption;
VARoptsr.ident     = 'sign';
VARoptsr.R         = SIGN;
VARoptsr.ndraws    = 1000;
VARoptsr.nsteps    = 48;
VARoptsr.sr_hor    = 3;
VARoptsr.mnem      = VARmnem;
VARoptsr.vnames    = VARvnames;

% Estimate VAR and identify via sign restrictions (returns distribution over
% all accepted rotation matrices; IRmed/IRinf/IRsup are percentile bands)
VARsr = VARmodel(ENDO, VARnlags, VARconst, VARoptsr);

% Plot responses to monetary shock (shock 3): median and 90% bands
VARoptsr.pick      = 3;
VARoptsr.figname   = 'sr';
VARoptsr.color     = cmap(2);
VARirplot(VARsr.IRmed,VARoptsr,VARsr.IRinf,VARsr.IRsup)


% Save original ordering for comparison in section 7
VARmnem_orig   = {'logcpi';'logip';'gs1';'ebp'};
VARvnames_orig = {'CPI';'IP';'1yr rate';'EBP'};


%% 6. EXTERNAL INSTRUMENTS (PROXY SVAR) IDENTIFICATION
% -----------------------------------------------------------------------
% Identification via an external instrument (FF4: federal funds futures
% surprise, 4-month ahead). The instrument must be placed first in the VAR,
% so we re-order ENDO putting Rate before CPI and IP.
% Error bands via wild bootstrap (required for IV residuals).

% Re-order: Rate first (the instrumented variable must be first)
VARvnames_IV = {'1yr rate';'CPI';'IP';'EBP';};
VARmnem_IV   = {'gs1';'logcpi';'logip';'ebp';};

% Re-create ENDO with new ordering
ENDO = nan(nobs,VARnvar);
for ii=1:VARnvar
    ENDO(:,ii) = DATA.(VARmnem_IV{ii});
end

% Set options: IV identification with wild-bootstrap inference. The instrument
% is passed via VARopt.IV before calling VARmodel.
VARoptiv           = VARoption;
VARoptiv.IV        = IV;
VARoptiv.ident     = 'iv';
VARoptiv.nsteps    = 48;
VARoptiv.inference = 1;
VARoptiv.ndraws    = 500;
VARoptiv.method    = 'wild';
VARoptiv.mnem      = VARmnem_IV;
VARoptiv.vnames    = VARvnames_IV;
VARoptiv.color     = cmap(4);

% Estimate VAR, identify via IV, and compute bootstrap bands. IV identifies
% one shock (the instrumented one); IR has third dimension = 1.
VARiv = VARmodel(ENDO, VARnlags, VARconst, VARoptiv);

% Plot responses to monetary shock (shock 1): median and 90% bands
VARoptiv.pick      = 1;
VARoptiv.figname   = 'iv';
VARirplot(VARiv.IRbar,VARoptiv,VARiv.IRinf,VARiv.IRsup)


%% 7. COMPARISON: POINT ESTIMATES ACROSS IDENTIFICATION APPROACHES
% -----------------------------------------------------------------------
% Plot median IRFs from all three methods on the same axes. The IV results
% use a different variable ordering (Rate first), so we use find() to locate
% the column in VARiv.IRbar that corresponds to each variable in the original order.

% IV variable ordering used above
VARmnem_iv = {'gs1';'logcpi';'logip';'ebp'};

% Open a new figure and plot median IRFs from all three methods side by side
figure
FigSize(24,12)
steps  = 1:VARoptiv.nsteps;
x_axis = zeros(1,VARoptiv.nsteps);
for ii = 1:VARnvar
    % Find which column in IV results corresponds to variable ii
    col_iv = find(strcmp(VARmnem_iv, VARmnem_orig{ii}));
    % Plot
    subplot(2,2,ii)
    plot(steps,VARchol.IRbar(:,ii,3),   'Color',pantone('Blue'),'LineWidth',2); hold on
    plot(steps,VARsr.IRmed(:,ii,3),     'Color',cmap(2),        'LineWidth',2); hold on
    plot(steps,VARiv.IRbar(:,col_iv,1), 'Color',cmap(4),        'LineWidth',2); hold on
    plot(steps,x_axis,'-k','LineWidth',0.5)
    xlim([steps(1) steps(end)])
    title(VARvnames_orig{ii},'FontWeight','bold','FontSize',14)
    set(gca,'FontSize',12,'Layer','bottom')
    SetAxesDual(gca)
end
set(findall(gcf,'-property','FontName'),'FontName','Palatino')
legend('Cholesky','Sign restr.','IV','Location','best')
