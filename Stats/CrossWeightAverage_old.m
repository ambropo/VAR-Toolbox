function [average, weight] = CrossWeightAverage(DATA,WEIGHT)
% =========================================================================
% Compute the weighted average of DATA, computing the weights form the
% matrix WEIGHT. Note that if there are NaNs in DATA the weights are 
% rescaled. WEIGHTS CANNOT contain NaN
% =========================================================================
% [average, weight] = CrossWeightAverage(DATA,WEIGHT)
% -------------------------------------------------------------------------
% INPUT 
%	- DATA: panel of time series DATA(T,N) of T observation x N series 
%       (NaN are accepted and weights rescaled)
%   - WEIGHT: time series of FLOWS or WEIGHTS (TxN). You can also
%       provide a (1xN) matrix in this case the code would automatically 
%       compute fixed weights
% -------------------------------------------------------------------------
% OUTPUT 
%	- average : weighted average vector (T x 1)
%	- weight  : matrix of weights (T x N)
% =========================================================================
% Example 1: foreign variables as in GVAR (example with fixed weights)
% x = [1 NaN  3 ; 
%      2   3  4 ; 
%      3   4  5 ; 
%      4   5  6];
% w = [0  .4 .6];
% [average, weight] = CrossWeightAverage(x,w)
% -------------------------------------------------------------------------
% Example 2: weighted average (with time-varying weights)
% x = [ 1 NaN   3 ;
%       2   3   4 ;
%       3   4   5 ;  
%       4   5   6];
% w = [.4  .2  .4 ; 
%      .3  .4  .3 ;
%      .4  .3  .3 ;
%      .5  .3  .2];
% [average, weight] = CrossWeightAverage(x,w)
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015



%% Preliminaries
% Check inputs
[r1, c1] = size(DATA);
[r2, c2] = size(WEIGHT);
if r2==1 && c2==c1 
    % Create a matrix of fixed weights
    aux = [];
    for ii=1:r1
        aux = [aux; WEIGHT];
    end
    WEIGHT = aux;
end


% Re-Check inputs
[r1, c1] = size(DATA);
[r2, c2] = size(WEIGHT);
if r1~=r2 || c1~=c2
    disp(' ')
    disp('The matrices of data and weights are not conformable.')
    return
end

%% Cross section weihgted average
[nobs, nvars] = size(DATA);
nans = isnan(DATA);
WEIGHT(nans) = NaN;

average(1:nobs,1) = NaN;
weight(1:nobs,1:nvars) = NaN;

for ii=1:nobs
    aux_weight = WEIGHT(ii,:)./nansum(WEIGHT(ii,:));
    weight(ii,:) = aux_weight;
    aux_weight(nans(ii,:)) = 0;
    DATA(ii,nans(ii,:)) = 0;
    average(ii,1) = DATA(ii,:) * aux_weight';
end
