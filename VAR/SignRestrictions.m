function [B, n_tried] = SignRestrictions(SIGN,VAR,VARopt)
% =======================================================================
% Draw orthonormal rotations of the VAR covariance matrix until the
% rotation satisfies the sign restrictions specified in SIGN
% =======================================================================
% [B, n_tried] = SignRestrictions(SIGN,VAR,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - SIGN: sign restriction matrix (nvar x nshocks): +1 positive, -1
%           negative, 0 unrestricted [double]
%   - VAR: structure, result of VARmodel.m [struct]
%   - VARopt: options of the VAR (result of VARmodel.m) [struct]
% -----------------------------------------------------------------------
% OUTPUT
%   - B: impact matrix consistent with SIGN; empty if none found [double]
%   - n_tried: number of random rotations attempted before returning [integer]
% -----------------------------------------------------------------------
% EXAMPLE
%   SIGN = [1 0; -1 1; 0 -1];   % 3 vars, 2 shocks
%   VARopt = VARoption; VAR = VARmodel(randn(100,3), 2, 1, VARopt);
%   [B, n_tried] = SignRestrictions(SIGN, VAR, VARopt);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: August 2018. Updated: 2026-06-03
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Determine the number of variables (dy) and shocks (ds) from SIGN
dy = size(SIGN,1);
ds = size(SIGN,2);

% Check whether columns of B (and corresponding sigma) are already provided
if ~strcmp(VARopt.ident, 'sign+iv')
    if size(SIGN,1)==size(SIGN,2)
        sigma = VAR.sigma;
        Biv = [];
    % If SIGN is missing a column, assume corresponding Cholesky
    elseif size(SIGN,1)>size(SIGN,2)
        sigma = VAR.sigma;
        aux = chol(sigma)';
        % NOTE: this code path is only correct when dy-ds == 1 (exactly one
        % Cholesky column is pre-determined). When dy-ds > 1 only the first
        % such column is extracted; the additional pre-determined columns are
        % discarded. Use ident='sign+iv' (which populates VAR.B(:,1)) to
        % handle the multi-column pre-determined case.
        Biv = aux(:,size(SIGN,1)-size(SIGN,2));
    else
        error('Matrix SIGN has the wrong dimension');
    end
else
    % sign+iv: VAR.B(:,1) holds the IV-identified column (set by recover_B);
    % the full-sample VCV sigma is used for the rotation basis so that B*B'=sigma
    % exactly and FEVD rows sum to 1 (sigma_b covers only the IV subsample).
    sigma = VAR.sigma;
    Biv   = VAR.B(:,1);
end

% Determine the first column index to rotate; columns before whereToStart
% are already determined by Biv and are held fixed.
% Using size(Biv,2) as the source of truth handles sign+iv (1 pre-determined
% column) and plain-sign with dy>ds (1 Cholesky column) uniformly, without
% relying on the dy-ds formula which overcounts for sign+iv.
whereToStart = 1 + size(Biv, 2);
if ~(size(Biv,2)==whereToStart-1)
    error('Biv and SIGN must have compatible sizes')
end
nanMat = NaN*ones(dy,1);
orderIndices = 1:dy;

%% 2. SEARCH FOR VALID ROTATIONS
% -----------------------------------------------------------------------
% Repeatedly draw a random Householder-QR rotation matrix and apply it to
% the lower Cholesky of sigma. Accept the rotated B when all sign
% restrictions in SIGN are satisfied simultaneously.
counter = 1; flag = 0;
while 1
    % Create starting matrix to be rotated.
    % If one column of B has already been provided:
    if whereToStart>1
        C = chol(sigma,'lower');
        q = C\Biv;
        % Normalize to unit length: C\Biv is approximately but not exactly
        % unit-norm when Biv was calibrated against a different VCV (sigma_b).
        q = q / norm(q);
        for ii = whereToStart:dy
            r = randn(dy,1);
            q = [q (eye(dy)-q*q')*r/norm((eye(dy)-q*q')*r)];
        end
        % Check that q*q'=I:
        %q*q'
        startingMat = C*q;
        % Check that startingMat*startingMat'=SigmaHat:
        % startingMat*startingMat'
        % Check that first column of startingMat = Biv
        % [startingMat(:,1) Biv]
    % Otherwise start from a lower Cholesky
    else
        startingMat = chol(sigma,'lower');
    end
    counter = counter + 1;

    % Abort the search if the rotation budget is exhausted; flag triggers
    % an empty B return after the loop
    if counter>VARopt.sr_rot
        flag = 1;
        break
    end
    termaa = startingMat;
    TermA = 0;
    rotMat = eye(dy);
    rotMat(whereToStart:end,whereToStart:end) = OrthNorm(length(whereToStart:dy));

    % Rotate columns of startingMat with the Householder-QR matrix
    terma = termaa*rotMat;
    termaa = terma;

    % Update VAR_draw with the rotated B matrix
    VAR.B = termaa;

    % If sr_hor>1, compute IRF for horizon to be checked.
    % VARopt.nsteps is intentionally set to sr_hor here so that compute_IR
    % only evaluates the horizons needed for the sign check; the original
    % nsteps is not restored because the modified VARopt is local to this
    % function and the caller's VARopt is unaffected.
    if VARopt.sr_hor>1
        VARopt.nsteps=VARopt.sr_hor;
        [PSI, VAR] = compute_wold(VAR, VARopt);
        aux_irf = compute_IR(VAR, VARopt, VAR.B, PSI);
    end

    % Check sign restrictions: scan candidate columns of the rotated matrix
    % and greedily match each shock to the first column satisfying its
    % restrictions; a matched column is marked NaN so it cannot be reused
    for ii = 1 : ds
        for jj = whereToStart : dy
            % NaN-sentinel: after a column of terma is matched to a shock,
            % it is set to NaN (line below). isfinite detects unmatched
            % columns; a NaN column means that shock is already assigned.
            if isfinite(terma(1,jj))
                % Create CHECK matrix to check the signs
                if VARopt.sr_hor>1
                    CHECK = aux_irf(:,:,jj)';
                else
                    CHECK = terma(:,jj);
                end
                if sum(CHECK.* SIGN(:,ii) < 0) == 0
                    TermA = TermA + 1;
                    orderIndices(whereToStart-1+ii) = jj;
                    terma(:,jj) = nanMat;
                    break
                elseif sum(-CHECK.* SIGN(:,ii) < 0) == 0
                    TermA = TermA + 1;
                    terma(:,jj) = nanMat;
                    termaa(:,jj) = -termaa(:,jj);
                    orderIndices(ii+whereToStart-1) = jj;
                    break
                end
            end
        end
    end

    % All ds shocks matched: accept this rotation
    if isequal(TermA,ds)
        break
    end
end
if flag==0; B=termaa(:,orderIndices); else; B=[]; end
n_tried = counter - 1;
end
