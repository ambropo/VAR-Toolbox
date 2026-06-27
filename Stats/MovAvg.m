function OUT = MovAvg(DATA,window)
% =======================================================================
% Compute the trailing moving average of each column of DATA over a
% fixed-width backward-looking window.
% =======================================================================
% OUT = MovAvg(DATA,window)
% -----------------------------------------------------------------------
% INPUT
%   - DATA  : T observations x N variables [double]
%   - window: number of periods in the trailing window [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: T x N matrix of moving averages; first window-1 rows are NaN
%          [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(50,3);
%   OUT = MovAvg(X,4);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate window parameter and enforce minimum data length. A scalar
% input is converted to a column vector so the loop works uniformly.
if nargin<2,                error('Not enough input.'),          end
if window<=0,               error('Window must be positive.'),   end
if (window~=floor(window)), error('Window must be an integer.'), end

% Force column vector so the loop handles both vectors and matrices uniformly
if min(size(DATA))==1
    DATA = DATA(:);  % force column vector so the loop works uniformly
end

% Get dimensions and validate window size
[nobs, nvar] = size(DATA);
if window>nobs
    error('window must not be greater than the length of DATA.')
end

%% 2. COMPUTE ROLLING MEAN
% -----------------------------------------------------------------------
% The window is trailing (backward-looking): OUT(t) is the mean of
% DATA(t-window+1:t,:), so the first valid output is at t = window.
% When DATA is a matrix, mean averages the window rows for each column
% independently. NaN in any window position propagates to NaN output;
% use MovAvgCent for 'omitnan' behaviour.
temp = nan(nobs-window+1, nvar);
for row = 1:(nobs-window+1)
    temp(row, :) = mean(DATA(row:(row+window-1), :));
end

% Prepend window-1 NaN rows so output is length-T, aligned with input
OUT = [nan(window-1, nvar); temp];
