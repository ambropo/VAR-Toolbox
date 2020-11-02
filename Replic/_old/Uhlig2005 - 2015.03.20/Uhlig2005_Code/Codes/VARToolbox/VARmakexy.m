function [Y, X] = VARmakexy(DATA,lags,c_case)
% =======================================================================
% Builds the VAR process from the data-matrix DATA. It orders the data into
% the Y and X matrix --> Example: [x y] = [x(-1) y(-1) x(-2) y(-2)]
% =======================================================================
% [Y, X] = VARmakexy(DATA, lags, c_case)
% -----------------------------------------------------------------------
% INPUT
%   DATA   : matrix containing the original data
%   lags   : lag order of the VAR
%   c_case : 0, no constant, no trend
%            1, constant, no trend
%            2, constant, trend
% OUPUT
%   Y: dependent variable
%   X: independent variable
% =======================================================================
% Ambrogio Cesa Bianchi, July 2011
% ambrogio.cesabianchi@gmail.com


[nobs, ~]= size(DATA);

%Y matrix 
Y = DATA(lags+1:end,:);

%X-matrix 
if c_case==0
        X=[];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        
elseif c_case==1 %constant
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
       X = [ones(nobs-lags,1) X];
       
elseif c_case==2 % time trend and constant
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        trend=1:size(X,1);
        X = [ones(nobs-lags,1) trend' X];
     
elseif c_case==3 % squared time trend, linear time trend, and constant
        X = [];
        for jj=0:lags-1
            X = [DATA(jj+1:nobs-lags+jj,:), X];
        end
        trend=1:size(X,1);
        X = [ones(nobs-lags,1) trend' (trend').^2 X];
end
