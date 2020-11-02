function OUT = VARmakelags(DATA,lags)
% =======================================================================
% Builds a matrix with lagged values of DATA, i.e. if DATA = [x1 x2],
% VARmakelags(DATA,1) yields OUT = [x1 x2 x1(-1) x2(-1)]
% =======================================================================
% OUT = VARmakelags(DATA,lags)
% -----------------------------------------------------------------------
% INPUT
%   DATA : matrix containing the original data
%   lags : lag order
%
% OUPUT
%   OUT    : matrix of lagged values
% =======================================================================
% Ambrogio Cesa Bianchi, February 2012
% ambrogio.cesabianchi@gmail.com


[nobs, ~]= size(DATA);

% Create the lagged matrix
OUT = [];
for jj=0:lags-1
    OUT = [DATA(jj+1:nobs-lags+jj,:), OUT];
end

% Finally, save the non-lagged values...
aux = DATA(lags+1:end,:);

%... and append to the lagged matrix
OUT = [aux OUT];