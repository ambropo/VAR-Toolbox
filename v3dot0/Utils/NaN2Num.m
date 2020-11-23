function OUT = NaN2Num(DATA)
% =======================================================================
% Substitute NaN values with 123456789
% =======================================================================
% OUT = Num2NaN(DATA)
% -----------------------------------------------------------------------
% INPUT
%	- DATA: a (m x n) matrix with NaNs 
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: a (m x n) matrix with 123456789 instead of NaNs
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [NaN 2; NaN 4; 5 6; 7 8; 9 10];
%   OUT = NaN2Num(x)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

OUT=DATA;
for i=1:size(DATA,1)
    for j=1:size(DATA,2)
        if isnan(DATA(i,j)) == 1
            OUT(i,j) = 123456789;
        end
    end
end

