function [PC, TABLE] = PairCorr(DATA,labels,absolute)
% =======================================================================
% Compute pairwise correlation of a panel of time series DATA with T 
% observations and N variables. Computes the pairwise correlation of both 
% levels and log-differences of the original series in DATA.
% 
% Note: If a series (ie, column) has a NaN, the whole series is treated as 
% NaN. See PairCorrUnbalanced for pairwise correlations with NaNs
% =======================================================================
% [PC, TABLE] = PairCorr(DATA,labels)
% -----------------------------------------------------------------------
% INPUT
%	- DATA: matrix DATA T (observations) x N (variables)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - labels: names of each variable j. Default "Variable"
%   - absolute: Default 0. If set to 1 computes the average of the absolute
%       value of the pairwise correlation
% -----------------------------------------------------------------------
% TABLEPUT
%	- PC: matrix of pairwise correlation N (variables) x 2 (levels 
%       and log-diff)
%	- TABLE: formatted table of pairwise correlation with titles
% =========================================================================
% Example
% DATA = rand(50,4);
% [PC TABLE] = PairCorr(DATA)
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015





%% Preliminaries: define the dimension of the matrix of interest
% =========================================================================
[~, col] = size(DATA);

% If no names are provided set it to 'Variable'
if ~exist('labels','var')
    labels(1,1:col) = {'Variable'};
end

% If labels are entered as jx1 vector, transpose it
if size(labels,1) > 1
    labels = labels';
end

% If no option is entered, no absolute value
if ~exist('absolute','var')
    absolute = 0;
end

%% Compute pairwise correlation
% =========================================================================
% Define the matrix for the levels 
X = DATA;
% If there are columns with NaNs make the whole column NaN
X(:,isnan(X(1,:))==1) = NaN;

% Compute the first differences
x = log(X(2:end,:)) - log(X(1:end-1,:));

% Compute the correlation matrix
X_corr = corrcoef(X);
x_corr = corrcoef(x);

% Store the unbalanced correlation matrices and compute absolute if needed
if absolute==0
    COR1 = X_corr;
    COR2 = x_corr;
else
    COR1 = abs(X_corr);
    COR2 = abs(x_corr);
end  

% Find the NaNs in the correlation matrix
nans = isnan(X_corr);

% Define the number of non-NaN elements in the correlation matrix
n = sum(~nans);
n(n==0) = NaN;

% % Set the NaNs of the correlation matrix to zero
% X_corr(nans) = 0;
% x_corr(nans) = 0;

% Compute the pairwise correlation
X_PairCorr = (nansum(COR1) - 1) ./ (n-1);
x_PairCorr = (nansum(COR2) - 1) ./ (n-1);

PC = [X_PairCorr ; x_PairCorr]';

% Table with titles
title = {'' , 'Level', 'First Diff.'};
TABLE = [labels  ; num2cell(X_PairCorr) ; num2cell(x_PairCorr)];
TABLE = [title ; TABLE'];