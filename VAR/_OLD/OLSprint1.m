function OUT = OLSprint(OLS,vnames,snames,approx)
% =======================================================================
% Prints the output of an OLS estimation
% =======================================================================
% [beta, tstat, TABLE] = OLSprint(OLS,hlabel,vlabel,approx)
% -----------------------------------------------------------------------
% INPUT
%   - OLS: structure output of OLSmodel function
%   - vnames: name of the variables
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - snames: name of the specification
%   - approx: number of decimal digits. Default = 4
%------------------------------------------------------------------------
% OUPUT
%   beta:  table of estimated coefficients in cell array
%   tstat: table of t-stats in cell array
%   TABLE: table of estimated coefficients and t-stats in cell array
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


vnames = {'a','b','c'}
r = length(OLS.beta);
indexb = 1;
indext = 2;
for ii=1:r
    TAB(indexb,1) = OLS.beta(ii);
    TAB(indext,1) = OLS.tstat(ii);   
    vnames(indexb,1) = vnames(ii);
    indexb = indexb+2;
    indext = indext+2;
end
index = indexb;
TAB(index) = OLS.rsqr; vnames(index) = {'R2'};    index = index+1; 
TAB(index) = OLS.rbar; vnames(index) = {'R2bar'}; index = index+1;
TAB(index) = OLS.F;    vnames(index) = {'F'};     index = index+1;
TAB(index) = OLS.nobs; vnames(index) = {'Obs'};   index = index+1;

TabPrint(TAB,[],vnames)
