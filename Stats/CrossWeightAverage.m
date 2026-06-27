function [OUT, W] = CrossWeightAverage(DATA,WEIGHT)
% =======================================================================
% Compute the weighted cross-sectional average of a panel of time series,
% rescaling weights row-by-row whenever NaNs are present in the data.
% =======================================================================
% [OUT, W] = CrossWeightAverage(DATA,WEIGHT)
% -----------------------------------------------------------------------
% INPUT
%   - DATA  : panel of time series (TxN); NaNs are accepted and weights
%             are rescaled to sum to 1 over available series [double]
%   - WEIGHT: weight matrix (TxN), or a single row (1xN) for fixed
%             weights that are replicated across all T periods [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: weighted average vector (T x 1) [double]
%   - W  : matrix of (rescaled) weights (T x N) [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 NaN 3; 2 3 4; 3 4 5; 4 5 6];
%   w = [0 .4 .6];
%   [OUT, W] = CrossWeightAverage(x, w);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate that both required arguments are supplied and that DATA and
% WEIGHT are conformable. A single-row WEIGHT is broadcast to (TxN).
if nargin < 2
    error('CrossWeightAverage: DATA and WEIGHT are required inputs.')
end
[r1, c1] = size(DATA);
[r2, c2] = size(WEIGHT);

% If a single row of weights is supplied, replicate it into a (TxN) matrix
if r2==1 && c2==c1
    WEIGHT = repmat(WEIGHT, r1, 1);
end

% Confirm DATA and WEIGHT are now conformable
[r2, c2] = size(WEIGHT);
if r1~=r2 || c1~=c2
    error('CrossWeightAverage: DATA and WEIGHT matrices are not conformable.')
end

%% 2. COMPUTE CROSS-SECTIONAL WEIGHTED AVERAGE
% -----------------------------------------------------------------------
% NaNs in DATA are excluded row-by-row; the remaining weights are
% renormalised to sum to 1 so the average is still well-defined.
[nobs, nvars] = size(DATA);
nans = isnan(DATA);
WEIGHT(nans) = NaN;

% Preallocate output and weight matrices
OUT = nan(nobs, 1);
W   = nan(nobs, nvars);

% Loop over rows, renormalise weights and compute weighted average
for ii=1:nobs
    % Normalise weights to sum to 1, ignoring NaN entries.
    % Edge case: if all non-NaN weights for this row sum to zero, the
    % normalised weights are NaN and OUT(ii) will be NaN even when data
    % is present. This is left as-is; callers should ensure non-zero weights.
    row_w = WEIGHT(ii,:);
    aux_weight = row_w ./ sum(row_w, 'omitnan');
    W(ii,:) = aux_weight;
    % Zero out both the weight and the data entry for missing observations
    % before computing the dot product. Zeroing DATA is the load-bearing step:
    % it prevents any residual NaN from entering the sum even if the weight is
    % already zero, since 0*NaN = NaN in IEEE arithmetic.
    aux_weight(nans(ii,:)) = 0;
    DATA(ii, nans(ii,:)) = 0;
    if sum(nans(ii,:)) == nvars
        OUT(ii,1) = NaN;   % all series missing for this period
    else
        OUT(ii,1) = DATA(ii,:) * aux_weight';
    end
end
