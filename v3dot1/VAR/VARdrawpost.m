function [sigma_draw, Ft_draw, F_draw, Fcomp_draw] = VARdrawpost(VAR)
% =======================================================================
% Draw from the posterior distribution of a VAR model
% =======================================================================
% [sigma_draw, Ft_draw] = VARdrawpost(VAR)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function
% -----------------------------------------------------------------------
% OUPUT
%   - sigma_draw: draw from the posterior of VCV matrix of VAR residuals 
%   - Ft_draw: draw from the posterior of Ft of VAR
% -----------------------------------------------------------------------
% EXAMPLE
%   - See VARToolbox_Code.m in "../Primer/"
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% Get relevant parameters from VAR structure
%===============================================
nobs = VAR.nobs;
k    = [];
X    = VAR.X;
const= VAR.const;
nvar = VAR.nvar;
nlag = VAR.nlag;


%% OLS estimates
%============================================
Ft_hat = VAR.Ft;
sigma_hat = VAR.sigma;
inv_sigma_hat = inv(sigma_hat);
    

%% Draw the VCV matrix (sigma)
%============================================
inv_sigma_draw = wishrnd(inv_sigma_hat/nobs,nobs);
sigma_draw     = inv(inv_sigma_draw);

%% Draw the coeffiecient matrix (Ft)
%============================================
% Compute VCV of coefficient matrix
aux1 = (X'*X)\eye(size(X,2));
aux2 = kron(sigma_draw, aux1); 
aux2 = (aux2 + aux2')/2; % Force symmetry (might fail bc of numerical error)
Fthat_vec = Ft_hat(:);
Ftdraw = mvnrnd(Fthat_vec,aux2);
Ft_draw = reshape(Ftdraw,k,nvar);
F_draw = Ft_draw';
Fcomp_draw = [F_draw(:,1+const:nvar*nlag+const); eye(nvar*(nlag-1)) zeros(nvar*(nlag-1),nvar)];

