function [TABLE, beta, tstat] = ARDLprint(ARDL,vnames,approx,vnames_ex)
% =======================================================================
% Prints the output of a VAR estimation
% =======================================================================
% [beta, tstat, TABLE] = VARprint(VAR,VARopt,approx)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure output of VARmodel function
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   approx: number of decimal digits. Default = 4
%------------------------------------------------------------------------
% OUPUT
%   beta: table of estimated coefficients in cell array
%   tstat: table of t-stats in cell array
%   TABLE: table of estimated coefficients and t-stats in cell array
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% Check inputs
%===============================================
% Check they are not empty
if isempty(vnames)
    error('You need to add label for endogenous variables in VARopt');
end
if ~exist('approx','var')
    approx = 4;
end
if ARDL.nvar_ex>0
    if ~exist('vnames_ex','var')
        error('You need to add label for exogenous variables');
    end
end

%% Retrieve and initialize variables 
%=============================================================
nlag = ARDL.nlag;
nlag_ex = ARDL.nlag_ex;
const = ARDL.const;
% vnames_ex = vnames(2:end);
% vnames = vnames(1);

%% Additional checks
%=============================================================
% Check size of vnames (and change it if necessary)
htext = vnames;
nvars = 1;
nvars_ex = 1;

%% Labels of deterministic components
%===============================================
switch const
    case 0
        aux = [];            
    case 1
        aux = {'c'};
    case 2
        aux = {'c';'trend'};
    case 3
        aux = {'c';'trend';'trend2'};
end
vtext = {' '};
vtext = [vtext; aux];
clear aux

%% Labels of lagged variables
%===============================================
for jj=1:nlag
    for ii=1:nvars
        aux(ii,1) = {[vnames{ii} '(-' num2str(jj) ')' ]};
    end
    vtext = [vtext ; aux];
end
clear aux

%% Labels of exogenous variables
%===============================================
vtext = [vtext ; vnames_ex'];
if nlag_ex > 0
    for jj=1:nlag_ex
        for ii=1:nvars_ex
            aux(ii,1) = {[vnames_ex{ii} '(-' num2str(jj) ')' ]};
        end
        vtext = [vtext ; aux];
    end
    clear aux
end


%% Save
%===============================================
% Save a beta table
beta = roundnum2cell(ARDL.beta,approx);
beta = [htext; beta];
beta = [vtext beta];

% Save a std err table
bstd = roundnum2cell(ARDL.bstd,approx);
bstd = [htext; bstd];
bstd = [vtext bstd];

% Save a tstat table
tstat = ARDL.tstat;
tstat = roundnum2cell(tstat,2);
tstat = [htext; tstat];
tstat = [vtext tstat];

% Save a p-value table
tprob = ARDL.tprob;
tprob = roundnum2cell(tprob,approx);
tprob = [htext; tprob];
tprob = [vtext tprob];

% Save a beta & tstat table
nn = size(beta,1)-1;
TABLE = {''};
index = 1;
for ii=1:nn
    for jj=1:nvars
        TABLE(index,jj) = beta(1+ii,1+jj);
        TABLE(index+1,jj) = bstd(1+ii,1+jj);
        aux1 = cell2mat(tstat(1+ii,1+jj)); % get the numeric value from cell
        aux2 = [ '[' num2str(aux1) ']' ];  % add parenthesis to t-stat value
        TABLE{index+2,jj} = aux2;
        TABLE(index+3,jj) = tprob(1+ii,1+jj);
    end
    index = index+4;
end
clear aux
TABLE = [htext; TABLE];

% Create vertical label
TAB_v = {''};
index = 2;
for ii=1:nn
    TAB_v(index,1) = vtext(1+ii);
    TAB_v(index+1,1) = {['std(' vtext{1+ii} ')']};
    TAB_v(index+2,1) = {['t(' vtext{1+ii} ')']};
    TAB_v(index+3,1) = {['p(' vtext{1+ii} ')']};
    index = index + 4;
end
TABLE = [TAB_v TABLE];
TABLE(index,2) = num2cell(ARDL.rsqr); TABLE(index,1) = {'R2'};    index = index+1; 
TABLE(index,2) = num2cell(ARDL.rbar); TABLE(index,1) = {'R2bar'}; index = index+1;
if const>0
    TABLE(index,2) = num2cell(ARDL.F); TABLE(index,1) = {'F'};     index = index+1;
else
    TABLE(index,2) = [];               TABLE(index,1) = {'F'};     index = index+1;
end
TABLE(index,2) = num2cell(ARDL.nobs);  TABLE(index,1) = {'Obs'};   index = index+1;
% 
% %% Print the table on screen (only beta)
% %===============================================
% info.cnames = char(htext);
% info.rnames = char(vtext);
% disp(' ')
% %disp('---------------------------------------------------------------------')
% disp(' ')
% disp('Reduced form VAR estimation:')
% disp(' ')
% mprint(ARDL.Ft,info)
% %disp('---------------------------------------------------------------------')






    