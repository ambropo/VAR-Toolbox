function OUT = censor(X,pct)
% =======================================================================
% Replace values in each column of X with NaN if they fall below the
% pct-th or above the (100-pct)-th percentile of that column.
% =======================================================================
% OUT = censor(X,pct)
% -----------------------------------------------------------------------
% INPUT
%   - X  : matrix of data, R rows x C columns [double]
%   - pct: censoring percentile on each tail; must be in (0, 50) [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: censored matrix of the same size as X, with tail observations
%          replaced by NaN [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(200,3);
%   OUT = censor(X, 5);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Enforce that both arguments are supplied and that pct is a valid tail
% probability, i.e. strictly between 0 and 50.
if nargin < 2
    error('censor: X and pct are required inputs.')
end
if pct <= 0 || pct >= 50
    error('censor: pct must be in (0, 50).')
end

%% 2. CENSOR EACH COLUMN
% -----------------------------------------------------------------------
% Values above the (100-pct) percentile or below the pct percentile
% are replaced with NaN. For example, pct=5 censors the bottom 5% and
% the top 5% of each column independently.
[row, col] = size(X);
OUT = nan(row,col);
for ii=1:col
    x = X(:,ii);
    upp = prctile(x, 100-pct);  % upper threshold: (100-pct)-th percentile
    low = prctile(x, pct);      % lower threshold: pct-th percentile
    x(x>upp) = NaN;  % strict: boundary values are kept, not censored
    x(x<low) = NaN;
    OUT(:,ii) = x;
end
