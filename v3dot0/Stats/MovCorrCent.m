function OUT = MovCorrCent(X,window,i)
% =======================================================================
% Computes correlation between X_{i} and X_j for all j different
% of i, from windowdowSize to the number of observations.  The 
% first windowdowSize rows are NaN.
% =======================================================================
% OUT = MovCorr(X, windowdowSize, i)
% -----------------------------------------------------------------------
% INPUT
%   - X: panel time series T observations x N variables [double]
%   - window: size of the moving window [double]
%   - i: selects the i^th variable against which correlations are to be
%       computed [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix with moving correlation T observations x N-1 
%       variables. The first window-1 rows are NaN [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = rand(100,5);
%   OUT = MovCorrCent(X,10,1)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


[nobs,nvars] = size(X);
OUT = nan(nobs,nvars-1);

for tt = window+1:nobs-window
    C = corrcoef(X(tt-window:tt+window, :));
    idx = setdiff(1:nvars, i);
    OUT(tt, :) = C(i, idx);
end

