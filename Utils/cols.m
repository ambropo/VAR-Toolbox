function c = cols(DATA)
% =======================================================================
% Returns number of columns in a matrix
% =======================================================================
% c = cols(DATA)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: input matrix (nobs X nvars)
% -----------------------------------------------------------------------
% OUTPUT
%	- c: number of columns in DATA
% -----------------------------------------------------------------------
% EXAMPLE
%   x = rand(20,5);
%   c = cols(x)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. RETURN COLUMN COUNT
% -----------------------------------------------------------------------
% Extract the second element of the size vector; discard the row count
[~,c] = size(DATA);
