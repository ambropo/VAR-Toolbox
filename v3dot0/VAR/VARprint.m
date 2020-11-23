function [TABLE, beta] = VARprint(VAR,VARopt,approx)
% =======================================================================
% Prints the output of a VAR estimation
% =======================================================================
% [TABLE, beta] = VARprint(VAR,VARopt,approx)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure output of VARmodel function
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - approx: number of decimal digits. Default = 4
%------------------------------------------------------------------------
% OUPUT
%   - TABLE: table of estimated coefficients, std errors, t-stats, and p 
%       values in in cell array
%   - beta: table of estimated coefficients only in cell array
% -----------------------------------------------------------------------
% EXAMPLE
%   - See VARToolbox_Code.m in "../Primer/"
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


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

% Save a standard error table
bstd = [];
for ii=1:nvars
    eval( ['aux = VAR.eq' num2str(ii) '.bstd;'] );
    bstd = [bstd aux];
end
bstd = roundnum2cell(bstd,approx);
bstd = [htext; bstd];
bstd = [vtext bstd];
clear aux

% Save a tstat table
tstat = [];
for ii=1:nvars
    eval( ['aux = VAR.eq' num2str(ii) '.tstat;'] );
    tstat = [tstat aux];
end
tstat = roundnum2cell(tstat,2);
tstat = [htext; tstat];
tstat = [vtext tstat];
clear aux

% Save a p-value table
tprob = [];
for ii=1:nvars
    eval( ['aux = VAR.eq' num2str(ii) '.tprob;'] );
    tprob = [tprob aux];
end
tprob = roundnum2cell(tprob,approx);
tprob = [htext; tprob];
tprob = [vtext tprob];
clear aux

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
for jj=1:nvars
    eval( ['aux = VAR.eq' num2str(jj) '.rsqr;'] ); TABLE(index,jj) = num2cell(aux); 
    eval( ['aux = VAR.eq' num2str(jj) '.rbar;'] ); TABLE(index+1,jj) = num2cell(aux); 
    TABLE(index+2,jj) = num2cell(VAR.nobs); 
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
TAB_v(index,1) = {'R2'};    
TAB_v(index+1,1) = {'R2bar'};
TAB_v(index+2,1) = {'Obs'};  
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






    