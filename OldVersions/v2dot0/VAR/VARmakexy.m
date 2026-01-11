function [Y, X] = VARmakexy(DATA,lags,const)
% =======================================================================
% Builds the VAR process from the data-matrix DATA. It orders the data into
% the Y and X matrix --> Example: [x y] = [x(-1) y(-1) x(-2) y(-2)]
% =======================================================================
% [Y, X] = VARmakexy(DATA, lags, const)
% -----------------------------------------------------------------------
% INPUT
%   DATA: matrix containing the original data
%   lags: lag order of the VAR
%   const : 0, no constant, no trend
%           1, constant, no trend
%           2, constant, trend
%           3, constant, trend, trend^2
% -----------------------------------------------------------------------
% OUTPUT
%   Y: dependent variable
%   X: independent variable
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


% Get dimesion of DATA
[nobs, ~]= size(DATA);

% Y matrix 
Y = DATA(lags+1:end,:);

% X-matrix 
if const==0
        X=[];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        
elseif const==1 %constant
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
       X = [ones(nobs-lags,1) X];
       
elseif const==2 % time trend and constant
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        trend=1:size(X,1);
        X = [ones(nobs-lags,1) trend' X];
     
elseif const==3 % squared time trend, linear time trend, and constant
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        trend=1:size(X,1);
        X = [ones(nobs-lags,1) trend' (trend').^2 X];
end
