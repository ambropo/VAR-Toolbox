function [CORR, OUT] = CorrUnbalanced(DATA,labels)
% =======================================================================
% Compute correlation of a panel of time series DATA (with T
% observations and N variables) using rows with no missing values in
% column i or j.
%
% note: for each pair of columns, the correlation is computed using the
% maximum amount of available observations. This is to deal with
% unbalanced panels. Therefore, NaN are accepted.
% =======================================================================
% [CORR, OUT] = CorrUnbalanced(DATA,labels)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: matrix T (observations) x N (variables) [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - labels: names of each variable j [dflt = 'Variable']
% -----------------------------------------------------------------------
% OUTPUT
%	- CORR: matrix of correlation N x N [double]
%	- OUT.N: number of observations used for each pair [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = randn(50,4);
%   [CORR, OUT] = CorrUnbalanced(DATA);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Validate input, extract panel dimensions, and set default variable names.
if nargin < 1
    error('CorrUnbalanced: DATA is a required input.')
end

% Extract the number of variables from the column dimension
[~, nvar] = size(DATA);

% If no names are provided set it to 'Variable'
if ~exist('labels','var')
    labels(1,1:nvar) = {'Variable'};
end

% If labels are entered as jx1 vector, transpose it
if size(labels,1) > 1
    labels = labels';
end

%% 2. COMPUTE PAIRWISE CORRELATION
% -----------------------------------------------------------------------
% For each pair (ii,jj), use only rows where neither series is NaN.
% If a series is constant, corr() returns NaN; the diagonal is forced to 1.
CORR = nan(nvar,nvar);
OUT.N = nan(nvar,nvar);
for ii=1:nvar
    X1 = DATA(:,ii);
    for jj=1:nvar
        X2 = DATA(:,jj);
        Y = CommonSample([X1 X2]);
        if isempty(Y)
            CORR(ii,jj) = NaN;
            OUT.N(ii,jj) = 0;
        else
            aux = corr(Y(:,1),Y(:,2));
            OUT.N(ii,jj) = length(Y);
            % If there is no variation in the data, corr() yields NaN.
            % The diagonal is forced to 1; off-diagonal entries stay NaN.
            if isnan(aux)
                if ii==jj
                    CORR(ii,jj) = 1;
                else
                    CORR(ii,jj) = NaN;
                end
            else
                CORR(ii,jj) = aux;
            end
        end
    end
end
