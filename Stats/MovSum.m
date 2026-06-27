function OUT = MovSum(DATA,window)
% =======================================================================
% Moving sum of the vector (or matrix) DATA (T obs x N variables). If
% DATA is a matrix, moving sum is computed down each column.
% =======================================================================
% OUT = MovSum(DATA,window)
% -----------------------------------------------------------------------
% INPUT
%   - DATA  : T observations x N variables [double]
%   - window: window of the moving sum [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: T observations x N variables matrix (the first window-1
%       observations are NaN) [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = rand(50,4);
%   OUT = MovSum(DATA,2)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
if nargin<2,                error('Not enough input.'),          end
if window<=0,               error('window must be positive.'),   end
if (window~=floor(window)), error('window must be an integer.'), end

% Force column vector so the loop handles both vectors and matrices uniformly
if min(size(DATA))==1
    DATA = DATA(:);  % force column vector so the loop works uniformly
end

% Get dimensions and validate window size
[nobs, nvar] = size(DATA);
if window>nobs
    error('window must not be greater than the length of DATA.')
end

%% 2. COMPUTE ROLLING SUM
% -----------------------------------------------------------------------
% The window is trailing (backward-looking): OUT(t) is sum of DATA(t-window+1:t,:).
% NaN in any window position propagates to NaN output (no 'omitnan');
% this differs from MovAvgCent which uses 'omitnan'.
% Prepend window-1 NaN rows so OUT aligns with the original series.
temp = nan(nobs-window+1, nvar);
for row = 1:(nobs-window+1)
    temp(row, :) = sum(DATA(row:(row+window-1), :));
end

OUT = [nan(window-1, nvar); temp];
