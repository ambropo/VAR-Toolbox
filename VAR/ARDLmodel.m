function ARDL = ARDLmodel(ENDO,nlag,const,EXOG,nlag_ex)
% =======================================================================
% Estimate an ARDL(p,q) model via OLS, with optional deterministic terms
% =======================================================================
% ARDL = ARDLmodel(ENDO,nlag,const,EXOG,nlag_ex)
% -----------------------------------------------------------------------
% INPUT
%   - ENDO: dependent variable vector (nobs x 1)
%   - nlag: number of lags of the endogenous variable [integer >= 1]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - const: 0 no constant; 1 constant; 2 constant and trend [dflt = 1]
%   - EXOG: exogenous variable matrix (nobs x nvar_ex)
%   - nlag_ex: number of lags for exogenous variable(s) [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - ARDL: structure including ARDL estimation results
% -----------------------------------------------------------------------
% EXAMPLE
%   y = cumsum(randn(120,1));
%   x = randn(120,2);
%   ARDL = ARDLmodel(y, 2, 1, x, 1);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate required inputs and set defaults for optional arguments
if ~exist('ENDO','var') || isempty(ENDO)
    error('ARDLmodel: ENDO is required and cannot be empty');
end
if ~exist('nlag','var') || isempty(nlag)
    error('ARDLmodel: nlag is required');
end
[nobs, ~] = size(ENDO);
ARDL.ENDO = ENDO;

% Default to constant if the deterministic component is not specified
if ~exist('const','var')
    const = 1;
end
if const > 2
    error('ARDLmodel: const must be 0, 1, or 2 (got %d)', const);
end
ARDL.const = const;

% Check if there is an exogenous variable
if exist('EXOG','var') && ~isempty(EXOG)
    [nobs_ex, nvar_ex] = size(EXOG);
    % Confirm ENDO and EXOG span the same sample
    if (nobs_ex ~= nobs)
        error('ARDLmodel: nobs in EXOG does not match nobs in ENDO');
    end
    clear nobs_ex
    % Default exogenous lag order to 0 (contemporaneous only)
    if ~exist('nlag_ex','var')
        nlag_ex = 0;
    end
    ARDL.EXOG = EXOG;
else
    nvar_ex = 0;
    nlag_ex = 0;
    ARDL.EXOG = [];
end

%% 2. BUILD DATA MATRICES
% -----------------------------------------------------------------------
% Effective sample size after removing initial observations for lags
nobse        = nobs - max(nlag,nlag_ex);
ARDL.nobs    = nobse;
ARDL.nlag    = nlag;
ARDL.nlag_ex = nlag_ex;
ncoeff       = nlag;
ARDL.ncoeff  = ncoeff;
ncoeff_ex    = nvar_ex + nvar_ex*nlag_ex;
nvar         = ncoeff + ncoeff_ex + const;
ARDL.nvar    = nvar;
ARDL.nvar_ex = nvar_ex;

% Construct dependent vector Y and regressor matrix X from lagged endo
[Y, X] = VARmakexy(ENDO,nlag,const);

% Append (lagged) exogenous variables to X, aligning rows if lag orders differ
if exist('EXOG','var') && ~isempty(EXOG)
    X_EX  = VARmakelags(EXOG,nlag_ex);
    if nlag == nlag_ex
        X = [X X_EX];
    elseif nlag > nlag_ex
        diff = nlag - nlag_ex;
        X_EX = X_EX(diff+1:end,:);
        X = [X X_EX];
    elseif nlag < nlag_ex
        diff = nlag_ex - nlag;
        Y = Y(diff+1:end,:);
        X = [X(diff+1:end,:) X_EX];
    end
end

% Store method tag and regression matrices for downstream use
ARDL.meth = 'ols';
ARDL.y = Y;
ARDL.x = X;

% Compute (X'X)^{-1} via QR for numerical stability
[~, r] = qr(X,0);
xpxi = (r'*r)\eye(nvar);

% OLS coefficient estimates
beta = xpxi*(X'*Y);
ARDL.beta = beta;

% Predicted values and residuals
ARDL.yhat  = X*ARDL.beta;
ARDL.resid = Y - ARDL.yhat;

% Variance of residuals (dof-adjusted) and covariance of beta
sigu = ARDL.resid'*ARDL.resid;
ARDL.sige    = sigu/(nobse-nvar);
sigbeta      = ARDL.sige*xpxi;
ARDL.sigbeta = sigbeta;

% Standard errors, t-statistics, and confidence intervals for beta
tmp = (ARDL.sige)*(diag(xpxi));
bstd = sqrt(tmp);
ARDL.bstd  = bstd;
tcrit = -tdis_inv(.025,nobse-nvar);
ARDL.bint  = [ARDL.beta-tcrit.*bstd, ARDL.beta+tcrit.*bstd];
ARDL.tstat = ARDL.beta./(sqrt(tmp));
ARDL.tprob = tdis_prb(ARDL.tstat,nobse-nvar);

% R-squared and adjusted R-squared
ym = Y - mean(Y);
rsqr1 = sigu;
rsqr2 = ym'*ym;
ARDL.rsqr = 1.0 - rsqr1/rsqr2;
rsqr1 = rsqr1/(nobse-nvar);
rsqr2 = rsqr2/(nobse-1.0);
if rsqr2 ~= 0
    ARDL.rbar = 1 - (rsqr1/rsqr2);
else
    ARDL.rbar = ARDL.rsqr;
end

% Durbin-Watson statistic
ediff = ARDL.resid(2:nobse) - ARDL.resid(1:nobse-1);
ARDL.dw    = (ediff'*ediff)/sigu;

% F-test of overall significance (only meaningful when a constant is included)
if const>0
    fx    = X(:,1);
    fxpxi = (fx'*fx)\eye(1);
    fbeta = fxpxi*(fx'*Y);
    fyhat = fx*fbeta;
    fresid = Y - fyhat;
    fsigu  = fresid'*fresid;
    fym    = Y - mean(Y);
    frsqr1 = fsigu;
    frsqr2 = fym'*fym;
    frsqr  = 1.0 - frsqr1/frsqr2;
    ARDL.F = ((frsqr-ARDL.rsqr)/(1-nvar)) / ((1-ARDL.rsqr)/(nobse-nvar));
end
