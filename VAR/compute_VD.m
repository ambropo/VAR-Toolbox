function VD = compute_VD(VAR, VARopt, B, PSI)
% =====================================================================
% Compute forecast error variance decompositions (FEVDs) given an
% estimated VAR, an identified structural impact matrix B, and the Wold
% multipliers PSI.
% =====================================================================
% VD = compute_VD(VAR, VARopt, B, PSI)
% ---------------------------------------------------------------------
% INPUT
%   - VAR:    structure, result of VARmodel OLS estimation
%   - VARopt: options structure; relevant field: VARopt.nsteps
%   - B:      (nvar x nvar) structural impact matrix from recover_B
%   - PSI:    (nvar x nvar x nsteps) Wold multipliers from compute_wold
% ---------------------------------------------------------------------
% OUTPUT
%   - VD: (nsteps x nvar x nvar) variance decompositions in percent;
%         VD(h, shock, variable) is the share of the h-step forecast error
%         variance of variable explained by shock (in percent)
% ---------------------------------------------------------------------
% EXAMPLE
%   VAR.nvar = 3; VAR.sigma = eye(3); VARopt.nsteps = 10;
%   B = eye(3); PSI = repmat(eye(3),[1 1 10]);
%   VD = compute_VD(VAR, VARopt, B, PSI);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. UNPACK PARAMETERS
% ---------------------------------------------------------------------
% Read horizon, cross-section dimension, and reduced-form VCV from the
% input structures; pre-allocate output and intermediate arrays.
nsteps = VARopt.nsteps;
nvar   = VAR.nvar;
sigma  = VAR.sigma;

% Pre-allocate output array and intermediate MSE accumulation arrays
VD        = zeros(nsteps, nvar, nvar);
MSE       = zeros(nvar, nvar, nsteps);
MSE_shock = zeros(nvar, nvar, nsteps);

%% 2. COMPUTE VARIANCE DECOMPOSITIONS
% ---------------------------------------------------------------------
% For each structural shock ii, accumulate the total forecast error MSE
% and the MSE attributable to shock ii alone. FEVD is the diagonal share:
% VD(h,ii,kk) = 100 * MSE_shock(kk,kk,h) / MSE(kk,kk,h).
% Total h-step forecast error MSE: recursive formula (does not depend on ii)
MSE(:,:,1) = sigma;
for nn = 2:nsteps
    MSE(:,:,nn) = MSE(:,:,nn-1) + PSI(:,:,nn)*sigma*PSI(:,:,nn)';
end

for ii = 1:nvar

    % MSE attributable to shock ii alone
    MSE_shock(:,:,1) = B(:,ii) * B(:,ii)';
    for nn = 2:nsteps
        MSE_shock(:,:,nn) = MSE_shock(:,:,nn-1) + PSI(:,:,nn)*MSE_shock(:,:,1)*PSI(:,:,nn)';
    end

    % FEVD: diagonal share of MSE attributable to shock ii
    FECD = MSE_shock(1:nvar,1:nvar,:) ./ MSE(1:nvar,1:nvar,:);
    for nn = 1:nsteps
        for kk = 1:nvar
            VD(nn,ii,kk) = 100 * FECD(kk,kk,nn);
        end
    end

end
