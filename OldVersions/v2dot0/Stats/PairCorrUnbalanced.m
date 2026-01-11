function [PC, TABLE] = PairCorrUnbalanced(DATA,labels,absolute)
% =======================================================================
% Compute pairwise correlation of a panel of time series DATA with T 
% observations and N variables. Computes the pairwise correlation of both 
% levels and log-differences of the original series in DATA.
% 
% Note: for each pair of columns, the correlation is computed using the
% maximum amount of available observations. This is to deal with unbalanced
% panels. Therefore, NaN are accepted.
% =======================================================================
% [PC, TABLE] = PairCorrUnbalanced(DATA,labels)
% -----------------------------------------------------------------------
% INPUT
%	- DATA    : matrix DATA T (observations) x N (variables)
%------------------------------------------------------------------------
% OPTIONAL INPUT
%   - labels: Default "Variable", names of each variable j
%   - absolute: Default 0. If set to 1 computes the average of the absolute
%       value of the pairwise correlation
%------------------------------------------------------------------------
% OUPUT
%	- PC: matrix of pairwise correlation N (variables) x 2 (levels 
%       and log-diff)
%	- TABLE: formatted table of pairwise correlation with titles
% =======================================================================
% EXAMPLE
% DATA = rand(50,4);
% [PC, TABLE] = PairCorrUnbalanced(DATA)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com



%% Preliminaries: define the dimension of the matrix of interest
% =========================================================================
[row , col] = size(DATA);

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

if sum(sum(X<=0))>0
    warning('Some data points are <=0. First differences will not be computed')
    x = nan(row,col);
else
    % Compute the first differences
    x = log(X(2:end,:)) - log(X(1:end-1,:));
end

% Compute the correlation matrix using the maximum amount of avaliable obs
for ii=1:col
    X1 = X(:,ii);
    x1 = x(:,ii);
    for jj=1:col
        X2 = X(:,jj);
        x2 = x(:,jj);
        Y = CommonSample([X1 X2]);
        y = CommonSample([x1 x2]);
        if isempty(Y) == 1
            X_corr(ii,jj) = NaN;
        else
            aux = corr(Y(:,1),Y(:,2));
            % This is to take into account that if there is no variation in
            % the data, corr(x,y) yields NaN. If that happens the pairwise
            % correlation is set to zero. (February 2013)
            if isnan(aux)==1
                if ii==jj
                    X_corr(ii,jj) = 1; % Even if there is no variation the corr of each column with itself is seto to 1
                else
                    X_corr(ii,jj) = 0;
                end
            else
                X_corr(ii,jj) = corr(Y(:,1),Y(:,2));
            end
        end
        if isempty(y) == 1
            x_corr(ii,jj) = NaN;
        else
            aux = corr(y(:,1),y(:,2));
            % This is to take into account that if there is no variation in
            % the data, corr(x,y) yields NaN. If that happens the pairwise
            % correlation is set to zero. (February 2013)
            if isnan(aux)==1
                if ii==jj 
                    x_corr(ii,jj) = 1; % Even if there is no variation the corr of each column with itself is set to 1
                else
                    x_corr(ii,jj) = 0;
                end
            else
                x_corr(ii,jj) = corr(y(:,1),y(:,2));
            end
        end
    end
end

% Store the unbalanced correlation matrices
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

% Set the NaNs of the correlation matrix to zero
% X_corr(nans) = 0;
% x_corr(nans) = 0;

% Compute the pairwise correlation
X_PairCorr = (nansum(COR1) - 1) ./ (n-1);
x_PairCorr = (nansum(COR2) - 1) ./ (n-1);

PC = [X_PairCorr ; x_PairCorr]';

%Write the table in PairCorr.xls with titles
title = {'' , 'Level', 'First Diff.'};
TABLE = [labels  ; num2cell(PC')];
TABLE = [title ; TABLE'];
