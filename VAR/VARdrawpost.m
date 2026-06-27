function [sigma_draw, Ft_draw, F_draw, Fcomp_draw] = VARdrawpost(VAR)
% =======================================================================
% Draw one sample from the posterior distribution of the VAR coefficients
% and covariance matrix under a flat (diffuse) prior
% =======================================================================
% [sigma_draw, Ft_draw, F_draw, Fcomp_draw] = VARdrawpost(VAR)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function [struct]
% -----------------------------------------------------------------------
% OUTPUT
%   - sigma_draw: draw from the posterior of the VCV matrix of VAR
%                 residuals [double, nvar x nvar]
%   - Ft_draw: draw from the posterior of Ft (coefficient matrix,
%              ncoeff x nvar) [double]
%   - F_draw: transpose of Ft_draw (nvar x ncoeff) [double]
%   - Fcomp_draw: companion form matrix of the draw [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   VAR = VARmodel(randn(100,3), 2, 1);
%   [sigma_draw, Ft_draw, F_draw, Fcomp_draw] = VARdrawpost(VAR);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. RETRIEVE PARAMETERS
% -----------------------------------------------------------------------
% Extract dimensions and estimation objects needed for the posterior draws
nobs  = VAR.nobs;
X     = VAR.X;
const = VAR.const;
nvar  = VAR.nvar;
nlag  = VAR.nlag;

% Number of rows in the coefficient matrix (regressors per equation)
k = size(X, 2);

%% 2. OLS ESTIMATES
% -----------------------------------------------------------------------
% Store OLS point estimates used as the posterior mean (flat prior)
Ft_hat        = VAR.Ft;
sigma_hat     = VAR.sigma;

% The Wishart draw requires the explicit inverse of the scale matrix as
% input (not a solve), so inv() is intentional here.
inv_sigma_hat = inv(sigma_hat);

%% 3. DRAW THE VCV MATRIX
% -----------------------------------------------------------------------
% Use a Wishart draw on the precision matrix and invert to get sigma
inv_sigma_draw = wishrnd(inv_sigma_hat/nobs, nobs);
sigma_draw     = inv(inv_sigma_draw);

%% 4. DRAW THE COEFFICIENT MATRIX
% -----------------------------------------------------------------------
% Compute the Kronecker-structured VCV of the vectorised coefficient matrix
aux1 = (X'*X)\eye(size(X,2));
aux2 = kron(sigma_draw, aux1);

% Force symmetry to guard against numerical rounding errors
aux2 = (aux2 + aux2')/2;
Fthat_vec = Ft_hat(:);
Ftdraw    = mvnrnd(Fthat_vec, aux2);
Ft_draw   = reshape(Ftdraw, k, nvar);
F_draw    = Ft_draw';

% Build the companion form matrix for the drawn coefficients
Fcomp_draw = [F_draw(:,1+const:nvar*nlag+const); eye(nvar*(nlag-1)) zeros(nvar*(nlag-1),nvar)];
