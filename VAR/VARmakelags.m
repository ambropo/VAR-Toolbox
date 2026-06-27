function OUT = VARmakelags(DATA,lag)
% =====================================================================
% Build a matrix of current and lagged values of DATA for use as the
% regressor block in VARmakexy. If DATA = [x1 x2] and lag=1, the output
% is OUT = [x1(t) x2(t) x1(t-1) x2(t-1)].
% =====================================================================
% OUT = VARmakelags(DATA,lag)
% ---------------------------------------------------------------------
% INPUT
%   - DATA: matrix of original data (nobs x nvar) [double]
%   - lag:  lag order [integer]
% ---------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix of current and lagged values ((nobs-lag) x nvar*(lag+1))
%          Column order: [Y(0), Y(-1), ..., Y(-lag)] [double]
% ---------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   OUT = VARmakelags(x,2)
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. BUILD LAG MATRIX
% ---------------------------------------------------------------------
% jj=0 fills the rightmost nvar columns with Y(-lag) (oldest lag);
% jj=lag-1 fills the leftmost nvar columns with Y(-1) (most recent lag).
% After the loop OUT = [Y(-1), Y(-2), ..., Y(-lag)].
% The current (non-lagged) values aux = Y(0) are then prepended to give
% the final matrix [Y(0), Y(-1), ..., Y(-lag)].
% Preallocate: lag blocks of nvar columns, nobs-lag rows.
[nobs, nvar] = size(DATA);
OUT = nan(nobs-lag, lag*nvar);
for jj = 0:lag-1
    % col_idx: jj=lag-1 maps to leftmost block (Y(-1)); jj=0 to rightmost (Y(-lag)).
    col_idx = (lag-1-jj)*nvar + (1:nvar);
    OUT(:, col_idx) = DATA(jj+1:nobs-lag+jj, :);
end

% Prepend the current (non-lagged) values as the first block of columns
aux = DATA(lag+1:end, :);
OUT = [aux, OUT];
