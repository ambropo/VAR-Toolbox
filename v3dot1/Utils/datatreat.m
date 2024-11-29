function OUT = datatreat(DATA,vtreat,nlag)
% =======================================================================
% Treat a time series with the specified method. If changes are computed
% the function assumes 1 lag (unless otherwise specified)
% =======================================================================
% OUT = datatreat(DATA,vtreat,lag)
% -----------------------------------------------------------------------
% INPUT
%	- DATA: matrix DATA(T,N)
%   - vtreat: 0 No treatment 
%             1	Log
%             2 Difference
%             3	Log Difference
%             4 Percent change
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - lag: number of lags for changes
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: matrix DATA(T,N) of treated data. The first "nlag"
%     observations are NaNs
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; -3 4; 5 6; 7 8; 9 10];
%   OUT = datatreat(x,3)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

% Check input
if ~exist('nlag','var')
    nlag = 1;
end

% Set matrices
[nobs, nvar] = size(DATA);
OUT = nan(nobs,nvar);

% No treatment
if vtreat==0
    OUT = DATA;

% Log
elseif vtreat==1
    if ~isempty(DATA<0), warning('Negative numbers set to NaN before taking logs'), end
    DATA(DATA<0) = NaN;
    OUT = log(DATA);
    
% Difference
elseif vtreat==2
    OUT(nlag+1:end,:) = DATA(1+nlag:end,:) - DATA(1:end-nlag,:);
    
% Log difference
elseif vtreat==3
    if ~isempty(DATA<0), warning('Negative numbers set to NaN before taking logs'), end
    DATA(DATA<0) = NaN;
    OUT(nlag+1:end,:) = log(DATA(1+nlag:end,:))-log(DATA(1:end-nlag,:));

% Percent change
elseif vtreat==4
    OUT(nlag+1:end,:) = DATA(1+nlag:end,:)./DATA(1:end-nlag,:)-1;
end
