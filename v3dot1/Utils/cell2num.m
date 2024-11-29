function OUT = cell2num(datacell)
% =======================================================================
% Convert a cell array (of numbers) into a double array. If the cell array
% does not include a number returns NaN
% =======================================================================
% OUT = cell2num(datacell)
% -----------------------------------------------------------------------
% INPUT
%	- datacell: a (m x n) cell array with numbers
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: a (m x n) matrix with numbers
% -----------------------------------------------------------------------
% EXAMPLE
%   x = {'1','2','3'};
%   OUT = cell2num(x)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

if ~iscell(datacell)
    error('Input has to be a cell array')
end

% Initialize
OUT = zeros(size(datacell));

% Convert
for c=1:size(datacell,2)
    for r=1:size(datacell,1)
        OUT(r,c)=str2double(datacell{r,c});
    end  
end
