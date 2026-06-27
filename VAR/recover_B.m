function [B, VAR] = recover_B(VAR, VARopt)
% =====================================================================
% Recover the structural impact matrix B from the reduced-form VCV under
% the identification scheme specified in VARopt.ident.
% =====================================================================
% [B, VAR] = recover_B(VAR, VARopt)
% ---------------------------------------------------------------------
% INPUT
%   - VAR:    structure, result of VARmodel OLS estimation
%   - VARopt: options structure; relevant fields:
%               VARopt.ident = 'short' | 'long' | 'iv' | 'exog'
%               VARopt.IV            = instrument matrix (required for ident='iv')
%               VARopt.exoshock      = exogenous shock variable (required for ident='exog')
%               VARopt.nlag_exoshock = lag order for exoshock [dflt = 0]
% ---------------------------------------------------------------------
% OUTPUT
%   - B:   (nvar x nvar) structural impact matrix
%   - VAR: updated with .FirstStage, .sigma_b (iv only)
% ---------------------------------------------------------------------
% EXAMPLE
%   VAR.sigma = [1 0.5; 0.5 1]; VAR.nvar = 2; VARopt.ident = 'short';
%   VAR.Fcomp = zeros(2); [B, VAR] = recover_B(VAR, VARopt);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-06-01
% ---------------------------------------------------------------------

%% 1. UNPACK PARAMETERS
% ---------------------------------------------------------------------
% Extract the identification label, reduced-form VCV, companion matrix,
% and cross-section dimension from the input structures.
ident = VARopt.ident;
sigma = VAR.sigma;
Fcomp = VAR.Fcomp;
nvar  = VAR.nvar;

%% 2. RECOVER B
% ---------------------------------------------------------------------
% Dispatch to the appropriate identification routine based on VARopt.ident.
if strcmp(ident,'short')
    % Cholesky decomposition: zero contemporaneous restrictions
    [out, chol_flag] = chol(sigma);
    if chol_flag ~= 0; error('VCV is not positive definite'); end
    B = out';
elseif strcmp(ident,'long')
    % Long-run Cholesky: zero long-run restrictions (Blanchard-Quah)
    Finf_big = inv(eye(length(Fcomp)) - Fcomp);
    Finf     = Finf_big(1:nvar, 1:nvar);
    D        = chol(Finf*sigma*Finf')';
    B        = Finf \ D;
elseif strcmp(ident,'iv')
    % External instrument (proxy SVAR): two-stage regression approach.
    % The instrument must be supplied in VARopt.IV. The first variable
    % in ENDO is the one instrumented; ordering matters.
    IV = VARopt.IV;
    up = VAR.resid(:,1);
    uq = VAR.resid(:,2:end);

    % Align instrument sample with the residual sample
    [aux, ~, ~] = CommonSample([up IV(VAR.nlag+1:end,:)]);
    p    = aux(:,1);
    q    = uq(end-length(p)+1:end,:);
    pq   = [p q];
    Z_iv = aux(:,2:end);

    % First stage: project instrumented residual onto IV
    FirstStage = OLSmodel(p, Z_iv);
    p_hat      = FirstStage.yhat;

    % Second stage: recover ratios of structural impact coefficients
    Biv    = zeros(nvar, 1);
    Biv(1) = 1;
    sqsp   = zeros(size(q,2), 1);
    for ii = 2:nvar
        SecondStage = OLSmodel(q(:,ii-1), p_hat);
        Biv(ii)     = SecondStage.beta(2);
        sqsp(ii-1)  = SecondStage.beta(2);
    end

    % Normalize by shock size (Gertler-Karadi 2015, footnote 4)
    sigma_b = (1/(length(pq)-VAR.ntotcoeff)) * ...
        (pq-repmat(mean(pq),size(pq,1),1))' * ...
        (pq-repmat(mean(pq),size(pq,1),1));
    s21s11 = sqsp;
    S11    = sigma_b(1,1);
    S21    = sigma_b(2:end,1);
    S22    = sigma_b(2:end,2:end);
    Q      = s21s11*S11*s21s11' - (S21*s21s11' + s21s11*S21') + S22;
    sp     = sqrt(S11 - (S21-s21s11*S11)'*(Q\(S21-s21s11*S11)));
    Biv    = Biv * sp * sign(FirstStage.beta(2));

    % Only column 1 (b_1 = Biv) is IV-identified. complete_B fills columns 2:n
    % with a Cholesky-QR completion so that B is invertible for compute_HD (the
    % structural-shock backout eps = B\u requires a full-rank B). The completion
    % carries no economic content: its IRF/VD/HD contributions are zeroed and the
    % stored VAR.B has zeros in columns 2:n (see VARmodel). The completion is used
    % only internally, before that zeroing, to recover the shock-1 series.
    B = complete_B(Biv, sigma, nvar);
    VAR.FirstStage = FirstStage;
    VAR.sigma_b    = sigma_b;
elseif strcmp(ident,'exog')
    % Exogenous variable: first column of B scaled to a one-std-dev shock.
    % exoshock is always prepended as the first exogenous block in VARmodel,
    % so its contemporaneous coefficient sits at column const+ncoeff+1 of VAR.F.
    % As in the 'iv' case, only column 1 is identified; complete_B fills the
    % remaining columns with a numerical completion (invertible B for compute_HD),
    % which is zeroed in VARmodel so the stored VAR.B shows only the identified
    % column. The exog and iv schemes are therefore handled identically here.
    exo    = VARopt.exoshock;
    b1     = VAR.F(:, VAR.const+VAR.ncoeff+1) * std(exo(~isnan(exo)));
    B      = complete_B(b1, sigma, nvar);
else
    error(['recover_B: ident = ''' ident ''' not recognised. ' ...
        'Choose: short, long, iv, exog.']);
end

end % recover_B

%% LOCAL FUNCTIONS
% =====================================================================
function B = complete_B(b1, sigma, nvar)
% Complete a single identified impact column b1 to a full invertible B via
% Cholesky-QR, so that B*B' = sigma exactly and B(:,1) = b1 exactly. Columns
% 2:n are an orthonormal completion with no economic interpretation; they
% exist only to make B invertible (e.g. for the eps = B\u backout in
% compute_HD). norm(P\b1) is approximately but not exactly 1 when b1 is not
% drawn from sigma (the IV/exog impact uses a different sample than sigma), so
% q1 is normalized defensively before the orthonormal completion.
P  = chol(sigma)';           % lower-triangular Cholesky factor: P*P' = sigma
q1 = P \ b1;                 % express b1 in Cholesky basis (approximately unit)
q1 = q1 / norm(q1);          % normalize defensively
[Q, ~] = qr([q1, eye(nvar)]);% complete q1 to orthonormal basis Q
if Q(:,1)' * q1 < 0          % ensure Q(:,1) = q1, not -q1
    Q(:,1) = -Q(:,1);
end
B      = P * Q;              % B*B' = P*Q*Q'*P' = P*P' = sigma (exactly)
B(:,1) = b1;                 % restore exact b_1 to preserve IRFs for shock 1
end
