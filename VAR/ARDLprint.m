function [TABLE, beta, tstat] = ARDLprint(ARDL,vnames,approx,vnames_ex)
% =======================================================================
% Format and return the estimation output of an ARDL model
% =======================================================================
% [TABLE, beta, tstat] = ARDLprint(ARDL,vnames,approx,vnames_ex)
% -----------------------------------------------------------------------
% INPUT
%   - ARDL: structure output of ARDLmodel function
%   - vnames: cell array with name of the endogenous variable {1 x 1}
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - approx: number of decimal digits [dflt = 4]
%   - vnames_ex: cell array of exogenous variable names (required if
%       ARDL.nvar_ex > 0)
% -----------------------------------------------------------------------
% OUTPUT
%   - TABLE: coefficients, std errors, t-stats, and p-values [cell array]
%   - beta:  estimated coefficients only [cell array]
%   - tstat: t-statistics only [cell array]
% -----------------------------------------------------------------------
% EXAMPLE
%   y = cumsum(randn(120,1));
%   ARDL = ARDLmodel(y, 2, 1);
%   [TABLE, beta, tstat] = ARDLprint(ARDL, {'y'}, 4);
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
    error('ARDLprint: vnames is required and cannot be empty');
end
if ~exist('approx','var')
    approx = 4;
end
if ARDL.nvar_ex > 0
    if ~exist('vnames_ex','var') || isempty(vnames_ex)
        error('ARDLprint: vnames_ex is required when ARDL.nvar_ex > 0');
    end
end

%% 2. RETRIEVE MODEL PARAMETERS
% -----------------------------------------------------------------------
nlag    = ARDL.nlag;
nlag_ex = ARDL.nlag_ex;
const   = ARDL.const;

% Header label (column header for the table)
htext    = vnames;
nvars    = 1;   % ARDL is single-equation
nvars_ex = ARDL.nvar_ex;

%% 3. LABELS OF DETERMINISTIC COMPONENTS
% -----------------------------------------------------------------------
% Build row labels for the constant and trend terms, matching ARDLmodel ordering
switch const
    case 0
        aux = {};
    case 1
        aux = {'c'};
    case 2
        aux = {'c';'trend'};
end
vtext = {' '};
vtext = [vtext; aux];
clear aux

%% 4. LABELS OF LAGGED ENDOGENOUS VARIABLES
% -----------------------------------------------------------------------
% Preallocate aux for the lag labels of the endogenous variable
aux = cell(nvars,1);
for jj=1:nlag
    for ii=1:nvars
        aux{ii,1} = [vnames{ii} '(-' num2str(jj) ')'];
    end
    vtext = [vtext; aux]; %#ok<AGROW>
end
clear aux

%% 5. LABELS OF EXOGENOUS VARIABLES
% -----------------------------------------------------------------------
% Append contemporaneous and lagged exogenous variable labels
if nvars_ex > 0
    vtext = [vtext; vnames_ex'];
    if nlag_ex > 0
        aux = cell(nvars_ex,1);
        for jj=1:nlag_ex
            for ii=1:nvars_ex
                aux{ii,1} = [vnames_ex{ii} '(-' num2str(jj) ')'];
            end
            vtext = [vtext; aux]; %#ok<AGROW>
        end
        clear aux
    end
end

%% 6. ASSEMBLE OUTPUT TABLES
% -----------------------------------------------------------------------
% Build individual formatted tables for beta, std errors, t-stats, p-values
beta  = roundnum2cell(ARDL.beta,approx);
beta  = [htext; beta];
beta  = [vtext beta];

bstd  = roundnum2cell(ARDL.bstd,approx);
bstd  = [htext; bstd];
bstd  = [vtext bstd];

tstat = roundnum2cell(ARDL.tstat,2);
tstat = [htext; tstat];
tstat = [vtext tstat];

tprob = roundnum2cell(ARDL.tprob,approx);
tprob = [htext; tprob];
tprob = [vtext tprob];

% Interleave beta, std, t-stat, and p-value rows into a single TABLE cell array
nn    = size(beta,1)-1;
TABLE = cell(4*nn, nvars);
index = 1;
for ii=1:nn
    for jj=1:nvars
        TABLE(index,jj)   = beta(1+ii,1+jj);
        TABLE(index+1,jj) = bstd(1+ii,1+jj);
        aux1 = cell2mat(tstat(1+ii,1+jj));     % extract numeric t-stat from cell
        TABLE{index+2,jj} = ['[' num2str(aux1) ']'];  % bracket t-stat
        TABLE(index+3,jj) = tprob(1+ii,1+jj);
    end
    index = index+4;
end
TABLE = [htext; TABLE];

% Build vertical row-label column and append fit statistics at the bottom
TAB_v = cell(size(TABLE,1), 1);
TAB_v{1} = '';
index = 2;
for ii=1:nn
    TAB_v{index}   = vtext{1+ii};
    TAB_v{index+1} = ['std(' vtext{1+ii} ')'];
    TAB_v{index+2} = ['t('   vtext{1+ii} ')'];
    TAB_v{index+3} = ['p('   vtext{1+ii} ')'];
    index = index + 4;
end
TABLE = [TAB_v TABLE];

% Append goodness-of-fit statistics
TABLE{index,1} = 'R2';    TABLE{index,2} = ARDL.rsqr; index = index+1;
TABLE{index,1} = 'R2bar'; TABLE{index,2} = ARDL.rbar; index = index+1;
if const > 0
    TABLE{index,1} = 'F'; TABLE{index,2} = ARDL.F;    index = index+1;
else
    TABLE{index,1} = 'F'; TABLE{index,2} = [];         index = index+1;
end
TABLE{index,1} = 'Obs';   TABLE{index,2} = ARDL.nobs;
