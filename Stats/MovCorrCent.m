function OUT = MovCorrCent(X,window,i)
% =======================================================================
% Computes correlation between X_{i} and X_j for all j different from i,
% using a centered rolling window of half-width 'window'. The first and
% last 'window' rows of OUT are NaN.
% =======================================================================
% OUT = MovCorrCent(X,window,i)
% -----------------------------------------------------------------------
% INPUT
%   - X     : panel time series T observations x N variables [double]
%   - window: half-width of the centered window; full window = 2*window+1 [double]
%   - i     : index of the variable against which correlations are computed [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix with moving correlation T observations x N-1
%       variables. The first and last window rows are NaN [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = rand(100,5);
%   OUT = MovCorrCent(X,10,1)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
if nargin < 3
    error('MovCorrCent: X, window, and i are required inputs.')
end
[nobs, nvars] = size(X);
if nobs < 2*window+1
    error('MovCorrCent: series too short — need at least 2*window+1 observations.')
end

%% 2. COMPUTE CENTERED ROLLING CORRELATIONS
% -----------------------------------------------------------------------
% The window is symmetric: each observation tt uses rows [tt-window, tt+window],
% so 'window' rows are undefined at both the start and end of the sample.
% corrcoef returns the full correlation matrix; setdiff extracts the row
% corresponding to variable i against all others.
% corrcoef does not accept a 'pairwise' option: any NaN within the window
% propagates to an all-NaN correlation matrix for that observation.
OUT = nan(nobs, nvars-1);

% Roll over each observation using the symmetric centered window
for tt = window+1:nobs-window
    C   = corrcoef(X(tt-window:tt+window, :));
    idx = setdiff(1:nvars, i);   % indices of all variables except i
    OUT(tt, :) = C(i, idx);
end
