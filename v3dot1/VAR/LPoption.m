function LPopt = LPoption
%========================================================================
% Optional inputs for LP analysis. This function is run automatically in
% the LPmodel function if not provided by the user
%========================================================================
% LPopt = LPoption
% =======================================================================
% VAR Toolbox 3.1
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2024.
% -----------------------------------------------------------------------

LPopt.nsteps    = 40; % number of steps for computation of IRFs
LPopt.pctg      = 95; % confidence level for bootstrap
LPopt.EXOG      = []; % size of window for plots
LPopt.LAGS      = []; % size of window for plots
LPopt.impact    = 0;  % size of the shock for IRFs: 0=1stdev, 1=unit shock
