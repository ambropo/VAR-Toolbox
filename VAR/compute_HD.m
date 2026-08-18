function HD = compute_HD(VAR, B)
% =======================================================================
% Compute historical decompositions (HDs): the contribution of each
% structural shock and each deterministic component to the historical
% path of each endogenous variable.
% =======================================================================
% HD = compute_HD(VAR, B)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel OLS estimation [struct]
%   - B:   (nvar x nvar) structural impact matrix from recover_B [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - HD: structure with fields (all in levels, NaN-padded for lag periods):
%       .shock  [(nobs+nlag) x nvar x nvar] contribution of each shock
%       .init   [(nobs+nlag) x nvar]        contribution of initial conditions
%       .const  [(nobs+nlag) x nvar]        contribution of constant
%       .trend  [(nobs+nlag) x nvar]        contribution of linear trend
%       .exo    [(nobs+nlag) x nvar x nvar_ex] contribution of exogenous vars
%       .exoshock [(nobs+nlag) x nvar]      contribution of the observed
%                                           exogenous shock regressor block
%                                           (ident='exog'); zero otherwise
%       .endo   [(nobs+nlag) x nvar]        total (sum of all components)
% -----------------------------------------------------------------------
% EXAMPLE
%   Y  = randn(100, 3);
%   VAR = VARmodel(Y, 2, 1);
%   B  = chol(VAR.sigma)';
%   HD = compute_HD(VAR, B);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------

% I thank Andrey Zubarev for finding a bug in the contribution of the
% exogenous variables when nvar_ex~=0 and nlag_ex>0.


%% 1. UNPACK PARAMETERS
% -----------------------------------------------------------------------
% Extract VAR dimensions, coefficient matrices, residuals, and data from
% the VAR structure. X is trimmed to the endogenous lag block only.
Fcomp   = VAR.Fcomp;
const   = VAR.const;
F       = VAR.Ft';
nvar    = VAR.nvar;
nvar_ex = VAR.nvar_ex;
nvarXeq = VAR.nvar * VAR.nlag;
nlag    = VAR.nlag;
Y       = VAR.Y;
X       = VAR.X(:, 1+const:nvarXeq+const);
nobs    = size(Y, 1);

% Structural shocks: eps(shock, time) = B^{-1} * u(time, var)'
eps     = B \ transpose(VAR.resid);
B_big   = zeros(nvarXeq, nvar);
B_big(1:nvar,:) = B;
Icomp   = [eye(nvar) zeros(nvar, (nlag-1)*nvar)];


%% 2. STRUCTURAL SHOCK CONTRIBUTIONS
% -----------------------------------------------------------------------
% Contribution of each structural shock j to each variable i, accumulated
% via the companion-form recursion using the companion-space impact matrix B_big.
HDshock_big = zeros(nlag*nvar, nobs+1, nvar);
HDshock     = zeros(nvar, nobs+1, nvar);
for j = 1:nvar
    eps_big = zeros(nvar, nobs+1);
    eps_big(j, 2:end) = eps(j,:);
    for i = 2:nobs+1
        HDshock_big(:,i,j) = B_big*eps_big(:,i) + Fcomp*HDshock_big(:,i-1,j);
        HDshock(:,i,j)     = Icomp * HDshock_big(:,i,j);
    end
end


%% 3. INITIAL CONDITIONS
% -----------------------------------------------------------------------
% Contribution of the initial state vector X(1,:) to subsequent periods,
% propagated forward through the companion form with no additional forcing.
HDinit_big      = zeros(nlag*nvar, nobs+1);
HDinit          = zeros(nvar, nobs+1);
HDinit_big(:,1) = X(1,:)';
HDinit(:,1)     = Icomp * HDinit_big(:,1);
for i = 2:nobs+1
    HDinit_big(:,i) = Fcomp * HDinit_big(:,i-1);
    HDinit(:,i)     = Icomp * HDinit_big(:,i);
end


%% 4. CONSTANT CONTRIBUTION
% -----------------------------------------------------------------------
% Isolate the effect of the intercept by feeding only the constant forcing
% vector CC through the companion recursion, with zero initial state.
HDconst_big = zeros(nlag*nvar, nobs+1);
HDconst     = zeros(nvar, nobs+1);
CC          = zeros(nlag*nvar, 1);
if const > 0
    CC(1:nvar,:) = F(:,1);
    for i = 2:nobs+1
        HDconst_big(:,i) = CC + Fcomp*HDconst_big(:,i-1);
        HDconst(:,i)     = Icomp * HDconst_big(:,i);
    end
end


%% 5. LINEAR TREND CONTRIBUTION
% -----------------------------------------------------------------------
% Isolate the effect of the linear trend by scaling TT by the period index
% and accumulating through the companion recursion.
HDtrend_big = zeros(nlag*nvar, nobs+1);
HDtrend     = zeros(nvar, nobs+1);
TT          = zeros(nlag*nvar, 1);
if const > 1
    TT(1:nvar,:) = F(:,2);
    for i = 2:nobs+1
        HDtrend_big(:,i) = TT*(i-1) + Fcomp*HDtrend_big(:,i-1);
        HDtrend(:,i)     = Icomp * HDtrend_big(:,i);
    end
end


%% 6. EXOGENOUS VARIABLE CONTRIBUTIONS
% -----------------------------------------------------------------------
% Loop over exogenous variables; for each one, feed its realisation through
% the companion recursion. VARmakelags orders X_EX as
% [EXOG(t), EXOG(t-1), ..., EXOG(t-nlag_ex)], each block nvar_ex columns
% wide, so variable ii at lag kk occupies column kk*nvar_ex+ii of X_EX and
% its coefficient sits in column base_ex+kk*nvar_ex+ii of F. Every included
% lag contributes to the forcing term: summing over kk is required for the
% components to reconstruct the data whenever nlag_ex>0. (Using only the
% contemporaneous column, as before, dropped all lagged EXOG contributions.)
nlag_ex   = VAR.nlag_ex;
base_ex   = const + nvarXeq + VAR.ncoeff_es;   % past deterministics, endo lags, exoshock block
HDexo_big = zeros(nlag*nvar, nobs+1);
HDexo     = zeros(nvar, nobs+1, nvar_ex);
if nvar_ex > 0
    for ii = 1:nvar_ex
        HDexo_big(:) = 0;                      % reset state for each exogenous variable

        % Total forcing contributed by variable ii at each date: contemporaneous
        % value plus every included lag, each weighted by its own coefficient
        force = zeros(nvar, nobs);
        for kk = 0:nlag_ex
            col   = kk*nvar_ex + ii;
            force = force + F(:, base_ex+col) * VAR.X_EX(:,col)';
        end

        for i = 2:nobs+1
            fvec           = zeros(nlag*nvar, 1);
            fvec(1:nvar)   = force(:,i-1);
            HDexo_big(:,i) = fvec + Fcomp*HDexo_big(:,i-1);
            HDexo(:,i,ii)  = Icomp * HDexo_big(:,i);
        end
    end
end


%% 7. IDENTIFIED EXOGENOUS SHOCK CONTRIBUTION
% -----------------------------------------------------------------------
% Under ident='exog' the observed shock enters the VAR as its own regressor
% block X_ES = [es(t), es(t-1), ..., es(t-nlag_es)], with coefficients in
% columns base_es+1 ... base_es+ncoeff_es of F. This forcing term is a
% component in its own right, distinct from the structural-shock block in
% section 2: HD.shock accounts for the reduced-form innovations, while X_ES
% is an observed regressor. Omitting it (as before) left the components
% short of the data by exactly this term whenever ident='exog'.
base_es        = const + nvarXeq;
HDexoshock_big = zeros(nlag*nvar, nobs+1);
HDexoshock     = zeros(nvar, nobs+1);
if VAR.ncoeff_es > 0
    force_es = zeros(nvar, nobs);
    for kk = 1:VAR.ncoeff_es
        force_es = force_es + F(:, base_es+kk) * VAR.X_ES(:,kk)';
    end
    for i = 2:nobs+1
        fvec                = zeros(nlag*nvar, 1);
        fvec(1:nvar)        = force_es(:,i-1);
        HDexoshock_big(:,i) = fvec + Fcomp*HDexoshock_big(:,i-1);
        HDexoshock(:,i)     = Icomp * HDexoshock_big(:,i);
    end
end


%% 8. TOTAL AND RESHAPE OUTPUT
% -----------------------------------------------------------------------
% All components must sum to the original data.
HDendo = HDinit + HDconst + HDtrend + HDexoshock + sum(HDexo,3) + sum(HDshock,3);

% Reshape to (nobs+nlag x nvar x nshock) with NaN padding over lag periods
HD.shock = zeros(nobs+nlag, nvar, nvar);
for i = 1:nvar
    for j = 1:nvar
        HD.shock(:,j,i) = [nan(nlag,1); HDshock(i,2:end,j)'];
    end
end

% init uses nlag-1 NaN rows (not nlag) because HDinit(:,1) holds the initial
% condition at t=0, which is aligned to the first observable period.
HD.init   = [nan(nlag-1,nvar); HDinit(:,1:end)'];
HD.const  = [nan(nlag,nvar);   HDconst(:,2:end)'];
HD.trend  = [nan(nlag,nvar);   HDtrend(:,2:end)'];
HD.exo    = zeros(nobs+nlag, nvar, nvar_ex);
for i = 1:nvar_ex
    HD.exo(:,:,i) = [nan(nlag,nvar); HDexo(:,2:end,i)'];
end
HD.exoshock = [nan(nlag,nvar); HDexoshock(:,2:end)'];
HD.endo   = [nan(nlag,nvar); HDendo(:,2:end)'];
