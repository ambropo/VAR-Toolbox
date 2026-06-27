function [TABLE, beta] = OLSprint(OLS,vnames,ynames,approx)
% =======================================================================
% Prints the output of an OLS estimation
% =======================================================================
% [TABLE, beta] = OLSprint(OLS,vnames,ynames,approx)
% -----------------------------------------------------------------------
% INPUT
%   - OLS: structure output of OLSmodel function
%   - vnames: name of the variables (no constant or trends)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - ynames: name of the dependent variable [dflt = {''}]
%   - approx: number of decimal digits [dflt = 4]
% -----------------------------------------------------------------------
% OUTPUT
%   - TABLE: coefficients, std errors, t-stats, and p-values [cell array]
%   - beta:  estimated coefficients only [cell array]
% -----------------------------------------------------------------------
% EXAMPLE
%   x = randn(100,2); y = x*[1;2] + randn(100,1);
%   OLS = OLSmodel(y, x, 1);
%   [TABLE, beta] = OLSprint(OLS, {'x1','x2'}, {'y'});
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate required inputs and set defaults for optional arguments
if ~exist('vnames','var') || isempty(vnames)
    error('OLSprint: vnames is required and cannot be empty');
end
if ~exist('ynames','var')
    ynames = {''};
end
if ~exist('approx','var')
    approx = 4;
end

% Ensure vnames is a column cell array
if size(vnames,1)==1
    vnames = vnames';
end

%% 2. RETRIEVE AND INITIALIZE VARIABLES
% -----------------------------------------------------------------------
% Extract estimation metadata and pre-allocate the output array TAB.
% Each regressor occupies four rows: beta, std, t-stat, p-value.
const = OLS.const;
r = length(OLS.beta);
TAB = nan(4*r+4,1);

%% 3. LABELS OF DETERMINISTIC COMPONENTS
% -----------------------------------------------------------------------
% Build the label prefix for any deterministic terms (constant, trend)
% added internally by OLSmodel, then prepend to vnames.
switch const
    case 0
        aux = [];
    case 1
        aux = {'c'};
    case 2
        aux = {'c';'trend'};
end
vnames = [aux; vnames];
clear aux

%% 4. LABELS OF REGRESSORS
% -----------------------------------------------------------------------
% Fill TAB with coefficient, std error, t-stat, and p-value for each
% regressor; vtext records the corresponding row label for display.
vtext = cell(4*r+4,1);
indexb = 1; indexs = 2; indext = 3; indexp = 4;
for ii=1:r
    TAB(indexb,1) = OLS.beta(ii);
    TAB(indexs,1) = OLS.bstd(ii);
    TAB(indext,1) = OLS.tstat(ii);
    TAB(indexp,1) = OLS.tprob(ii);
    vtext(indexb,1) = vnames(ii);
    vtext(indexs,1) = {['std(' vnames{ii} ')']};
    vtext(indext,1) = {['t(' vnames{ii} ')']};
    vtext(indexp,1) = {['p(' vnames{ii} ')']};
    indexb = indexb+4;
    indexs = indexs+4;
    indext = indext+4;
    indexp = indexp+4;
end

% Append goodness-of-fit statistics: R2, adjusted R2, F-stat, and nobs
index = indexb;
TAB(index) = OLS.rsqr; vtext(index) = {'R2'};    index = index+1;
TAB(index) = OLS.rbar; vtext(index) = {'R2bar'}; index = index+1;
if const>0
    TAB(index) = OLS.F;    vtext(index) = {'F'};     index = index+1;
else
    TAB(index) = NaN;   vtext(index) = {'F'};     index = index+1;
end
TAB(index) = OLS.nobs; vtext(index) = {'Obs'};

%% 5. SAVE
% -----------------------------------------------------------------------
% Format and store results as cell arrays via TabPrint.
beta = TabPrint(OLS.beta,ynames,vnames,approx);
TABLE = TabPrint(TAB,ynames,vtext,approx);

%% 6. PRINT TABLE ON SCREEN
% -----------------------------------------------------------------------
% Display the full estimation table to the MATLAB command window.
info.cnames = char(ynames);
info.rnames = char([{''}; vtext]);
disp(' ')
disp('OLS estimation:')
disp(' ')
mprint(TAB,info)
