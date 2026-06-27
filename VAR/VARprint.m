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
% -----------------------------------------------------------------------
% OUTPUT
%   - TABLE: table of estimated coefficients, std errors, t-stats, and p
%       values in cell array
%   - beta: table of estimated coefficients only in cell array
% -----------------------------------------------------------------------
% EXAMPLE
%   ENDO = randn(80,2); VARopt = VARoption; VARopt.vnames = {'y','pi'};
%   VAR = VARmodel(ENDO, 2, 1); [TABLE, beta] = VARprint(VAR, VARopt, 4);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end
% If there is VARopt get the vnames
vnames = VARopt.vnames;
if isempty(vnames); vnames = VARopt.mnem; end   % fall back to mnemonics
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

%% 2. RETRIEVE AND INITIALIZE VARIABLES
% -----------------------------------------------------------------------
% Extract dimensions and specification flags from the VAR struct for use
% in label construction and table assembly below.
nlag      = VAR.nlag;
nlag_ex   = VAR.nlag_ex;
ncoeff_es = VAR.ncoeff_es;
const     = VAR.const;

% Per-equation field names as resolved by VARmodel (VAR.eqnames). Fall back
% to eq1,...,eqN for structs produced before VAR.eqnames was introduced.
if isfield(VAR,'eqnames')
    eqnames = VAR.eqnames;
else
    eqnames = cell(VAR.nvar,1);
    for ii = 1:VAR.nvar
        eqnames{ii} = ['eq' num2str(ii)];
    end
end

%% 3. ADDITIONAL CHECKS
% -----------------------------------------------------------------------
% Check size of vnames (and change it if necessary)
htext = vnames;
if size(htext,2)==1
    htext = htext';
    nvars = size(htext,2);
else
    nvars = size(htext,2);
end

% Check size of vnames_ex (and change it if necessary)
if size(vnames_ex,2)==1
    vnames_ex = vnames_ex';
    nvars_ex = size(vnames_ex,2);
else
    nvars_ex = size(vnames_ex,2);
end

%% 4. LABELS OF DETERMINISTIC COMPONENTS
% -----------------------------------------------------------------------
% Build the cell array of row labels for constant and trend terms
switch const
    case 0
        aux = [];            
    case 1
        aux = {'c'};
    case 2
        aux = {'c';'trend'};
end
vtext = {' '};
vtext = [vtext; aux];
clear aux

%% 5. LABELS OF LAGGED ENDOGENOUS VARIABLES
% -----------------------------------------------------------------------
% Append one label per variable per lag (e.g. 'GDP(-1)', 'GDP(-2)', ...)
% to vtext, keeping the row order aligned with VAR.Ft.
for jj=1:nlag
    for ii=1:nvars
        aux(ii,1) = {[vnames{ii} '(-' num2str(jj) ')' ]};
    end
    vtext = [vtext ; aux];
end
clear aux

%% 6. LABELS OF EXOSHOCK VARIABLE
% -----------------------------------------------------------------------
% When ident='exog', VAR.Ft has ncoeff_es extra rows (contemporaneous +
% lagged exoshock) between the lag block and the EXOG block. Add labels to
% keep vtext aligned with the rows of VAR.Ft.
if ncoeff_es > 0
    aux_es = {'exoshock'};
    for jj = 1:ncoeff_es-1
        aux_es{end+1,1} = ['exoshock(-' num2str(jj) ')'];
    end
    vtext = [vtext; aux_es];
    clear aux_es jj
end

%% 7. LABELS OF EXOGENOUS VARIABLES
% -----------------------------------------------------------------------
% Append contemporaneous and lagged exogenous variable labels to vtext,
% matching the column order in VAR.Ft.
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

%% 8. SAVE
% -----------------------------------------------------------------------
% Assemble cell-array tables for coefficients, standard errors, t-statistics,
% and p-values; combine into a single TABLE with a row label column.
% Save a beta table
beta = roundnum2cell(VAR.Ft,approx);
beta = [htext; beta];
beta = [vtext beta];

% Save a standard error table
bstd = [];
for ii=1:nvars
    aux = VAR.(eqnames{ii}).bstd;
    bstd = [bstd aux];
end
bstd = roundnum2cell(bstd,approx);
bstd = [htext; bstd];
bstd = [vtext bstd];
clear aux

% Save a tstat table
tstat = [];
for ii=1:nvars
    aux = VAR.(eqnames{ii}).tstat;
    tstat = [tstat aux];
end
tstat = roundnum2cell(tstat,2);
tstat = [htext; tstat];
tstat = [vtext tstat];
clear aux

% Save a p-value table
tprob = [];
for ii=1:nvars
    aux = VAR.(eqnames{ii}).tprob;
    tprob = [tprob aux];
end
tprob = roundnum2cell(tprob,approx);
tprob = [htext; tprob];
tprob = [vtext tprob];
clear aux

% Build combined TABLE: 4 rows per regressor (beta, bstd, t-stat, p-value)
nn = size(beta,1)-1;
TABLE = {''};
index = 1;
for ii=1:nn
    for jj=1:nvars
        TABLE(index,jj) = beta(1+ii,1+jj);
        TABLE(index+1,jj) = bstd(1+ii,1+jj);
        TABLE{index+2,jj} = ['[' tstat{1+ii,1+jj} ']'];
        TABLE(index+3,jj) = tprob(1+ii,1+jj);
    end
    index = index+4;
end
for jj=1:nvars
    TABLE(index,jj)   = num2cell(VAR.(eqnames{jj}).rsqr);
    TABLE(index+1,jj) = num2cell(VAR.(eqnames{jj}).rbar);
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

%% 9. PRINT TABLE ON SCREEN
% -----------------------------------------------------------------------
% Display coefficient matrix, eigenvalues, and VCV using mprint
format short g
info.cnames = char(htext);
info.rnames = char(vtext);
disp(' ')
%disp('---------------------------------------------------------------------')
disp(' ')
disp('Reduced form VAR estimation:')
disp(' ')
mprint(VAR.Ft,info)
%disp('---------------------------------------------------------------------')
disp(' ')
disp('VAR eigenvalues:')
disp(eig(VAR.Fcomp))
disp(' ')
disp('Reduced-form covariance matrix:')
disp(VAR.sigma)
