function [Y, X] = VARmakexy(DATA,lags,const)
% =======================================================================
% Builds left-hand-side (Y) and right-hand-side (X) matrices for OLS
% estimation of a VAR(p) model from a raw data matrix
% =======================================================================
% [Y, X] = VARmakexy(DATA, lags, const)
% -----------------------------------------------------------------------
% INPUT
%   - DATA:  (nobs x nvar) matrix of endogenous variables [double]
%   - lags:  lag order of the VAR [integer]
%   - const: deterministic specification [integer]
%            0 = no constant, no trend
%            1 = constant, no trend
%            2 = constant, linear trend
% -----------------------------------------------------------------------
% OUTPUT
%   - Y: (nobs-lags x nvar) dependent variable matrix [double]
%   - X: (nobs-lags x k)   regressor matrix, where k = const + nvar*lags
%        [double]; column order is [deterministics | Y(-1) ... Y(-lags)]
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = randn(100,3);
%   [Y, X] = VARmakexy(DATA, 2, 1);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. BUILD Y MATRIX (LEFT-HAND SIDE)
% -----------------------------------------------------------------------
% Y drops the first 'lags' rows — they are used as regressors in X
[nobs, ~]= size(DATA);
Y = DATA(lags+1:end,:);

%% 2. BUILD X MATRIX (RIGHT-HAND SIDE)
% -----------------------------------------------------------------------
% The lag loop prepends each successive lag so that X = [Y(-1) ... Y(-lags)]
% after the loop (most recent lag leftmost). Constant/trend columns are
% then prepended on the left.
if const==0
        X=[];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end

elseif const==1 % constant only
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        X = [ones(nobs-lags,1) X];

elseif const==2 % constant and linear time trend
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        trend=1:size(X,1);
        X = [ones(nobs-lags,1) trend' X];

else
    error('VARmakexy: const must be 0, 1, or 2 (got %d)', const);
end
