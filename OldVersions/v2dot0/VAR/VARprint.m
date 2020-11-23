function [beta, tstat, TABLE] = VARprint(VAR,VARopt,approx)
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
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% Check inputs
%===============================================
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end
% If there is VARopt get the vnames
vnames = VARopt.vnames;
vnames_ex = VARopt.vnames_ex;
% Check they are not empty
if isempty(vnames)
    error('You need to add label for endogenous variables in VARopt');
end
if VAR.nvar_ex>0
    if isempty(vnames_ex)
        error('You need to add label for exogenous variables in VARopt');
    end
end
if ~exist('approx','var')
    approx = 4;
end

%% Retrieve and initialize variables 
%=============================================================
nlag = VAR.nlag;
nlag_ex = VAR.nlag_ex;
const = VAR.const;


%% Additional checks
%=============================================================
% Check size of vnames (and change it if necessary)
htext = vnames;
if size(htext,2)==1
    htext = htext';
    nvars = size(htext,2);
else
    nvars = size(htext,2);
end

% Check size of vnames_ex (and change it if necessary)
if exist('vnames_ex','var')
    if size(vnames_ex,2)==1
        vnames_ex = vnames_ex';
        nvars_ex = size(vnames_ex,2);
    else
        nvars_ex = size(vnames_ex,2);
    end
end

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
if VAR.nvar_ex>0
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
end

%% Save
%===============================================
% Save a beta table
beta = roundnum2cell(VAR.Ft,approx);
beta = [htext; beta];
beta = [vtext beta];

% Save a tstat table
tstat = [];
for ii=1:nvars
    eval( ['aux = VAR.eq' num2str(ii) '.tstat;'] );
    tstat = [tstat aux];
end
tstat = roundnum2cell(tstat,approx);
tstat = [htext; tstat];
tstat = [vtext tstat];
clear aux

% Save a beta & tstat table
nn = size(beta,1)-1;
TABLE = {''};
mm = 1;
for ii=1:nn
    for jj=1:nvars
        TABLE(mm,jj) = beta(1+ii,1+jj);
        aux1 = cell2mat(tstat(1+ii,1+jj)); % get the numeric value from cell
        aux2 = [ '[' num2str(aux1) ']' ];  % add parenthesis to t-stat value
        TABLE{mm+1,jj} = aux2;
    end
    mm = mm + 2;
end
clear aux
TABLE = [htext; TABLE];
TAB_v = {''};
mm = 2;
for ii=1:nn
    TAB_v(mm,1) = vtext(1+ii);
    TAB_v(mm+1,1) = {''};
    mm = mm + 2;
end
TABLE = [TAB_v TABLE];

%% Print the table on screen (only beta)
%===============================================
info.cnames = char(htext);
info.rnames = char(vtext);
disp(' ')
%disp('---------------------------------------------------------------------')
disp(' ')
disp('Reduced form VAR estimation:')
disp(' ')
mprint(VAR.Ft,info)
%disp('---------------------------------------------------------------------')






    