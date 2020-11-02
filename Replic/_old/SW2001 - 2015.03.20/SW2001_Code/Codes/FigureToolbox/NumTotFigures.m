function nfigures = NumTotFigures(row,col,nvars)
% =======================================================================
% Determine how many figures are needed for a given number of subplots
% =======================================================================
% nfigures = NumTotFigures(row,col,nvars)
% -----------------------------------------------------------------------
% INPUTS 
%	- row   : number of rows of the subplot
%	- col   : number of columns of the subplot
%	- nvars : number of variables
%
% =========================================================================
% Ambrogio Cesa Bianchi, February 2012
% ambrogio.cesabianchi@gmail.com



NumGraphXPage = row*col;

p = floor(nvars./NumGraphXPage);
q = (nvars./NumGraphXPage);

if NumGraphXPage>=nvars
    nfigures=1;
elseif p==q
    nfigures=p;
else
    nfigures=p+1;
end
clear p q