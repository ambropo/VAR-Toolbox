function r = rows(DATA)
% =====================================================================
% Return the number of rows in a matrix
% =====================================================================
% r = rows(DATA)
% ---------------------------------------------------------------------
% INPUT
%   - DATA: input matrix [nobs x nvars double]
% ---------------------------------------------------------------------
% OUTPUT
%   - r: number of rows in DATA [scalar integer]
% ---------------------------------------------------------------------
% EXAMPLE
%   X = rand(20,5);
%   r = rows(X);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. RETURN ROW COUNT
% ---------------------------------------------------------------------
% Extract the first dimension of DATA; ignore the column count.
[r,~] = size(DATA);
