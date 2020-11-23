function [Y, X] = VARmakexy(DATA,lags,const)
%========================================================================
% Builds VAR matrices from DATA, e.g. [x y] = [x(-1) y(-1) x(-2) y(-2)] 
% in case of 2 lags and no constant
%========================================================================
% [Y, X] = VARmakexy(DATA, lags, const)
%--------------------------------------------------------------------------
% INPUT
%   - DATA: matrix containing the original data
%   - lags: lag order of the VAR
%   - const : 0, no constant, no trend
%             1, constant, no trend
%             2, constant, trend
%             3, constant, trend, trend^2
%--------------------------------------------------------------------------
% OUTPUT
%   - Y: VAR dependent variable
%   - X: VAR independent variable
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   [Y,X]= VARmakexy(x,2,1)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


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
