function OUT = L(X,nlag)
% =======================================================================
% Creates a matrix (or vector) of lagged values (the first obs are NaN)
% =======================================================================
% OUT = L(X,nlag)
% -----------------------------------------------------------------------
% INPUT
%   - X: input matrix (nobs x nvars)
%   - nlag: order of lags (-1 is lag; +1 is lead)
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: lagged matrix (nobs x nvars), the first obs are NaN
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(50,3);
%   OUT = L(X, -1);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
switch(nargin)
    case 1
        error('Missing input: number of lags');
    case 2
        % valid — proceed below
    otherwise
        error('Too many inputs for function L');
end

%% 2. SHIFT ROWS AND PAD WITH NaN
% -----------------------------------------------------------------------
% Sign convention: nlag > 0 shifts forward in time (lead), nlag < 0 shifts
% backward in time (lag). The displaced rows are filled with NaN so the
% output length always equals the input length.
% trimr(X, ktop, kbot) drops ktop rows from the top and kbot from the bottom.
init = NaN;
if nlag > 0      % lead: drop first nlag rows, append NaN rows at the bottom
    zt  = ones(nlag, cols(X)) * init;
    OUT = [trimr(X, nlag, 0); zt];
elseif nlag < 0  % lag:  append NaN rows at the top, drop last |nlag| rows
    zt  = ones(abs(nlag), cols(X)) * init;
    OUT = [zt; trimr(X, 0, abs(nlag))];
else
    OUT = X;
end
