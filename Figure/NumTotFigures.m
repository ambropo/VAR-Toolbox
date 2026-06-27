function nfigures = NumTotFigures(row,col,nvar)
% =======================================================================
% Determine the number of figures needed to display nvar panels arranged
% in a row-by-col subplot grid
% =======================================================================
% nfigures = NumTotFigures(row,col,nvar)
% -----------------------------------------------------------------------
% INPUT
%   - row : number of subplot rows per figure [double]
%   - col : number of subplot columns per figure [double]
%   - nvar: total number of variables (panels) to plot [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - nfigures: number of figures required [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   nfigures = NumTotFigures(3,4,10)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. COMPUTE NUMBER OF FIGURES NEEDED
% -----------------------------------------------------------------------
% Panels that fit on a single figure
NumGraphXPage = row * col;

% p is the integer number of full pages; q is the exact (possibly
% fractional) number. If p==q the panels divide evenly into full pages;
% otherwise one extra page is needed for the remainder.
p = floor(nvar / NumGraphXPage);
q =       nvar / NumGraphXPage;

% Return 1 if all panels fit on one page; p if they divide evenly; p+1 otherwise
if NumGraphXPage >= nvar
    nfigures = 1;
elseif p == q
    nfigures = p;
else
    nfigures = p + 1;
end
