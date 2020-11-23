function OLS = OLSmodel(y,x,const)
% =======================================================================
% OLS regression
% =======================================================================
% OLS = OLSmodel(y,x,const)
% -----------------------------------------------------------------------
% INPUT
%	- y: dependent variable vector    (nobs x 1)
%	- x: independent variables matrix (nobs x nvar)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%	- const: 0 no constant; 1 constant; 2 constant and trend; 3 constant, 
%       trend, and trend^2 [dflt = 0]
% -----------------------------------------------------------------------
% OUPUT
%	- OLS: structure including VAR estimation results
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% This script is based on ols.m script by James P. LeSage


% Check inputs
if isempty(x)
    [nobs, ~] = size(y);
    nvar = 0;
else
    [nobs, nvar] = size(x); 
    [nobs2, ~] = size(y);
    if (nobs ~= nobs2); error('x and y must have same # obs'); end
end

% Check if ther are constant, trend, both, or none
if ~exist('const','var')
    const = 1;
end

% Add constant or trend if needed
if const==1 %constant
    x = [ones(nobs,1) x];
    nvar = nvar+1;
elseif const==2 % time trend and constant
    trend = 1:nobs;
    x = [ones(nobs,1) trend' x];
    nvar = nvar+2;
elseif const==3 % time trend, trend^2, and constant
    trend = 1:nobs;
    x = [ones(nobs,1) trend' trend'.^2 x];
    nvar = nvar+3;
end

OLS.meth = 'ols';
OLS.y = y;
OLS.x = x;
OLS.nobs = nobs;
OLS.nvar = nvar;

if nobs < 10000
  [~, r] = qr(x,0);
  xpxi = (r'*r)\eye(nvar);
else
  xpxi = (x'*x)\eye(nvar);
end;

OLS.beta = xpxi*(x'*y);
OLS.yhat = x*OLS.beta;
OLS.resid = y - OLS.yhat;
sigu = OLS.resid'*OLS.resid;
OLS.sige = sigu/(nobs-nvar);
tmp = (OLS.sige)*(diag(xpxi));
sigb=sqrt(tmp);
OLS.bstd = sigb;
tcrit=-tdis_inv(.025,nobs);
OLS.bint=[OLS.beta-tcrit.*sigb, OLS.beta+tcrit.*sigb];
OLS.tstat = OLS.beta./(sqrt(tmp));
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
end;
ediff = OLS.resid(2:nobs) - OLS.resid(1:nobs-1);
OLS.dw = (ediff'*ediff)/sigu; % durbin-watson

% F-test
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
