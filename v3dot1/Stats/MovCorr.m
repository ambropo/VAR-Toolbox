function OUT = MovCorr(X,window,i)
% =======================================================================
% Computes correlation between X_i and X_j for all j different
% of i, from window to the number of observations.  The 
% first window rows are NaN.
% =======================================================================
% OUT = MovCorr(X, window, i)
% -----------------------------------------------------------------------
% INPUT
%   - X: panel time series T observations x N variables [double]
%   - window : size of the moving window [double]
%   - i: selects the i^th variable against which correlations are to be
%       computed [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix with moving correlation T observations x N-1 
%       variables. The first window-1 rows are NaN. [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = rand(100,5);
%   OUT = MovCorr(X,20,1)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


[nobs,nvars] = size(X);
OUT = nan(nobs,nvars-1);

for tt = window:nobs
    C = corrcoef(X(tt-window+1:tt, :));
    idx = setdiff(1:nvars, [i]);
    OUT(tt, :) = C(i, idx);
end

