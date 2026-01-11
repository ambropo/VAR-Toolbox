function OUT = MovStd(DATA,window)
% =======================================================================
% Moving stand. deviation of the vector (or matrix) DATA (T obs x N 
% variables). If DATA is a matrix moving average is computed down each 
% column.
% =======================================================================
% OUT = MovAvg(DATA,window)
% -----------------------------------------------------------------------
% INPUT
%    - DATA : T observations x N variables
%    - window: window of the moving average
% -----------------------------------------------------------------------
% OUPUT
%    - OUT: T observations x N variables matrix (the first window-1 
%       observations are NaN)
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = rand(50,4);
%   OUT = MovStd(DATA,2)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


if nargin<2,                error('Not enough input.'),          end
if window<=0,               error('window must be positive.'),   end
if (window~=floor(window)), error('window must be an integer.'), end

if min(size(DATA))==1
    DATA = DATA(:); % forces DATA to be a column vector
end

[nobs,nvar] = size(DATA);
if window>nobs
    error('window must not be greater than the length of DATA.')
end

temp = [];
for row=1:(nobs-window+1)
    temp = [temp; std(DATA(row:(row+window-1),:))];
end

OUT = temp;
OUT = [nan(window-1,nvar); OUT]; % add nans to make conformable to original 