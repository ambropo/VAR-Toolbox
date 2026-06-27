function OUT = MovCorr(X,window,i)
% =======================================================================
% Compute the rolling correlation between variable i and every other
% variable in X over a trailing window, from observation window onward.
% =======================================================================
% OUT = MovCorr(X, window, i)
% -----------------------------------------------------------------------
% INPUT
%   - X     : panel time series T observations x N variables [double]
%   - window: size of the trailing rolling window [double]
%   - i     : index of the reference variable; correlations are computed
%             between X(:,i) and all X(:,j) for j ~= i [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: T x (N-1) matrix of rolling correlations; first window-1 rows
%          are NaN [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(100,5);
%   OUT = MovCorr(X,20,1);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Confirm that all three required arguments are supplied.
if nargin < 3
    error('MovCorr: X, window, and i are required inputs.')
end

%% 2. COMPUTE ROLLING CORRELATIONS
% -----------------------------------------------------------------------
% corrcoef returns the full (nvars x nvars) correlation matrix for the
% current window. setdiff(1:nvars, i) picks all column indices except i,
% so OUT stores the correlation of variable i with every other variable.
% The first window-1 rows remain NaN (not enough data for a full window).
% corrcoef does not accept a 'pairwise' option: any NaN within the window
% propagates to an all-NaN correlation matrix for that observation.
[nobs, nvars] = size(X);
OUT = nan(nobs, nvars-1);

% Roll over each observation, computing the correlation matrix for the current window
for tt = window:nobs
    C   = corrcoef(X(tt-window+1:tt, :));
    idx = setdiff(1:nvars, i);   % indices of all variables except i
    OUT(tt, :) = C(i, idx);
end
