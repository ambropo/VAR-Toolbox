function OUT = MovAvg(DATA,window)
% =======================================================================
% Moving average of the matrix DATA (TxN). The moving average is 
% computed down each column.
% =======================================================================
% OUT = MovAvg(DATA,window)
% -----------------------------------------------------------------------
% INPUT
%   DATA: T observations x N variables [double]
%   window: window of the moving average [double]
% -----------------------------------------------------------------------
% OUPUT
%   OUT: T x N matrix (the first windows-1 observations are NaN) [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = rand(20,2);
%   OUT = MovAvg(X,2)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


if nargin<2,                error('Not enough input.'),          end
if window<=0,               error('Window must be positive.'),   end
if (window~=floor(window)), error('Window must be an integer.'), end

if min(size(DATA))==1
    DATA = DATA(:); % forces DATA to be a column vector
end

[nobs,nvar] = size(DATA);
if window>nobs
    error('window must not be greater than the length of DATA.')
end

temp=[];
for row=1:(nobs-window+1),
    temp = [temp; mean(DATA(row:(row+window-1),:))];
end

OUT = temp;
OUT = [nan(window-1,nvar); OUT]; % add nans to make conformable to original 
