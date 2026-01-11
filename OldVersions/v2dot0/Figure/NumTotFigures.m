function nfigures = NumTotFigures(row,col,nvar)
% =======================================================================
% Determine the number of figures for a given number of subplots, rows and
% columns
% =======================================================================
% nfigures = NumTotFigures(row,col,nvar)
% -----------------------------------------------------------------------
% INPUT
%	- row: number of rows of the subplot
%	- col: number of columns of the subplot
%	- nvar: number of variables
% -----------------------------------------------------------------------
% OUTPUT
%	- nfigures: number of charts per subplot
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

NumGraphXPage = row*col;

p = floor(nvar./NumGraphXPage);
q = (nvar./NumGraphXPage);

if NumGraphXPage>=nvar
    nfigures=1;
elseif p==q
    nfigures=p;
else
    nfigures=p+1;
end
clear p q