function OUT = MovAvgCent(DATA,window)
% =======================================================================
% Moving average of the matrix DATA (TxN). The moving average is 
% compute over the interval [t-window,t+window] and it is computed down 
% each column.
% =======================================================================
% OUT = MovAvg(DATA,window)
% -----------------------------------------------------------------------
% INPUT
%   DATA: T observations DATA window variables
%   window: window of the moving average
%------------------------------------------------------------------------
% OUPUT
%   OUT: T observations DATA window variables matrix (the first windows-1 
%       obseravations are NaN)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

    
if nargin<2, error('Not enough input.'),end
if window<=0,error('window must be positive.'),end
if (window~=floor(window)),error('window must be an integer.'),end

if min(size(DATA))==1,
    DATA=DATA(:); % forces DATA to be a column vector
end

[nobs,nvars] = size(DATA);
if window>nobs,
    error('window must not be greater than the length of DATA.')
end

temp = nan(nobs,nvars);
for jj = (window+1):(nobs-window),
    temp(jj,:) = nanmean(DATA(jj-window:jj+window,:));
end

OUT = temp;