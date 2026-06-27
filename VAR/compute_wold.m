function [PSI, VAR] = compute_wold(VAR, VARopt)
% =====================================================================
% Compute the Wold moving-average multiplier matrices PSI(:,:,h) for
% h = 1, ..., nsteps and store the lag-polynomial matrices in VAR.Fp.
% =====================================================================
% [PSI, VAR] = compute_wold(VAR, VARopt)
% ---------------------------------------------------------------------
% INPUT
%   - VAR:    structure, result of VARmodel OLS estimation
%   - VARopt: options structure; relevant field: VARopt.nsteps
% ---------------------------------------------------------------------
% OUTPUT
%   - PSI:    (nvar x nvar x nsteps) Wold multiplier matrices
%   - VAR:    updated with .Fp (nvar x nvar x nsteps) lag-polynomial
% ---------------------------------------------------------------------
% EXAMPLE
%   VAR.nvar = 2; VAR.nlag = 1; VAR.const = 1; VARopt.nsteps = 8;
%   VAR.F = [zeros(2,1), 0.5*eye(2)]; [PSI, VAR] = compute_wold(VAR, VARopt);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. UNPACK PARAMETERS
% ---------------------------------------------------------------------
% Read horizon, cross-section dimension, and lag order from the input
% structures; pre-allocate PSI, Fp, and set the column offset I to skip
% the deterministic block in VAR.F.
nsteps = VARopt.nsteps;
nvar   = VAR.nvar;
nlag   = VAR.nlag;

% Pre-allocate PSI and Fp arrays; set column offset past the deterministic block
PSI    = zeros(nvar, nvar, nsteps);
VAR.Fp = zeros(nvar, nvar, nlag);
I      = VAR.const + 1; % first column of the lag-1 block in VAR.F

%% 2. EXTRACT LAG-POLYNOMIAL MATRICES
% ---------------------------------------------------------------------
% Read Fp(:,:,1),...,Fp(:,:,nlag) from VAR.F column by column, starting
% past the deterministic block. Slices beyond nlag are padded with zeros.
for ii = 1:nsteps
    if ii <= nlag
        VAR.Fp(:,:,ii) = VAR.F(:, I:I+nvar-1);
    else
        VAR.Fp(:,:,ii) = zeros(nvar, nvar);
    end

    % Advance the column pointer by one block of nvar columns
    I = I + nvar;
end

%% 3. COMPUTE WOLD MULTIPLIERS
% ---------------------------------------------------------------------
% Recursive computation: PSI(h) = sum_{j=1}^{h-1} PSI(h-j) * Fp(j),
% with PSI(1) = I (identity, impact period).
PSI(:,:,1) = eye(nvar);
for ii = 2:nsteps
    jj  = 1;
    aux = 0;
    while jj < ii
        aux = aux + PSI(:,:,ii-jj) * VAR.Fp(:,:,jj);
        jj  = jj + 1;
    end
    PSI(:,:,ii) = aux;
end
