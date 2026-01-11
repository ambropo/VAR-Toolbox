function OUT = LPmakex(x,nlag)
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% OBSOLETE   %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
% =======================================================================
% Creates la matrix containing up to "nlag" lags  of the data in the 
% vector x
% =======================================================================
% OUT = LPmakex(x,nlag)
% -----------------------------------------------------------------------
% INPUT
%	- x: vector of data [nobs x 1]
%	- nlag: number of lags to compute 
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: matrix with lagged data
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1; 2; 3; 4; 5; 6];
%   OUT = LPmakex(x,3)
% OUT =
%        NaN   NaN   NaN
%          1   NaN   NaN
%          2     1   NaN
%          3     2     1
%          4     3     2
%          5     4     3
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% September 2024
% -----------------------------------------------------------------------

OUT = [];
for ii=1:nlag
    OUT = [OUT L(x,-ii)];
end


