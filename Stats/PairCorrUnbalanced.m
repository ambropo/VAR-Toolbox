function [PC, TABLE] = PairCorrUnbalanced(DATA,labels,absolute)
% =======================================================================
% Compute mean pairwise correlations (levels and log-differences) for an
% unbalanced panel, using the maximum available observations per pair.
% =======================================================================
% [PC, TABLE] = PairCorrUnbalanced(DATA,labels,absolute)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: matrix T (observations) x N (variables) [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - labels  : cell array of variable names [dflt = 'Variable']
%   - absolute: 1 to average absolute correlations instead of signed
%               correlations [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - PC   : matrix N x 2 of mean pairwise correlations (col 1: levels,
%            col 2: log-differences) [double]
%   - TABLE: cell array with variable labels and formatted correlation
%            values, suitable for display [cell]
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = randn(50,4);
%   DATA(DATA < 0) = NaN;           % introduce some missing values
%   [PC, TABLE] = PairCorrUnbalanced(DATA);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
% Validate required input and set defaults for optional arguments.
if nargin < 1
    error('PairCorrUnbalanced: DATA is a required input.')
end
[row, col] = size(DATA);

% If no names are provided, default to 'Variable'
if ~exist('labels','var')
    labels(1,1:col) = {'Variable'};
end

% If labels are entered as a column vector, transpose to row
if size(labels,1) > 1
    labels = labels';
end

% Default: do not take absolute values before averaging
if ~exist('absolute','var')
    absolute = 0;
end

%% 2. COMPUTE PAIRWISE CORRELATION
% -----------------------------------------------------------------------
% For each pair (ii,jj), use only rows where neither series is NaN
% (via CommonSample). If a series is constant, corr() returns NaN;
% the diagonal is forced to 1 and off-diagonal entries are set to NaN.
X = DATA;

% Check for non-positive values that would make log-differencing ill-defined
if sum(sum(X<=0)) > 0
    warning('PairCorrUnbalanced: some data points are <=0. First differences will not be computed.')
    x = nan(row, col);
else
    % Log-difference (first difference of logs) for growth-rate correlations
    x = log(X(2:end,:)) - log(X(1:end-1,:));
end

% Preallocate correlation matrices
X_corr = nan(col, col);
x_corr = nan(col, col);

% Loop over all variable pairs and compute pairwise correlations
for ii=1:col
    X1 = X(:,ii);
    x1 = x(:,ii);
    for jj=1:col
        X2 = X(:,jj);
        x2 = x(:,jj);

        % Level correlations
        Y = CommonSample([X1 X2]);
        if isempty(Y)
            X_corr(ii,jj) = NaN;
        else
            aux = corr(Y(:,1), Y(:,2));
            % If no variation in data, corr() returns NaN; force diagonal to 1.
            % Off-diagonal constant pairs are left as NaN (correlation is
            % undefined; NaN is excluded from the average via 'omitnan').
            if isnan(aux)
                if ii==jj
                    X_corr(ii,jj) = 1;
                else
                    X_corr(ii,jj) = NaN;
                end
            else
                X_corr(ii,jj) = aux;
            end
        end

        % Log-difference correlations
        y = CommonSample([x1 x2]);
        if isempty(y)
            x_corr(ii,jj) = NaN;
        else
            aux = corr(y(:,1), y(:,2));
            % Same convention as level correlations above: NaN for undefined.
            if isnan(aux)
                if ii==jj
                    x_corr(ii,jj) = 1;
                else
                    x_corr(ii,jj) = NaN;
                end
            else
                x_corr(ii,jj) = aux;
            end
        end

    end
end

% Optionally take absolute values before computing column means
if absolute == 0
    COR1 = X_corr;
    COR2 = x_corr;
else
    COR1 = abs(X_corr);
    COR2 = abs(x_corr);
end

% Count non-NaN entries per column separately for levels and log-diff,
% since the two correlation matrices can have different NaN patterns in
% unbalanced panels (a pair may be estimable in levels but not log-diffs).
nans_lev = isnan(X_corr);
n_lev    = sum(~nans_lev);
n_lev(n_lev==0) = NaN;
nans_dif = isnan(x_corr);
n_dif    = sum(~nans_dif);
n_dif(n_dif==0) = NaN;

% Average off-diagonal correlations: subtract 1 (diagonal) and divide by n-1
X_PairCorr = (sum(COR1, 'omitnan') - 1) ./ (n_lev-1);
x_PairCorr = (sum(COR2, 'omitnan') - 1) ./ (n_dif-1);

% Stack levels and log-diff pairwise correlations into output matrix
PC = [X_PairCorr ; x_PairCorr]';

% Build labelled output table
title  = {'' , 'Level', 'First Diff.'};
TABLE  = [labels ; num2cell(PC')];
TABLE  = [title ; TABLE'];
