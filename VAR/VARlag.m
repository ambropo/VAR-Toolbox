function [AIC, BIC, logL] = VARlag(ENDO,maxlag,const,EXOG,lag_ex)
% =====================================================================
% Select VAR lag length by minimizing the Akaike (AIC) or Bayesian (BIC)
% information criterion over candidate lags 1 through maxlag.
% =====================================================================
% [AIC, BIC, logL] = VARlag(ENDO,maxlag,const,EXOG,lag_ex)
% ---------------------------------------------------------------------
% INPUT
%   - ENDO:   matrix of endogenous variables (nobs x nvar) [double]
%   - maxlag: maximum candidate lag length to evaluate [integer]
% ---------------------------------------------------------------------
% OPTIONAL INPUT
%   - const:  deterministic specification: 0=none, 1=constant (dflt),
%             2=constant+trend [dflt = 1]
%   - EXOG:   matrix of exogenous variables (nobs x nvar_ex) [double]
%   - lag_ex: number of lags for exogenous variables [dflt = 0]
% ---------------------------------------------------------------------
% OUTPUT
%   - AIC:  lag length that minimises AIC [integer]
%   - BIC:  lag length that minimises BIC [integer]
%   - logL: log-likelihood value at each candidate lag (maxlag x 1) [double]
% ---------------------------------------------------------------------
% EXAMPLE
%   Y = randn(200, 3);
%   [AIC, BIC, logL] = VARlag(Y, 8, 1);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. CHECK INPUTS
% ---------------------------------------------------------------------
[nobs, ~] = size(ENDO);

% Default deterministic specification to constant-only if not supplied
if ~exist('const','var')
    const = 1;
end
if const > 2
    error('VARlag: const must be 0, 1, or 2 (got %d)', const);
end

% Parse exogenous variables and verify conformability with ENDO
if exist('EXOG','var')
    [nobs2, num_ex] = size(EXOG);
    % Check that ENDO and EXOG are conformable
    if (nobs2 ~= nobs)
        error('var: nobs in EXOG-matrix not the same as y-matrix');
    end
    clear nobs2
else
    num_ex = 0;
end

% Default exogenous lag order to zero (contemporaneous inclusion only)
if ~exist('lag_ex','var')
    lag_ex = 0;
end

% Total number of exogenous regressors per equation (contemporaneous + lags)
nvar_ex = num_ex*(lag_ex+1);

%% 2. COMPUTE LOG LIKELIHOOD AND INFORMATION CRITERIA
% ---------------------------------------------------------------------
% For each candidate lag length, estimate the VAR on a common sample
% (starting at maxlag+1) and compute AIC and BIC.
logL = zeros(maxlag,1);
AIC  = zeros(maxlag,1);
BIC  = zeros(maxlag,1);
for i=1:maxlag
    % Estimate VAR with lag length i on a sample aligned to the longest lag
    X = ENDO(maxlag+1-i:end,:);
    aux = VARmodel(X,i,const);
    if nvar_ex>0
        Y = EXOG(maxlag+1-i:end,:);
        aux = VARmodel(X,i,const,[],Y,lag_ex);
    end

    % Extract key quantities from the VAR output
    NOBSadj   = aux.nobs;     % observations used in estimation (after lag trimming)
    NOBS      = aux.nobs + i; % restore total observations by adding back the i initial lags
    NVAR      = aux.nvar;
    NTOTCOEFF = aux.ntotcoeff;
    RES       = aux.resid;

    % VCV of the residuals (plain MLE denominator for likelihood comparison)
    SIGMA = (1/NOBSadj) * (RES)' * (RES);

    % Log-likelihood under normality
    logL(i) = -(NOBS/2) * (NVAR*(1+log(2*pi)) + log(det(SIGMA)));

    % AIC: -2*logL/T + 2*k/T, where k = NVAR*NTOTCOEFF total parameters
    AIC(i) = -2*(logL(i)/NOBS) + 2*(NVAR*NTOTCOEFF)/NOBS;

    % BIC: -2*logL/T + k*log(T)/T (penalises more heavily than AIC)
    BIC(i) = -2*(logL(i)/NOBS) + (NVAR*NTOTCOEFF)*log(NOBS)/NOBS;
end

% Return the lag length that minimises each criterion
AIC = find(AIC==min(AIC));
BIC = find(BIC==min(BIC));
