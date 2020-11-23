function OUT = NaN2Num(DATA)
% =======================================================================
% Substitute NaN values with 123456789
% =======================================================================
% OUT = Num2NaN(DATA)
% -----------------------------------------------------------------------
% INPUTS 
%	- DATA: a (m x n) matrix with NaNs 
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: a (m x n) matrix with 123456789 instead of NaNs
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogiocesabianchi@gmail.com
%-------------------------------------------------------------------------

OUT=DATA;
for i=1:size(DATA,1)
    for j=1:size(DATA,2)
        if isnan(DATA(i,j)) == 1
            OUT(i,j) = 123456789;
        end
    end
end

