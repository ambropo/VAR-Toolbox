function [BETA, TSTAT, BETA_TSTAT] = VARprint(VAR,end_names,ex_names,approx)
% =======================================================================
% Prints the output of a VAR estimation
% =======================================================================
% BETA = VARprint(VAR,end_names)
% -----------------------------------------------------------------------
% INPUT
%   VAR       : structure output of VARmodel function
%   end_names : endogenous names of the variables
%   ex_names  : exogenous names of the variables
%
% OPTIONAL INPUT
%   approx    : number of decimal digits. Default = 2
%------------------------------------------------------------------------
% OUPUT
%   BETA      : table of estimated coefficients in cell array
%   TSTATS    : table of t-stats in cell array
%   BETA_TSTAT: table of estimated coefficients and t-stats in cell array
% =======================================================================
% Ambrogio Cesa Bianchi, May 2012
% ambrogio.cesabianchi@gmail.com

% Initialize data
nlags     = VAR.nlag;
nlags_ex  = VAR.nlag_ex;
c_case    = VAR.c_case;

% Check inputs
if ~exist('approx','var')
    approx = 2;
end

if VAR.nvar_ex>0
    if ~exist('ex_names','var')
        error('Label for exogenous variables is missing');
    end
end

% Check size of end_names (and change it if necessary)
htext = end_names;
if size(htext,2)==1
    htext = htext';
    nvars = size(htext,2);
else
    nvars = size(htext,2);
end

% Check size of ex_names (and change it if necessary)
if exist('ex_names','var')
    if size(ex_names,2)==1
        ex_names = ex_names';
        nvars_ex = size(ex_names,2);
    else
        nvars_ex = size(ex_names,2);
    end
end

% Labels of deterministic components
switch c_case
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

% Labels of lagged variables
for jj=1:nlags
    for ii=1:nvars
        aux(ii,1) = {[end_names{ii} '(-' num2str(jj) ')' ]};
    end
    vtext = [vtext ; aux];
end
clear aux

% Labels of exogenous variables
if VAR.nvar_ex>0
    vtext = [vtext ; ex_names'];
    if nlags_ex > 0
        for jj=1:nlags_ex
            for ii=1:nvars_ex
                aux(ii,1) = {[ex_names{ii} '(-' num2str(jj) ')' ]};
            end
            vtext = [vtext ; aux];
        end
        clear aux
    end
end

% Save a BETA table
BETA = roundnum2cell(VAR.beta,approx);
BETA = [htext; BETA];
BETA = [vtext BETA];

% Save a TSTAT table
TSTAT = [];
for ii=1:nvars
    eval( ['aux = VAR.eq' num2str(ii) '.tstat;'] );
    TSTAT = [TSTAT aux];
end
TSTAT = roundnum2cell(TSTAT,approx);
TSTAT = [htext; TSTAT];
TSTAT = [vtext TSTAT];
clear aux

% Save a BETA & TSTAT table
nn = size(BETA,1)-1;
BETA_TSTAT = {''};
mm = 1;
for ii=1:nn
    for jj=1:nvars
        BETA_TSTAT(mm,jj) = BETA(1+ii,1+jj);
        aux1 = cell2mat(TSTAT(1+ii,1+jj)); % get the numeric value from cell
        aux2 = [ '[' num2str(aux1) ']' ];  % add parenthesis to t-stat value
        BETA_TSTAT{mm+1,jj} = aux2;
    end
    mm = mm + 2;
end
clear aux
BETA_TSTAT = [htext; BETA_TSTAT];
TAB_v = {''};
mm = 2;
for ii=1:nn
    TAB_v(mm,1) = vtext(1+ii);
    TAB_v(mm+1,1) = {''};
    mm = mm + 2;
end
BETA_TSTAT = [TAB_v BETA_TSTAT];

% Print the table on screen (only BETAS)
info.cnames = char(htext);
info.rnames = char(vtext);
disp(' ')
disp('---------------------------------------------------------------------')
disp(' ')
disp('Reduced form VAR estimation:')
disp(' ')
mprint(VAR.beta,info)
disp('---------------------------------------------------------------------')






    