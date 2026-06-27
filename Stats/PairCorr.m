function [PC, TABLE] = PairCorr(DATA,labels,absolute)
% =======================================================================
% Compute pairwise correlation of a panel of time series DATA with T
% observations and N variables. Computes the pairwise correlation of both
% levels and log-differences of the original series in DATA.
%
% Note: If a series (ie, column) has a NaN, the whole series is treated
% as NaN. See PairCorrUnbalanced for pairwise correlations with NaNs.
% =======================================================================
% [PC, TABLE] = PairCorr(DATA,labels,absolute)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: matrix T (observations) x N (variables) [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - labels  : names of each variable j [dflt = 'Variable']
%   - absolute: 1 to use absolute values of correlations before averaging
%               [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - PC   : matrix N (variables) x 2 (levels and log-diff) of mean
%            pairwise correlations [double]
%   - TABLE: formatted cell table of pairwise correlations with titles
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = rand(50,4);
%   [PC, TABLE] = PairCorr(DATA)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PRELIMINARIES
% -----------------------------------------------------------------------
if nargin < 1
    error('PairCorr: DATA is a required input.')
end
[~, col] = size(DATA);

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
% Any column containing a NaN anywhere is set to NaN entirely, consistent
% with corrcoef's 'complete' (listwise) default.
X = DATA;
X(:, any(isnan(X))) = NaN;

% Check for non-positive values that would make log-differencing ill-defined
if sum(sum(X<=0)) > 0
    warning('PairCorr: some data points are <=0. First differences will not be computed.')
    x = nan(size(X,1)-1, size(X,2));
else
    % Log-difference (first difference of logs) for growth-rate correlations
    x = log(X(2:end,:)) - log(X(1:end-1,:));
end

% Full correlation matrices for levels and log-differences
X_corr = corrcoef(X);
x_corr = corrcoef(x);

% Optionally take absolute values before computing column means
if absolute == 0
    COR1 = X_corr;
    COR2 = x_corr;
else
    COR1 = abs(X_corr);
    COR2 = abs(x_corr);
end

% Count non-NaN entries per column; avoid division by zero.
% In the balanced case, listwise deletion ensures that any column with a
% NaN is set to all-NaN before computing either X_corr or x_corr, so both
% correlation matrices share the same NaN pattern. Using n from X_corr is
% therefore valid as the denominator for x_PairCorr as well.
nans = isnan(X_corr);
n    = sum(~nans);
n(n==0) = NaN;

% Average off-diagonal correlations: subtract 1 (diagonal) and divide by n-1
X_PairCorr = (sum(COR1, 'omitnan') - 1) ./ (n-1);
x_PairCorr = (sum(COR2, 'omitnan') - 1) ./ (n-1);

% Stack levels and log-diff pairwise correlations into output matrix
PC = [X_PairCorr ; x_PairCorr]';

% Build labelled output table
title  = {'' , 'Level', 'First Diff.'};
TABLE  = [labels ; num2cell(X_PairCorr) ; num2cell(x_PairCorr)];
TABLE  = [title ; TABLE'];
