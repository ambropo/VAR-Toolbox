function [laglength, AIC, logL] = VARlag(ENDO,maxlag,c_case,EXOG,lag_ex)
% =======================================================================
% Determines VAR lag length wit Akaike criterion
% =======================================================================
% [laglength, AIC, logL] = VARlag(ENDO,maxlag,c_case,EXOG,lag_ex)
% -----------------------------------------------------------------------
% INPUTS 
%   ENDO = an (nobs x neqs) matrix of y-vectors
%	maxlag = the maximum lag length over which Akaike information criterion
%            is computed
%
% OPTIONAL INPUTS
%   c_case  = 0 no const; 1 const ; 2 const&trend; 3 const&trend^2; (default = 1)
%	EXOG = optional matrix of variables (nobs x nvar_ex)
%   nlag_ex = number of lags for exogeonus variables (default = 0)
%--------------------------------------------------------------------------
% OUTPUT
%    laglength = preferred lag lenghth according to Akaike information criterion
%    AIC       = vector [maxlag x 1] of Akaike information criterion
%    logL      = vector [maxlag x 1] of loglikelihood
% =======================================================================
% Ambrogio Cesa Bianchi, October 2013
% ambrogio.cesabianchi@gmail.com

% Note: 
% The determinant of the residual covariance is computed without adjusting
% for the degrees of freedom. The log likelihood value is computed assuming 
% a multivariate normal (Gaussian) distribution

%% Check inputs
%==============
[nobs, ~] = size(ENDO);

% Check if ther are constant, trend, both, or none
if ~exist('c_case','var')
    c_case = 1;
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
for i=1:maxlag
    X = ENDO(maxlag+1-i:end,:);
    aux = VARmodel(X,i,c_case);
    if nvar_ex>0
        Y = EXOG(maxlag+1-i:end,:);
        aux = VARmodel(X,i,c_case,Y,lag_ex);
    end
    NOBS = aux.nobs;
    NEQS = aux.neqs;
    NTOTCOEFF = aux.ntotcoeff;
    RES = aux.residuals;
    SIGMA = (1/(NOBS))*(RES)'*(RES); %use non dof adjusted version of sigma as in Eviews
    logL(i) = -(NOBS/2)* (NEQS*(1+log(2*pi)) + log(det(SIGMA)));
    AIC(i)  = -2*(logL(i)/NOBS) + 2*(NEQS*NTOTCOEFF/NOBS);
end
    
laglength = find(AIC==min(AIC));

