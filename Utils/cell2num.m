function OUT = cell2num(datacell)
% =======================================================================
% Convert a cell array of number strings into a double array. If the cell
% array does not include a valid number string, returns NaN
% =======================================================================
% OUT = cell2num(datacell)
% -----------------------------------------------------------------------
% INPUT
%	- datacell: a (m x n) cell array with number strings (e.g. {'1','2'})
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: a (m x n) matrix with numbers
% -----------------------------------------------------------------------
% EXAMPLE
%   x = {'1','2','3'};
%   OUT = cell2num(x)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Ensure the input is a cell array before proceeding
if ~iscell(datacell)
    error('cell2num: input must be a cell array')
end

%% 2. CONVERT STRINGS TO NUMBERS
% -----------------------------------------------------------------------
% str2double returns NaN for any cell that is not a valid number string,
% matching the documented behavior ("does not include a number → NaN").
OUT = zeros(size(datacell));
for c = 1:size(datacell,2)
    for r = 1:size(datacell,1)
        OUT(r,c) = str2double(datacell{r,c});
    end
end
