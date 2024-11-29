function OUT = VARmakelags(DATA,lag)
% =======================================================================
% Builds a matrix with lagged values of DATA, i.e. if DATA = [x1 x2],
% VARmakelags(DATA,1) yields OUT = [x1 x2 x1(-1) x2(-1)]. Serves as an
% input to VARmakexy
% =======================================================================
% OUT = VARmakelags(DATA,lag)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: matrix containing the original data
%   - lag: lag order
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix of lagged values
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   OUT = VARmakelags(x,2)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

% Get dimesion of DATA
[nobs, ~]= size(DATA);

% Create the lagged matrix
OUT = [];
for jj=0:lag-1
    OUT = [DATA(jj+1:nobs-lag+jj,:), OUT];
end

% Finally, save the non-lagged values...
aux = DATA(lag+1:end,:);

%... and append to the lagged matrix
OUT = [aux OUT];