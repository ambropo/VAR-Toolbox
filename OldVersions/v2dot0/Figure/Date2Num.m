function OUT = Date2Num(DATA)
% =======================================================================
% Substitute cell dates 1989Q4 with numeric dates 1989.75. Only for
% quarterly data.
% =======================================================================
% OUT = Date2Num(DATA)
% -----------------------------------------------------------------------
% INPUTS 
%	- DATA: a (T x 1) vector with dates in cell format 
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT:  a (T x 1) vector with dates in numeric format
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogiocesabianchi@gmail.com
%-------------------------------------------------------------------------

OUT = nan(size(DATA,1),size(DATA,2));
for i=1:size(DATA,1)
    for j=1:size(DATA,2)
        aux = DATA{i,j};
        year = str2double(aux(1:4));
        quarter = str2double(aux(6));
        OUT(i,j) = year + quarter/4 -0.25;
    end
end
