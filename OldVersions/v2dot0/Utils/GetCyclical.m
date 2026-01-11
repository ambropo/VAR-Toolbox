function OUT = GetCyclical(DATA,vtreat,lag,lam)
% =======================================================================
% Compute cyclical components of a time series with the specified method
% =======================================================================
% OUT = GetCyclical(DATA,vtreat,lag)
% -----------------------------------------------------------------------
% INPUT
%	- DATA: matrix DATA(T,N)
%   - vtreat: 1	First difference
%             2	Log First Difference
%             3	Deviation from constant & trend
%             4	Log Deviation from constant & trend
%             5	Deviation from constant & quadratic trend
%             6	Log Deviation from constant & quadratic trend
%             7	HP filter
%             8	Log HP filter
%             9	Percent change
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - lag: number of lags for first differences or percent changes
%   - lam: smoothing parameter for HP filter
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: matrix DATA(T,N) of cyclical components. The first # (=lag) 
%     observations are NaN
% =========================================================================
% Ambrogio Cesa Bianchi, May 2015
% ambrogiocesabianchi@gmail.com
%-------------------------------------------------------------------------

if vtreat==1 || vtreat==2 || vtreat==9
    if ~exist('lag','var')
        error('You need to provide the lag')
    end
end
if vtreat==7 || vtreat==8
    if ~exist('lam','var')
        error('You need to provide smoothing parameter')
    end
end

[nobs, nvar] = size(DATA);

OUT = nan(nobs,nvar);

% No treatment
if vtreat==0
    OUT = DATA;

% Log
elseif vtreat==1
    if ~isempty(find(DATA<0)), error('Trying to take logs of negative number'), end
    OUT = log(DATA);
    
% First difference
elseif vtreat==2
    OUT(lag+1:end,:) = DATA(1+lag:end,:) - DATA(1:end-lag,:);
    
% Log First Difference
elseif vtreat==3
    if ~isempty(find(DATA<0)), error('Trying to take logs of negative number'), end
    OUT(lag+1:end,:) = log(DATA(1+lag:end,:))-log(DATA(1:end-lag,:));

% Deviation from constant&trend
elseif vtreat==4
    for ii=1:nvar
        [aux, fo, lo] = CommonSample(DATA(:,ii));
        if ~isempty(aux)
            trend = (1+fo:nobs-lo)';
            out = OLSmodel(aux,trend,1);
            OUT(1+fo:end-lo,ii) = out.resid;
        end
    end
    
% Log Deviation from constant&trend
elseif vtreat==5
    if ~isempty(find(DATA<0)), error('Trying to take logs of negative number'), end
    for ii=1:nvar
        [aux, fo, lo] = CommonSample(log(DATA(:,ii)));
        if ~isempty(aux)
            trend = (1+fo:nobs-lo)';
            out = OLSmodel(aux,trend,1);
            OUT(1+fo:end-lo,ii) = out.resid;
        end
    end 
    
% Deviation from constant & quadratic trend
elseif vtreat==6
    for ii=1:nvar
        [aux, fo, lo] = CommonSample(DATA(:,ii));
        if ~isempty(aux)
            trend = (1+fo:nobs-lo)';
            trend2 = trend.^2;
            out = OLSmodel(aux,trend2,1);
            OUT(1+fo:end-lo,ii) = out.resid;
        end 
    end
    
% Log Deviation from constant & quadratic trend
elseif vtreat==7
    if ~isempty(find(DATA<0)), error('Trying to take logs of negative number'), end
    for ii=1:nvar
        [aux, fo, lo] = CommonSample(log(DATA(:,ii)));
        if ~isempty(aux)
            trend = (1+fo:nobs-lo)';
            trend2 = trend.^2;
            out = OLSmodel(aux,trend2,1);
            OUT(1+fo:end-lo,ii) = out.resid;
        end
    end
    
% HP filter
elseif vtreat==8
    for ii=1:nvar
        [aux, fo, lo] = CommonSample(DATA(:,ii));
        if ~isempty(aux)
            [~, cyc] = hpfilter(aux,lam);
            OUT(1+fo:end-lo,ii) = cyc;
        end
    end 
    
% Log HP filter
elseif vtreat==9
    if ~isempty(find(DATA<0)), error('Trying to take logs of negative number'), end
    for ii=1:nvar
        [aux, fo, lo] = CommonSample(log(DATA(:,ii)));
        if ~isempty(aux)
            [~, cyc] = hpfilter(aux,lam); 
            OUT(1+fo:end-lo,ii) = cyc;
        end
    end 
    
% Percent change
elseif vtreat==10
    OUT(lag+1:end,:) = DATA(1+lag:end,:)./DATA(1:end-lag,:)-1;
end
