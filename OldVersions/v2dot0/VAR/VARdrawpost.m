function [sigma_draw, Ft_draw] = VARdrawpost(VAR)
% =======================================================================
% Draw from the posterior distribution of a VAR model
% =======================================================================
% [sigma_draw, Ft_draw] = VARdrawpost(VAR)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function
% -----------------------------------------------------------------------
% OUPUT
%   - sigma_draw: draw from the posterior of VCV matrix of residuals of VAR
%   - Ft_draw: draw from the posterior of Ft of VAR
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com



%% Get relevant parameters from VAR structure
%===============================================
nobs = VAR.nobs;
k    = [];
nvar = VAR.nvar;
X    = VAR.X;


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
aux1 = inv(X'*X);
aux2 = kron(sigma_draw, aux1);
Fthat_vec = Ft_hat(:);
Ftdraw = mvnrnd(Fthat_vec,aux2);
Ft_draw = reshape(Ftdraw,k,nvar);
