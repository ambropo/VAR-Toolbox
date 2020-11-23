function [AIC, SBC, logL] = VARlag(ENDO,maxlag,const,EXOG,lag_ex)
% =======================================================================
% Determine VAR lag length with Akaike (AIC) and Schwarz Bayesian 
% Criterion (SBC)criterion.
% =======================================================================
% [AIC, SBC, logL] = VARlag(ENDO,maxlag,const,EXOG,lag_ex)
% -----------------------------------------------------------------------
% INPUT
%   - ENDO: an (nobs x nvar) matrix of endogenous variables.
%	- maxlag: the maximum lag length over which Akaike information 
%       criterion is computed
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - const: 0 no constanrt; 1 constant ; 2 constant and trend; 
%           3 constant and trend^2; [dflt = 1]
%	- EXOG: optional matrix of variables (nobs x nvar_ex)
%   - nlag_ex: number of lags for exogeonus variables (dflt = 0)
% -----------------------------------------------------------------------
% OUTPUT
%	- AIC: preferred lag lenghth according to AIC
%   - SBC: preferred lag lenghth according to SBC
%   - logL: vector [maxlag x 1] of loglikelihood
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   OUT = VARmakelags(x,2)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------




%% Check inputs
%=========================================================
[nobs, ~] = size(ENDO);

% Check if ther are constant, trend, both, or none
if ~exist('const','var')
    const = 1;
end

% Check if there are exogenous variables
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

% Check if there is lag order of EXOG, otherwise set it to 0
if ~exist('lag_ex','var')
    lag_ex = 0;
end

% number of exogenous variables per equation
nvar_ex = num_ex*(lag_ex+1);

%% Compute log likelihood and Akaike criterion
%=========================================================
logL = zeros(maxlag,1);
AIC  = zeros(maxlag,1);
SBC  = zeros(maxlag,1);
for i=1:maxlag
    X = ENDO(maxlag+1-i:end,:);
    aux = VARmodel(X,i,const);
    if nvar_ex>0
        Y = EXOG(maxlag+1-i:end,:);
        aux = VARmodel(X,i,const,Y,lag_ex);
    end
    NOBSadj = aux.nobs;
    NOBS = aux.nobs + i;  
    NVAR = aux.nvar;
    NTOTCOEFF = aux.ntotcoeff;
    RES = aux.residuals;
    % VCV of the residuals (use dof adjusted denominator)
    SIGMA = (1/(NOBSadj)).*(RES)'*(RES);
    % Log-likelihood
    logL(i) = -(NOBS/2)* (NVAR*(1+log(2*pi)) + log(det(SIGMA)));
    % AIC: –2*LogL/T + 2*n/T, where n is total number of parameters (ie, NVAR*NTOTCOEFF)
    AIC(i) = -2*(logL(i)/NOBS) + 2*(NVAR*NTOTCOEFF)/NOBS;
    % SBC: –2*LogL/T + n*log(T)/T
    SBC(i) = -2*(logL(i)/NOBS) + (NVAR*NTOTCOEFF)*log(NOBS)/NOBS;
end
% Find the min of the info criteria
AIC = find(AIC==min(AIC));
SBC = find(SBC==min(SBC));



































