function [TABLE, beta] = OLSprint(OLS,vnames,ynames,approx) 
% =======================================================================
% Prints the output of an OLS estimation
% =======================================================================
% [TABLE, beta] = OLSprint(OLS,vnames,snames,approx)
% -----------------------------------------------------------------------
% INPUT
%   - OLS: structure output of OLSmodel function
%   - vnames: name of the variables (no constant or trends)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - ynames: name of the dependent variable
%   - approx: number of decimal digits. Default = 4
%------------------------------------------------------------------------
% OUPUT
%   - TABLE: table of estimated coefficients, std errors, t-stats, and p 
%       values in in cell array
%   - beta: table of estimated coefficients only in cell array
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% Check inputs
%===============================================
if ~exist('vnames','var')
    error('You need to provide variable names');
end
if ~exist('snames','var')
    ynames = {''};
end
if ~exist('approx','var')
    approx = 4;
end
if size(vnames,1)==1
    vnames = vnames';
end

%% Retrieve and initialize variables 
%=============================================================
const = OLS.const;
r = length(OLS.beta);
TAB = nan(2*r+4,1);


%% Table: deterministic components
%=============================================================
switch const
    case 0
        aux = [];            
    case 1
        aux = {'c'};
    case 2
        aux = {'c';'trend';};
    case 3
        aux = {'c';'trend';'trend2'};
end
vnames = [aux; vnames];
clear aux

%% Table: regressors
%=============================================================
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
index = indexb;
TAB(index) = OLS.rsqr; vtext(index) = {'R2'};    index = index+1; 
TAB(index) = OLS.rbar; vtext(index) = {'R2bar'}; index = index+1;
if const>0
    TAB(index) = OLS.F;    vtext(index) = {'F'};     index = index+1;
else
    TAB(index) = [];    vtext(index) = {'F'};     index = index+1;
end
TAB(index) = OLS.nobs; vtext(index) = {'Obs'};   index = index+1;

%% Save
%===============================================
beta = TabPrint(OLS.beta,ynames,vnames,approx);
TABLE = TabPrint(TAB,ynames,vtext,approx);

%% Print the TABLE on screen
%===============================================
info.cnames = char(ynames);
info.rnames = char([{''}; vtext]);
disp(' ')
disp('OLS estimation:')
disp(' ')
mprint(TAB,info)

