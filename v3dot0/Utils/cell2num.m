function OUT = cell2num(datacell)
% =======================================================================
% Convert a cell array (of numbers) into a double array. If the cell arrqay
% does not include a number returns NaN
% =======================================================================
% OUT = cell2num(datacell)
% -----------------------------------------------------------------------
% INPUTS 
%	- datacell: a (m x n) cell array with numbers
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: a (m x n) matrix with numbers
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogiocesabianchi@gmail.com
%-------------------------------------------------------------------------

if ~iscell(datacell)
    error('Input has to be a cell array')
end

% Initialize
OUT = zeros(size(datacell));

% Convert
for c=1:size(datacell,2)
    for r=1:size(datacell,1)
        if isnumeric(datacell{r,c})
            OUT(r,c)=datacell{r,c};
        else
            OUT(r,c)=NaN;
        end
    end  
end
