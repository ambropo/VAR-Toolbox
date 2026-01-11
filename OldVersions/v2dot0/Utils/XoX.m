function OUT = XoX(DATA,frequency,type)
% =======================================================================
% Compute the rate of change of a panel of time series (DATA, T obs x N 
% countries) at quarterly or annual frequency
% =======================================================================
% OUT = XoX(DATA,frequency,type)
% -----------------------------------------------------------------------
% INPUT
%	- DATA: matrix DATA(T,N)
%   - frequency: 1 for X(t)-X(t-1); 4 for X(t)-X(t-4); etc...
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - type: 'logdiff', computes log(X(t))-log(X(t-1)) [DEFAULT]
%           'diff'   , computes X(t)-X(t-1)
%           'rate'   , computes X(t)/X(t-1)-1
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: matrix DATA(T,N) of rates of change. The first # (=frequency) 
%     observations are NaN
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogiocesabianchi@gmail.com
%-------------------------------------------------------------------------

if ~exist('type','var')
    type = 'logdiff';
end

[nobs, nvar] = size(DATA);

if frequency>nobs
    error('Frequency is larger than the number of observations')
end


if strcmp(type,'logdiff')
    OUT = log(DATA(1+frequency:end,:))-log(DATA(1:end-frequency,:));
    OUT = [nan(frequency,nvar); OUT];
elseif strcmp(type,'rate')
    OUT = DATA(1+frequency:end,:)./DATA(1:end-frequency,:)-1;
    OUT = [nan(frequency,nvar); OUT];
elseif strcmp(type,'diff')
    OUT = DATA(1+frequency:end,:) - DATA(1:end-frequency,:);
    OUT = [nan(frequency,nvar); OUT];
end
