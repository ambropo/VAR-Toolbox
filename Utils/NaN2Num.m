function OUT = NaN2Num(DATA)
% =======================================================================
% Substitute NaN values with 123456789
% =======================================================================
% OUT = NaN2Num(DATA)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: matrix with NaN entries [m x n]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix with 123456789 in place of every NaN [m x n]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = [NaN 2; NaN 4; 5 6; 7 8; 9 10];
%   OUT = NaN2Num(X);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. REPLACE NaN WITH SENTINEL VALUE
% -----------------------------------------------------------------------
% 123456789 is an arbitrary large integer used as a sentinel so that
% NaN-free matrices can be passed to routines that do not handle NaN.
% Reverse with Num2NaN.
OUT = DATA;
OUT(isnan(DATA)) = 123456789;
