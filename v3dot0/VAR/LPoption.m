function LPopt = LPoption
%========================================================================
% Optional inputs for VAR analysis. This function is run automatically in
% the VARmodel function.
%========================================================================
% LPopt = VARoption
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

LPopt.vnames    = [];      % endogenous variables names
LPopt.vnames_ex = [];      % exogenous variables names
LPopt.snames    = [];      % shocks names
LPopt.nsteps    = 40;      % number of steps for computation of IRFs and FEVDs
LPopt.impact    = 0;       % size of the shock for IRFs: 0=1stdev, 1=unit shock
LPopt.shut      = 0;       % forces the IRF of one variable to zero
LPopt.ident     = 'short'; % identification method for IRFs ('short' zero short-run restr, 'long' zero long-run restr, 'sign' sign restr, 'iv' external instrument)
LPopt.recurs    = 'wold';  % method for computation of recursive stuff ('wold' form MA representation, 'comp' for companion form)
LPopt.ndraws    = 1000;    % number of draws for bootstrap or sign restrictions
LPopt.mult      = 10;      % multiple of draws to be printed at screen.
LPopt.pctg      = 95;      % confidence level for bootstrap
LPopt.method    = 'bs';    % methodology for error bands, 'bs' for standard bootstrap, 'wild' wild bootstrap
LPopt.sr_hor    = 1;       % number of periods that sign restrcitions are imposed on
LPopt.sr_rot    = 500;     % max number of rotations for finding sign restrictions
LPopt.sr_draw   = 100000;  % max number of total draws for finding sign restrictions
LPopt.sr_mod    = 1;       % model uncertainty for sign restrictions (1=yes, 0=no)
LPopt.pick      = 0;       % selects one variable for IRFs and FEVDs plots (0 => plot all)
LPopt.quality   = 1;       % quality of exported figures: 1=high (ghostscript required), 0=low
LPopt.suptitle  = 0;       % title on top of figures
LPopt.datesnum  = [];      % numeric vector of dates in the VAR
LPopt.datestxt  = [];      % cell vector of dates in the VAR
LPopt.datestype = 1;       % 1 smart labels; 2 less smart labels
LPopt.firstdate = [];      % initial date of the sample in format 1999.75 => 1999Q4 (both for annual and quarterly data)
LPopt.frequency = 'q';     % frequency of the data: 'm' monthly, 'q' quarterly, 'y' yearly
LPopt.figname   = [];      % string for name of exported figure
LPopt.FigSize   = [26,24]; % size of window for plots
LPopt.EXOG   = []; % size of window for plots
LPopt.LAGS   = []; % size of window for plots

% In progress
%LPopt.maxvd_N   = 1;       % position of variable to maximize variance decomposition
%LPopt.maxvd_H   = 10;      % horizon over which to maximize variance decomposition
%LPopt.maxvd_rot = 1000;    % max number of rotations for maximization of variance decomposition
