function OUT = MovCorrCent(X, window, i)
% =======================================================================
% Computes correlation between X_{i} and X_j for all j different
% of i, from windowdowSize to the number of observations.  The 
% first windowdowSize rows are NaN.
% =======================================================================
% OUT = MovCorr(X, windowdowSize, i)
% -----------------------------------------------------------------------
% INPUT
%   - X: panel time series T observations x N variables
%   - windowdow: size of the moving windowdow
%   - i: the variable X_i against which correlations should be returned
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix with moving correlation T observations x N-1 
%       variables. The first windowdowSize-1 rows are NaN.
% =======================================================================
% EXAMPLE
% X = rand(100,5);
% OUT = MovCorrCent(X,10,1)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015

[nobs,nvars] = size(X);
OUT = nan(nobs,nvars-1);

for tt = window+1:nobs-window
    C = corrcoef(X(tt-window:tt+window, :));
    idx = setdiff(1:nvars, i);
    OUT(tt, :) = C(i, idx);
end

