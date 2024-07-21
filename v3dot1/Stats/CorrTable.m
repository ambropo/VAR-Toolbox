function [CORR, TABLE] = CorrTable(x,vnames,pairwise)
% =======================================================================
% Computes the correlation matrix of a matrix of time series with titles
% =======================================================================
% out = CorrTable(x,vnames)
% -----------------------------------------------------------------------
% INPUT
%   - x: matrix (rows x cols) [double]
%   - vnames: array (1 x cols) with names of the (cols) series [cell]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - pairwise: default 0, change to 1 to compute pairwise correlations
% -----------------------------------------------------------------------
% OUTPUT
%   - CORR: correlation matrix [double]
%   - TABLE: table of correlation matrix with titles [cell]
% -----------------------------------------------------------------------
% EXAMPLE
%   x = rand(50,2);
%   [CORR, TABLE] = CorrTable(x,{'Consumption','Investment'})
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------

% If no dimension is specified, set it to 1
if ~exist('pairwise','var')
    pairwise = 0;
end

% vnames must be a row vector
if size(vnames,1)>1
    vnames = vnames';
end

% Compute correlation
if pairwise==0
    CORR = corr(x);
elseif pairwise==1
    CORR = corr(x,'rows','pairwise');
end    
[r, ~] = size(CORR);

% Place NaNs on the upper triangular
CORR(find(triu(CORR))) = NaN;
jj = 1;
for ii=1:r
    CORR(ii,jj) = 1;
    jj = jj +1;
end

% Save position of NaNs
nans = isnan(CORR);

% Transform table into cell array
TAB = num2cell(CORR);

% Add vnames on top
TAB = [vnames ; TAB];

% Add vnames on the left
aux = [{''} vnames]';
TABLE = [aux TAB];

% Print using mprint
info.cvnames = char(vnames);
info.rvnames = char([{' '} vnames]);
mprint(CORR,info);