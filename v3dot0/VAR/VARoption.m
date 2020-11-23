function VARopt = VARoption
%========================================================================
% Optional inputs for VAR analysis. This function is run automatically in
% the VARmodel function.
%========================================================================
% VARopt = VARoption
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

VARopt.vnames    = [];      % endogenous variables names
VARopt.vnames_ex = [];      % exogenous variables names
VARopt.snames    = [];      % shocks names (for sign restriction only)
VARopt.nsteps    = 40;      % number of steps for computation of IRFs and FEVDs
VARopt.impact    = 0;       % size of the shock for IRFs: 0=1stdev, 1=unit shock
VARopt.shut      = 0;       % forces the IRF of one variable to zero
VARopt.ident     = 'ch';    % identification method for IRFs ('ch' zero short-run restr, 'bq' zero long-run restr, 'sr' sign restr, 'iv' external instrument)
VARopt.recurs    = 'wold';  % method for computation of recursive stuff ('wold' form MA representation, 'comp' for companion form)
VARopt.ndraws    = 100;     % number of draws for bootstrap or sign restrictions
VARopt.mult      = 10;      % multiple of draws to be printed at screen.
VARopt.pctg      = 95;      % confidence level for bootstrap
VARopt.method    = 'bs';    % methodology for error bands, 'bs' for standard bootstrap, 'wild' wild bootstrap
VARopt.sr_hor    = 1;       % number of periods that sign restrcitions are imposed on
VARopt.sr_rot    = 500000;  % max number of rotations for finding sign restrictions
VARopt.sr_mod    = 1;       % model uncertainty for sign restrictions (1=yes, 0=no)
VARopt.pick      = 0;       % selects one variable for IRFs and FEVDs plots (0 => plot all)
VARopt.quality   = 1;       % quality of exported figures: 1=high (ghostscript required), 0=low
VARopt.suptitle  = 0;       % title on top of figures
VARopt.datesnum  = [];      % numeric vector of dates in the VAR
VARopt.datestxt  = [];      % cell vector of dates in the VAR
VARopt.datestype = 1;       % 1 smart labels; 2 less smart labels
VARopt.firstdate = [];      % initial date of the sample in format 1999.75 => 1999Q4 (both for annual and quarterly data)
VARopt.frequency = 'q';     % frequency of the data: 'm' monthly, 'q' quarterly, 'y' yearly
VARopt.figname   = [];      % string for name of exported figure
VARopt.FigSize   = [26,24]; % size of window for plots