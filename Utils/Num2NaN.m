function OUT = Num2NaN(DATA)
% =======================================================================
% Substitute 123456789 values with NaN
% =======================================================================
% OUT = Num2NaN(DATA)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: matrix with sentinel value 123456789 in place of NaN [m x n]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: matrix with NaN restored wherever 123456789 appeared [m x n]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = [123456789 2; 123456789 4; 5 6; 7 8; 9 10];
%   OUT = Num2NaN(X);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. REPLACE SENTINEL VALUE WITH NaN
% -----------------------------------------------------------------------
% Reverses NaN2Num: any cell equal to the sentinel 123456789 is restored
% to NaN. The sentinel was chosen to be unlikely to appear as real data.
OUT = DATA;
OUT(DATA == 123456789) = NaN;
