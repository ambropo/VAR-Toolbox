function OLS = OLSmodel(y,x,const,nlag_nw)
% =======================================================================
% OLS regression with homoskedastic, Huber-White, and Newey-West SEs
% =======================================================================
% OLS = OLSmodel(y,x,const,nlag_nw)
% -----------------------------------------------------------------------
% INPUT
%	- y: dependent variable vector    (nobs x 1)
%	- x: independent variables matrix (nobs x nvar)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%	- const: 0 no constant; 1 constant; 2 constant and trend [dflt = 1]
%   - nlag_nw: Newey-West bandwidth (number of lags). When omitted, the
%        automatic bandwidth floor(4*(nobs/100)^(2/9)) is used. Pass 0
%        to obtain the HC0 (Huber-White) sandwich estimator. [dflt = auto]
% -----------------------------------------------------------------------
% OUTPUT
%	- OLS: structure including OLS estimation results
% -----------------------------------------------------------------------
% EXAMPLE
%   x = randn(100,2); y = x*[1;2] + randn(100,1);
%   OLS = OLSmodel(y, x, 1, 4);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate input dimensions and set the default constant option.
if isempty(x)
    [nobs, ~] = size(y);
    nvar = 0;
else
    [nobs, nvar] = size(x);
    [nobs2, ~] = size(y);
    if (nobs ~= nobs2); error('x and y must have same # obs'); end
end

% Check if there are constant, trend, both, or none
if ~exist('const','var')
    const = 1;
end

% Add constant or trend if needed
% Validate from both sides: the chain below has no final else, so a negative
% or non-integer const previously fell through silently and the regression
% ran with no deterministics at all (while OLS.const recorded the invalid
% value). VARmodel and LPmodel apply the same check.
if ~isscalar(const) || ~ismember(const, [0 1 2])
    error('OLSmodel: const must be 0, 1, or 2 (got %s)', mat2str(const));
end
if const==1
    x = [ones(nobs,1) x];
    nvar = nvar+1;
elseif const==2
    trend = 1:nobs;
    x = [ones(nobs,1) trend' x];
    nvar = nvar+2;
end

OLS.meth = 'ols';
OLS.y = y;
OLS.x = x;
OLS.nobs = nobs;
OLS.nvar = nvar;

%% 2. OLS ESTIMATION
% -----------------------------------------------------------------------
% Compute (X'X)^{-1} via QR for numerical stability
[~, r] = qr(x,0);
xpxi = (r'*r)\eye(nvar);  % (X'X)^{-1}

% Coefficient estimates
OLS.beta = xpxi*(x'*y);

% Predicted values and residuals
OLS.yhat  = x*OLS.beta;
OLS.resid = y - OLS.yhat;

% Variance of the residuals (dof-adjusted)
sigu = OLS.resid'*OLS.resid;
OLS.sige    = sigu/(nobs-nvar);
OLS.sigbeta = OLS.sige*xpxi;  % covariance matrix of beta

%% 3. STANDARD ERRORS
% -----------------------------------------------------------------------
% OLS standard errors, t-stats, confidence intervals
tmp = (OLS.sige)*(diag(xpxi));
sigb = sqrt(tmp);
OLS.bstd  = sigb;
tcrit = -tdis_inv(.025,nobs-nvar);
OLS.bint  = [OLS.beta-tcrit.*sigb, OLS.beta+tcrit.*sigb];
OLS.tstat = OLS.beta./(sqrt(tmp));
% Guard against NaN/Inf tstat (e.g. when sige=0 or nobs=nvar): betainc
% inside tdis_prb rejects non-finite x2 as "not in [0,1]" on R2020a+.
if all(isfinite(OLS.tstat))
    OLS.tprob = tdis_prb(OLS.tstat, nobs-nvar);
else
    OLS.tprob = nan(size(OLS.tstat));
end

% Huber-White heteroskedasticity-robust standard errors (nlag = 0: no
% serial-correlation correction, heteroskedasticity only)
nlag = 0;
emat = repmat(OLS.resid', nvar, 1); % preallocate: stack nvar copies of e'
hhat = emat.*x';
G = zeros(nvar,nvar); w = zeros(2*nlag+1,1);
a = 0;
while a ~= nlag+1
    ga = zeros(nvar,nvar);
    w(nlag+1+a,1) = (nlag+1-a)/(nlag+1);
    za = hhat(:,(a+1):nobs)*hhat(:,1:nobs-a)';
    if a==0
        ga = ga + za;
    else
        ga = ga + za + za';
    end
    G = G + w(nlag+1+a,1)*ga;
    a = a+1;
end
V = xpxi*G*xpxi;
OLS.bstd_HW = sqrt(diag(V));

% Newey-West heteroskedasticity- and autocorrelation-consistent std errors
% Use caller-supplied bandwidth when provided; otherwise fall back to the
% automatic Newey-West bandwidth floor(4*(nobs/100)^(2/9))
if ~exist('nlag_nw','var')
    nlag = floor(4*((nobs/100)^(2/9))); % automatic bandwidth
else
    nlag = nlag_nw;                      % caller-specified bandwidth
end
emat = repmat(OLS.resid', nvar, 1); % preallocate: stack nvar copies of e'
hhat = emat.*x';
G = zeros(nvar,nvar); w = zeros(2*nlag+1,1);
a = 0;
while a ~= nlag+1
    ga = zeros(nvar,nvar);
    w(nlag+1+a,1) = (nlag+1-a)/(nlag+1);
    za = hhat(:,(a+1):nobs)*hhat(:,1:nobs-a)';
    if a==0
        ga = ga + za;
    else
        ga = ga + za + za';
    end
    G = G + w(nlag+1+a,1)*ga;
    a = a+1;
end
V = xpxi*G*xpxi;
OLS.bstd_NW = sqrt(diag(V));

%% 4. GOODNESS OF FIT
% -----------------------------------------------------------------------
% R-squared and adjusted R-squared
ym = y - mean(y);
rsqr1 = sigu;
rsqr2 = ym'*ym;
OLS.rsqr = 1.0 - rsqr1/rsqr2; % r-squared
rsqr1 = rsqr1/(nobs-nvar);
rsqr2 = rsqr2/(nobs-1.0);
if rsqr2 ~= 0
    OLS.rbar = 1 - (rsqr1/rsqr2); % rbar-squared
else
    OLS.rbar = OLS.rsqr;
end

% Durbin-Watson
ediff = OLS.resid(2:nobs) - OLS.resid(1:nobs-1);
OLS.dw = (ediff'*ediff)/sigu; % durbin-watson
OLS.const = const;

% F-test of joint significance against the constant-only model
if const>0
    fx = x(:,1);
    fxpxi = (fx'*fx)\eye(1);
    fbeta = fxpxi*(fx'*y);
    fyhat = fx*fbeta;
    fresid = y - fyhat;
    fsigu = fresid'*fresid;
    fym = y - mean(y);
    frsqr1 = fsigu;
    frsqr2 = fym'*fym;
    frsqr = 1.0 - frsqr1/frsqr2; % r-squared
    OLS.F = ((frsqr-OLS.rsqr)/(1-nvar)) / ((1-OLS.rsqr)/(nobs-nvar));
end
