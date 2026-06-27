function OUT = MovAvgCent(DATA,window)
% =======================================================================
% Compute the centered moving average of each column of DATA over a
% symmetric window [t-window, t+window] of total width 2*window+1.
% =======================================================================
% OUT = MovAvgCent(DATA,window)
% -----------------------------------------------------------------------
% INPUT
%   - DATA  : T observations x N variables [double]
%   - window: half-width of the centered window; full width = 2*window+1
%             [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: T x N matrix of centered moving averages; first and last
%          window rows are NaN [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(50,3);
%   OUT = MovAvgCent(X,4);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate window parameter, enforce minimum series length, and convert
% scalar input to a column vector so the loop works uniformly.
if nargin<2,                error('Not enough input.'),          end
if window<=0,               error('window must be positive.'),   end
if (window~=floor(window)), error('window must be an integer.'), end

% Force column vector so the loop handles both vectors and matrices uniformly
if min(size(DATA))==1
    DATA = DATA(:);  % force column vector so the loop works uniformly
end

% Get dimensions and validate window size
[nobs, nvars] = size(DATA);
if window > nobs
    error('window must not be greater than the length of DATA.')
end
if nobs < 2*window+1
    error('MovAvgCent: series too short — need at least 2*window+1 observations.')
end

%% 2. COMPUTE CENTERED ROLLING MEAN
% -----------------------------------------------------------------------
% Each observation jj uses the symmetric window [jj-window, jj+window].
% The first and last 'window' observations remain NaN (boundary effect).
% Unlike MovAvg and MovStd, internal NaNs in the window are ignored via
% 'omitnan'; a window with some missing values still yields a valid mean.
OUT = nan(nobs, nvars);
for jj = (window+1):(nobs-window)
    OUT(jj, :) = mean(DATA(jj-window:jj+window, :), 'omitnan');
end
