function [VAR, VARopt] = VARmodel(ENDO,nlag,const,EXOG,nlag_ex)
% =======================================================================
% Perform vector autogressive (VAR) estimation with OLS 
% =======================================================================
% [VAR, VARopt] = VARmodel(ENDO,nlag,const,EXOG,nlag_ex)
% -----------------------------------------------------------------------
% INPUT
%	- ENDO: an (nobs x nvar) matrix of y-vectors
%	- nlag: lag length
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%	- const: 0 no constant; 1 constant; 2 constant and trend; 3 constant, 
%       trend, and trend^2 [dflt = 0]
%	- EXOG: optional matrix of variables (nobs x nvar_ex)
%	- nlag_ex: number of lags for exogeonus variables [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - VAR: structure including VAR estimation results
%   - VARopt: structure including VAR options (see VARoption)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% Note: this code is a modified version of of the vare.m function of James 
% P. LeSage

% Representation -->  Y = Y(-1)*F' + u

% Note: compared to Eviews, there is a difference in the estimation of the 
% constant when lag is > 2. This is because Eviews initialize the trend
% with the number of lags (i.e., when lag=2, the trend is [2 3 ...T]), 
% while VARmakexy.m initialize the trend always with 1.

% I thank Jan Capek for spotting and addressing a compatibility issue with
% Matlab R2014a


%% Check inputs
%===============================================
[nobs, nvar] = size(ENDO);

% Create VARopt and update it
VARopt = VARoption;
VAR.ENDO = ENDO;
VAR.nlag = nlag;

% Check if ther are constant, trend, both, or none
if ~exist('const','var')
    const = 1;
end
VAR.const = const;

% Check if there are exogenous variables 
if exist('EXOG','var')
    [nobs2, nvar_ex] = size(EXOG);
    % Check that ENDO and EXOG are conformable
    if (nobs2 ~= nobs)
        error('var: nobs in EXOG-matrix not the same as y-matrix');
    end
    clear nobs2
    % Check if there is lag order of EXOG, otherwise set it to 0
    if ~exist('nlag_ex','var')
        nlag_ex = 0;
    end
    VAR.EXOG = EXOG;
else
    nvar_ex = 0;
    nlag_ex = 0;
    VAR.EXOG = [];
end


%% Save some parameters and create data matrices
%===============================================
    nobse         = nobs - max(nlag,nlag_ex);
    VAR.nobs      = nobse;
    VAR.nvar      = nvar;
    VAR.nvar_ex   = nvar_ex;    
    VAR.nlag      = nlag;
    VAR.nlag_ex   = nlag_ex;
    ncoeff        = nvar*nlag; 
    VAR.ncoeff    = ncoeff;
    ncoeff_ex     = nvar_ex*(nlag_ex+1);
    ntotcoeff     = ncoeff + ncoeff_ex + const;
    VAR.ntotcoeff = ntotcoeff;
    VAR.const     = const;

% Create independent vector and lagged dependent matrix
[Y, X] = VARmakexy(ENDO,nlag,const);

% Create (lagged) exogeanous matrix
if nvar_ex>0
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


%% OLS estimation equation by equation
%===============================================

for j=1:nvar;
    Yvec = Y(:,j);
    OLSout = OLSmodel(Yvec,X,0);
    aux = ['eq' num2str(j)];
    eval( ['VAR.' aux '.beta  = OLSout.beta;'] );  % bhats
    eval( ['VAR.' aux '.tstat = OLSout.tstat;'] ); % t-stats
    % compute t-probs
    tstat = zeros(ncoeff,1);
    tstat = OLSout.tstat;
    tout = tdis_prb(tstat,nobse-ncoeff);
    eval( ['VAR.' aux '.tprob = tout;'] );        % t-probs
    eval( ['VAR.' aux '.resid = OLSout.resid;'] );% resids 
    eval( ['VAR.' aux '.yhat  = OLSout.yhat;'] ); % yhats
    eval( ['VAR.' aux '.y     = Yvec;'] );        % actual y
    eval( ['VAR.' aux '.rsqr  = OLSout.rsqr;'] ); % r-squared
    eval( ['VAR.' aux '.rbar  = OLSout.rbar;'] ); % r-adjusted
    eval( ['VAR.' aux '.sige  = OLSout.sige;'] ); % standard error
end 


%% Compute the matrix of coefficients & VCV
%===============================================
Ft = (X'*X)\(X'*Y);
VAR.Ft = Ft;
SIGMA = (1/(nobse-ntotcoeff))*(Y-X*Ft)'*(Y-X*Ft); % adjusted for # of estimated coeff per equation
VAR.sigma = SIGMA;
VAR.residuals = Y - X*Ft;
VAR.X = X;
VAR.Y = Y;
if nvar_ex > 0
    VAR.X_EX = X_EX;
end


%% Companion matrix of Ft' and max eigenvalue
%===============================================
F = Ft';
Fcomp = [F(:,1+const:nvar*nlag+const); eye(nvar*(nlag-1)) zeros(nvar*(nlag-1),nvar)];
VAR.Fcomp = Fcomp;
VAR.maxEig = max(abs(eig(Fcomp)));

%% Initialize other results
%===============================================
VAR.invA = [];  % inverse of teh A matrix (need identification: see VARir/VARfevd)
VAR.S    = [];  % Orthonormal matrix (need identification: see SR)


