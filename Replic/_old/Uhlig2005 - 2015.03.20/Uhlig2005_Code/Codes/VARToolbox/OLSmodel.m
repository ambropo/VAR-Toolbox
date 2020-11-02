function OLSout = OLSmodel(y,x,c_case)
% =======================================================================
% OLS regression
% =======================================================================
% OLSout = OLSmodel(y,x,c_case)
% -----------------------------------------------------------------------
% INPUT
%   y: dependent variable vector    (nobs x 1)
%   x: independent variables matrix (nobs x nvar)
%
% OPTIONAL INPUT
%   c_case: 0 no const; 1 const ; 2 const&trend; 3 const&trend^2; (dflt = 1)
%------------------------------------------------------------------------
% OUPUT
%   OLSout.meth : 'ols'
%   OLSout.beta : bhat     (nvar x 1)
%   OLSout.tstat: t-stats  (nvar x 1)
%   OLSout.bstd : std deviations for bhat (nvar x 1)
%   OLSout.yhat : yhat     (nobs x 1)
%   OLSout.resid: residuals (nobs x 1)
%   OLSout.sige : e'*e/(n-k)   scalar
%   OLSout.rsqr : rsquared     scalar
%   OLSout.rbar : rbar-squared scalar
%   OLSout.dw   : Durbin-Watson Statistic
%   OLSout.nobs : nobs
%   OLSout.nvar : nvars
%   OLSout.y    : y data vector (nobs x 1)
%   OLSout.bint : (nvar x2 ) vector with 95% confidence intervals on beta
% =======================================================================
% Ambrogio Cesa Bianchi, Juanuary 2014
% ambrogio.cesabianchi@gmail.com

% This script is based on ols.m script by James P. LeSage

if ~exist('x','var')
    x = [];
    [nobs, ~] = size(y);
    nvar = 0;
else
    [nobs, nvar] = size(x); 
    [nobs2, ~] = size(y);
    if (nobs ~= nobs2); error('x and y must have same # obs'); end
end

% Check if ther are constant, trend, both, or none
if ~exist('c_case','var')
    c_case = 1;
end

%X Add constant or trend if needed
if c_case==1 %constant
    x = [ones(nobs,1) x];
    nvar = nvar+1;
elseif c_case==2 % time trend and constant
    trend = 1:nobs;
    x = [ones(nobs,1) trend' x];
    nvar = nvar+2;
elseif c_case==3 % time trend, trend^2, and constant
    trend = 1:nobs;
    x = [ones(nobs,1) trend' trend'.^2 x];
    nvar = nvar+3;
end

OLSout.meth = 'ols';
OLSout.y = y;
OLSout.x = x;
OLSout.nobs = nobs;
OLSout.nvar = nvar;

if nobs < 10000
  [~, r] = qr(x,0);
  xpxi = (r'*r)\eye(nvar);
else
  xpxi = (x'*x)\eye(nvar);
end;

OLSout.beta = xpxi*(x'*y);
OLSout.yhat = x*OLSout.beta;
OLSout.resid = y - OLSout.yhat;
sigu = OLSout.resid'*OLSout.resid;
OLSout.sige = sigu/(nobs-nvar);
tmp = (OLSout.sige)*(diag(xpxi));
sigb=sqrt(tmp);
OLSout.bstd = sigb;
tcrit=-tdis_inv(.025,nobs);
OLSout.bint=[OLSout.beta-tcrit.*sigb, OLSout.beta+tcrit.*sigb];
OLSout.tstat = OLSout.beta./(sqrt(tmp));
ym = y - mean(y);
rsqr1 = sigu;
rsqr2 = ym'*ym;
OLSout.rsqr = 1.0 - rsqr1/rsqr2; % r-squared
rsqr1 = rsqr1/(nobs-nvar);
rsqr2 = rsqr2/(nobs-1.0);
if rsqr2 ~= 0
    OLSout.rbar = 1 - (rsqr1/rsqr2); % rbar-squared
else
    OLSout.rbar = OLSout.rsqr;
end;
ediff = OLSout.resid(2:nobs) - OLSout.resid(1:nobs-1);
OLSout.dw = (ediff'*ediff)/sigu; % durbin-watson
