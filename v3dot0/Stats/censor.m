function OUT = censor(X,pct)
% =======================================================================
% Censor the values of a matrix (RxC) column by column, by replacing with 
% NaNs where the data is above 100-pct and below pct
% =======================================================================
% OUT = censor(X,pct)
% -----------------------------------------------------------------------
% INPUT
%   - X   : matrix of data [double]
%   - pct : percentile to be censored on each side [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT : matrix [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = rand(50,2);
%   OUT = censor(X,5)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------

[row, col] = size(X);
OUT = nan(row,col);
% Loop column by column 
for ii=1:col
    x = X(:,ii);
    upp = prctile(x,100-pct);
    low = prctile(x,pct);
    x(x>upp) = NaN;
    x(x<low) = NaN;
    OUT(:,ii) = x;
end