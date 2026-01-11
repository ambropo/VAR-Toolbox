function ARDL = ARDLmodel(ENDO,nlag,const,EXOG,nlag_ex)
% =======================================================================
% Estimate ARDL models with OLS 
% =======================================================================
% ARDL = ARDLmodel(ENDO,nlag,const,EXOG,nlag_ex)
% -----------------------------------------------------------------------
% INPUT
%	- ENDO: an (nobs x 1) vector of endogenous
%	- nlag: lag length
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%	- const: 0 no constant; 1 constant; 2 constant and trend; 3 constant, 
%       trend, and trend^2 [dflt = 0]
%	- EXOG: optional vector of exogenous variable (nobs x 1)
%	- nlag_ex: number of lags for exogeonus variable [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - VAR: structure including VAR estimation results
%   - VARopt: structure including VAR options (see VARoption)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% Check inputs
%===============================================
[nobs, ~] = size(ENDO);
ARDL.ENDO = ENDO;
ARDL.nlag = nlag;

% Check if ther are constant, trend, both, or none
if ~exist('const','var')
    const = 1;
end
ARDL.const = const;

% Check if there is exogenous variable
if exist('EXOG','var')
    [nobs_ex, nvar_ex] = size(EXOG);
    % Check that ENDO and EXOG are conformable
    if (nobs_ex ~= nobs)
        error('var: nobs in EXOG-matrix not the same as y-matrix');
    end
    clear nobs_ex
    % Check if there is lag order of EXOG, otherwise set it to 0
    if ~exist('nlag_ex','var')
        nlag_ex = 0;
    end
    ARDL.EXOG = EXOG;
else
    nvar_ex = 0;
    nlag_ex = 0;
    ARDL.EXOG = [];
end


%% Save some parameters and create data matrices
%===============================================
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
    ARDL.const   = const;

% Create independent vector and lagged dependent matrix
[Y, X] = VARmakexy(ENDO,nlag,const);

% Create (lagged) exogenous matrix
if exist('EXOG','var')
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

ARDL.meth = 'ols';
ARDL.y = Y;
ARDL.x = X;

% xpxi = (X'X)^(-1)
if nobse < 10000
  [~, r] = qr(X,0);
  xpxi = (r'*r)\eye(nvar);
else
  xpxi = (X'*X)\eye(nvar);
end;

% OLS estimator
beta = xpxi*(X'*Y);
ARDL.beta = beta;

% Predicted values & residuals
ARDL.yhat = X*ARDL.beta;
ARDL.resid = Y - ARDL.yhat;

% Covariance matrix of residuals
sigu = ARDL.resid'*ARDL.resid;
ARDL.sige = sigu/(nobse-nvar);

% Covariance matrix of beta
sigbeta = ARDL.sige*xpxi;
ARDL.sigbeta = sigbeta;

% Std errors of beta, t-stats, and intervals
tmp = (ARDL.sige)*(diag(xpxi));
bstd = sqrt(tmp);
ARDL.bstd = bstd;
tcrit=-tdis_inv(.025,nobse);
ARDL.bint=[ARDL.beta-tcrit.*bstd, ARDL.beta+tcrit.*bstd];
ARDL.tstat = ARDL.beta./(sqrt(tmp));
ARDL.tprob = tdis_prb(ARDL.tstat,nobs);

% R2
ym = Y - mean(Y);
rsqr1 = sigu;
rsqr2 = ym'*ym;
ARDL.rsqr = 1.0 - rsqr1/rsqr2; % r-squared
rsqr1 = rsqr1/(nobse-nvar);
rsqr2 = rsqr2/(nobse-1.0);
if rsqr2 ~= 0
    ARDL.rbar = 1 - (rsqr1/rsqr2); % rbar-squared
else
    ARDL.rbar = ARDL.rsqr;
end;

% Durbin-Watson
ediff = ARDL.resid(2:nobse) - ARDL.resid(1:nobse-1);
ARDL.dw = (ediff'*ediff)/sigu; % durbin-watson
ARDL.const = const;

% F-test
if const>0
    fx = X(:,1); 
    fxpxi = (fx'*fx)\eye(1);
    fbeta = fxpxi*(fx'*Y);
    fyhat = fx*fbeta;
    fresid = Y - fyhat;
    fsigu = fresid'*fresid;
    fym = Y - mean(Y);
    frsqr1 = fsigu;
    frsqr2 = fym'*fym;
    frsqr = 1.0 - frsqr1/frsqr2; % r-squared
    ARDL.F = ((frsqr-ARDL.rsqr)/(1-nvar)) / ((1-ARDL.rsqr)/(nobse-nvar));
end


% % Long-run coefficients
% q = ncoeff_ex;
% p = ncoeff;
% 
% sumendo = sum(beta(const+1:const+p)); % sum of lagged endo
% sumexog = sum(beta(const+p+1:end)); % sum of cont and lagged exog
% 
% theta = sumexog/(1-sumendo);
% ARDL.theta = theta;
% 
% aux1(1:p,1) = sumexog/((1-sumendo)^2);
% aux2(1:q,1) = 1/(1-sumendo);
% dtheta = [aux1; aux2];
% sigbeta_noconst = sigbeta(const+1:nvar,const+1:nvar);
% ARDL.sigtheta = dtheta'*sigbeta_noconst*dtheta;








