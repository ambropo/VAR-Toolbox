function LP = LPmodel(ENDO, TREAT, CTRL, nlag, const, LPopt, EXOG, nlag_ex)
% =======================================================================
% Estimate local projections (LP) via OLS or LP-IV across horizons h=1,...,H
% =======================================================================
% LP = LPmodel(ENDO, TREAT, CTRL, nlag, const, LPopt, EXOG, nlag_ex)
% -----------------------------------------------------------------------
% LPmodel is univariate by construction: it projects one outcome at a time.
% ENDO may be a single column (nobs x 1) or a matrix (nobs x N). When ENDO
% has N>1 columns, the same univariate specification — identical TREAT (shock
% or treatment), controls CTRL, lags, deterministics, and LPopt (including
% LPopt.IV, the external instrument) — is
% looped over the N columns and the responses are assembled column-by-column
% so the output resembles VARmodel: IR/INF/SUP become (H x N) matrices and
% per-outcome detail is nested under .eq1,...,.eqN. With a single column the
% output is unchanged from previous versions (fully backward compatible).
% -----------------------------------------------------------------------
% INPUT
%   - ENDO:    dependent variable(s) (nobs x N); each column is projected
%              on the same shock/treatment and control set. N=1 reproduces
%              the classic univariate LP exactly.
%   - TREAT:   shock or endogenous treatment (nobs x 1), shared across cols
%              OLS mode (LPopt.IV=[]): TREAT is the shock entering directly.
%              IV mode (LPopt.IV non-empty): TREAT is the endogenous
%              treatment (e.g. the policy rate), instrumented by the external
%              instrument LPopt.IV. This matches the VARmodel/VARopt.IV
%              convention, where .IV always holds the external instrument.
%   - CTRL:    control variables (nobs x nctr), shared across all columns;
%              lags 1,...,nlag enter the regression. Unlike VARmodel, lags
%              of ENDO are NOT added automatically: include ENDO as columns
%              of CTRL to control for lagged outcomes (standard in LP). For
%              VAR-style output pass the full ENDO matrix as CTRL. Pass []
%              for no controls.
%   - nlag:    number of lags for CTRL (and common sample trim) [int >= 1]
%   - const:   0 = none; 1 = constant; 2 = constant+trend   [dflt = 1]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - LPopt:   LP options structure (see LPoption)           [dflt = LPoption]
%   - EXOG:    exogenous variables (nobs x nexog)            [dflt = none]
%              nlag_ex = 0: enter contemporaneously
%              nlag_ex > 0: enter with contemporaneous + lags 1,...,nlag_ex
%   - nlag_ex: lag order for EXOG                            [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - LP: structure with estimation results.
%       Top-level (always):
%         .ENDO, .TREAT, .CTRL, .EXOG, .nlag, .nlag_ex, .const, .ntotcoeff
%         .IR   impulse responses (H x N); column i = response of ENDO(:,i)
%         .INF  lower confidence band (H x N)
%         .SUP  upper confidence band (H x N)
%       Single outcome (N=1) — also at top level, as before:
%         .jtest_chi2, .jtest_df, .jtest_pval — joint Wald test H0: all b_h=0
%         .h1,...,.hH  per-horizon estimation results
%       Multiple outcomes (N>1) — per-outcome detail nested by name:
%         one sub-struct per column, each a full univariate LP struct for
%         ENDO(:,i) (its own .IR/.INF/.SUP column, .jtest_*, .h1,...,.hH).
%         Field names are taken from LPopt.vnames when these are N unique,
%         valid MATLAB identifiers not clashing with the fields above;
%         otherwise they default to .eq1,...,.eqN. (LPopt.vnames also labels
%         LPirplot panels and may contain spaces, in which case the eqN
%         default applies; IR/INF/SUP column order always matches ENDO.)
%     Per-horizon OLS fields (.hN):
%       .nobs, .beta, .tstat, .bstd, .bstd_HW, .bstd_NW, .tprob,
%       .resid, .yhat, .y, .x, .rsqr, .rbar, .dw, .sigma, .nlag_nw
%     Per-horizon IV fields (.hN):
%       .nobs, .beta, .se_iv, .nlag_nw, .Fstat_fs, .rsqr_fs,
%       .resid, .y, .D_hat
% -----------------------------------------------------------------------
% EXAMPLE
%   y = cumsum(randn(200,3)); s = randn(200,1); c = randn(200,3);
%   LP  = LPmodel(y, s, c, 4, 1);         % 3 outcomes, IR is 40 x 3
%   LP1 = LPmodel(y(:,1), s, c, 4, 1);    % single outcome (classic)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: November 2024. Updated: 2026-06-12
% -----------------------------------------------------------------------

% Default const: include constant
if nargin < 5 || isempty(const)
    const = 1;
end

% Default LPopt: use LPoption defaults
if nargin < 6 || isempty(LPopt)
    LPopt = LPoption;
end

% Default EXOG: no exogenous regressors
if nargin < 7 || isempty(EXOG)
    EXOG    = [];
    nlag_ex = 0;
elseif nargin < 8 || isempty(nlag_ex)
    nlag_ex = 0;
end

% Number of outcomes (columns of ENDO)
N = size(ENDO,2);

% Single outcome: dispatch to the univariate engine and return its output
% unchanged (fully backward compatible).
if N == 1
    LP = lp_single(ENDO, TREAT, CTRL, nlag, const, LPopt, EXOG, nlag_ex);
    return
end

% Multiple outcomes: the matrix path requires a common NaN-free sample
% across columns (the lag trim is shared, so a NaN anywhere in a column
% propagates into that column's projection). Guard explicitly.
nan_cols = find(any(isnan(ENDO),1));
if ~isempty(nan_cols)
    error('LPmodel: ENDO contains NaN in column(s) %s; matrix LP requires a NaN-free sample.', mat2str(nan_cols));
end

% Per-outcome field names. Use LPopt.mnem when supplied as N unique, valid
% MATLAB identifiers that do not collide with the top-level field names;
% otherwise fall back to eq1,...,eqN. mnem is the sole source for field
% names; LPopt.vnames (LPirplot panel labels, which may contain spaces) is
% never used here, and .IR/.INF/.SUP column order is unchanged.
reserved = {'ENDO','TREAT','CTRL','EXOG','nlag','nlag_ex','const','ntotcoeff','IR','INF','SUP','eqnames'};
vn = LPopt.mnem;
use_mnem = ~isempty(vn) && numel(vn)==N && ...
             all(cellfun(@(s) (ischar(s)||(isstring(s)&&isscalar(s))) && isvarname(char(s)), vn)) && ...
             numel(unique(cellfun(@char, vn, 'UniformOutput', false)))==N && ...
             ~any(ismember(cellfun(@char, vn, 'UniformOutput', false), reserved));
eqnames = cell(N,1);
for ii = 1:N
    if use_mnem
        eqnames{ii} = char(vn{ii});
    else
        eqnames{ii} = ['eq' num2str(ii)];
    end
end

% Loop the univariate specification over the N outcomes, holding TREAT, CTRL,
% nlag, const, LPopt (incl. LPopt.IV), EXOG, and nlag_ex fixed. Assemble
% IR/INF/SUP as (H x N) and nest per-outcome detail under eqnames{i}.
H   = LPopt.nsteps;
IR  = nan(H,N);
INF = nan(H,N);
SUP = nan(H,N);
ntotcoeff = NaN;
for ii = 1:N
    LPi          = lp_single(ENDO(:,ii), TREAT, CTRL, nlag, const, LPopt, EXOG, nlag_ex);
    IR(:,ii)     = LPi.IR;
    INF(:,ii)    = LPi.INF;
    SUP(:,ii)    = LPi.SUP;
    if ii == 1; ntotcoeff = LPi.ntotcoeff; end
    LP.(eqnames{ii}) = LPi;
end

% Record the resolved per-outcome field names so downstream code reads the
% sub-structs by the same labels (mirrors VAR.eqnames in VARmodel)
LP.eqnames   = eqnames;

% Top-level shared fields and assembled response matrices
LP.ENDO      = ENDO;
LP.TREAT     = TREAT;
LP.CTRL      = CTRL;
LP.EXOG      = EXOG;
LP.nlag      = nlag;
LP.nlag_ex   = nlag_ex;
LP.const     = const;
LP.ntotcoeff = ntotcoeff;
LP.IR        = IR;
LP.INF       = INF;
LP.SUP       = SUP;


function LP = lp_single(ENDO, TREAT, CTRL, nlag, const, LPopt, EXOG, nlag_ex)
% =======================================================================
% [Internal] Univariate LP engine: project a single outcome (nobs x 1) via
% OLS or LP-IV across horizons h=1,...,H. Called by LPmodel per outcome.
% =======================================================================

% Default const: include constant
if nargin < 5 || isempty(const)
    const = 1;
end

% Default LPopt: use LPoption defaults
if nargin < 6 || isempty(LPopt)
    LPopt = LPoption;
end

% Default EXOG: no exogenous regressors
if nargin < 7 || isempty(EXOG)
    EXOG    = [];
    nlag_ex = 0;
elseif nargin < 8 || isempty(nlag_ex)
    nlag_ex = 0;
end

%% 1. RETRIEVE AND INITIALIZE VARIABLES
% -----------------------------------------------------------------------
% Unpack scalar options from LPopt and set the IV mode flag.
impact   = LPopt.impact;
H        = LPopt.nsteps;
longdiff = LPopt.longdiff;
do_iv    = ~isempty(LPopt.IV);
nlag_iv  = LPopt.nlag_iv;

% Store inputs in LP for downstream access
LP.ENDO  = ENDO;
LP.TREAT = TREAT;
LP.CTRL  = CTRL;
LP.EXOG  = EXOG;

%% 2. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate conformability of all input arrays
[nobsENDO, ~]        = size(ENDO);
[nobsEXOG, nvarEXOG] = size(EXOG);
[nobsCTRL, nvarCTRL] = size(CTRL);
[nobsTREAT, ~]       = size(TREAT);

if nobsTREAT ~= nobsENDO
    error('LPmodel: TREAT has different number of observations from ENDO');
end
if nvarEXOG > 0 && nobsEXOG ~= nobsENDO
    error('LPmodel: EXOG has different number of observations from ENDO');
end
if nvarCTRL > 0 && nobsCTRL ~= nobsENDO
    error('LPmodel: CTRL has different number of observations from ENDO');
end
if do_iv && size(LPopt.IV,1) ~= nobsENDO
    error('LPmodel: LPopt.IV has different number of observations from ENDO');
end

% nlag must be at least 1 to avoid CTRL entering contemporaneously with TREAT
if nlag < 1
    error('LPmodel: nlag must be >= 1');
end

%% 3. SAVE PARAMETERS AND CREATE DATA MATRICES
% -----------------------------------------------------------------------
% lag_trim is the common leading trim: max(nlag, nlag_ex). With nlag_ex=0
% (default), lag_trim = nlag. All input series are trimmed to rows
% 1+lag_trim:nobs so that lagged CTRL and EXOG matrices align.
lag_trim = max(nlag, nlag_ex);

% Trim ENDO and TREAT to the lag-trimmed sample
endo = ENDO(1+lag_trim:end,1);
s    = TREAT(1+lag_trim:end,1);

% Build lagged CTRL matrix: CTRL enters with lags 1,...,nlag.
% VARmakexy is called with const=0; deterministics are handled separately.
% When lag_trim > nlag, extra top rows are dropped to align with the trim.
if nvarCTRL > 0
    [~, auxX]  = VARmakexy(CTRL, nlag, 0);
    if lag_trim > nlag
        ctrl_lags = auxX(lag_trim-nlag+1:end,:);
    else
        ctrl_lags = auxX;
    end
else
    ctrl_lags = [];
end

% Build EXOG matrix: contemporaneous (nlag_ex=0) or with lags.
% VARmakelags(EXOG, nlag_ex) returns nobs-nlag_ex rows with columns
% [EXOG(t), EXOG(t-1), ..., EXOG(t-nlag_ex)]; extra top rows are trimmed
% to align with the lag_trim sample.
if nvarEXOG > 0
    X_EX     = VARmakelags(EXOG, nlag_ex);
    extra    = lag_trim - nlag_ex;
    exog_mat = X_EX(1+extra:end,:);
else
    exog_mat = [];
end

% In IV mode TREAT is the endogenous treatment and LPopt.IV the external
% instrument (matching the VARopt.IV convention). The trimmed treatment is
% just s (TREAT over the lag-trimmed sample); the instrument is used at full
% length when building the lagged Z matrix below.
if do_iv
    treat = s;
end

% Deterministic component: const=0 (none), 1 (constant), 2 (constant+trend)
if const > 2
    error('LPmodel: const must be 0, 1, or 2 (got %d)', const);
end
nT_trim = length(endo);
if const == 0
    detc = [];
elseif const == 1
    detc = ones(nT_trim,1);
else
    detc = [ones(nT_trim,1), (1:nT_trim)'];
end

% Control matrix for FWL: deterministics + EXOG (with lags) + lagged CTRL
controls = [detc, exog_mat, ctrl_lags];

% Total regressors: shock (1) + controls
ntotcoeff = 1 + size(controls,2);

LP.nlag      = nlag;
LP.nlag_ex   = nlag_ex;
LP.const     = const;
LP.ntotcoeff = ntotcoeff;

% Shock normalisation: OLS standardises TREAT; IV normalises the treatment D
if ~do_iv
    if impact == 0
        shock = zscore(s);
    elseif impact == 1
        shock = s;
    else
        error('LPmodel: impact must be 0 or 1');
    end
    d_norm = 1;
else
    % IV mode: normalisation applies to the endogenous treatment (TREAT = treat)
    if impact == 0
        d_norm = std(treat);
    elseif impact == 1
        d_norm = 1;
    else
        error('LPmodel: impact must be 0 or 1');
    end
end

% OLS RHS matrix (IV builds its own RHS via FWL at each horizon)
if ~do_iv
    LHS = endo;
    RHS = [shock, controls];
else
    LHS = endo;
end

% Long-difference: pre-align ENDO_{t-1} with the lag-trimmed sample
if longdiff
    endo_lag1 = ENDO(lag_trim:end-1,1);
end

% 3.1. Validate IV options
% -----------------------------------------------------------------------
% nlag_iv instrument lags use LPopt.IV from the pre-trimmed window;
% nlag_iv <= nlag ensures those values fall within LPopt.IV.
if do_iv
    if nlag_iv > nlag
        error('LPmodel: nlag_iv must be <= nlag');
    end
end

%% 4. OLS OR IV ESTIMATION AT EACH PROJECTION HORIZON
% -----------------------------------------------------------------------
% Pre-allocate output arrays and balanced-sample storage for the joint Wald
% test (common to OLS and IV), then loop over horizons h=1,...,H.
IR  = nan(H,1);
INF = nan(H,1);
SUP = nan(H,1);
conf = norminv(1 - (1-LPopt.pctg/100)/2);

% Balanced sample: common to all H equations for the joint Wald test
n_bal = max(nT_trim - H + 1, 1);
G_bal = zeros(n_bal, H);   % per-horizon scores
C_jt  = zeros(H, 1);       % per-horizon denominator

% Initialise joint-test fields (overwritten in §5 when computable)
LP.jtest_chi2 = nan;
LP.jtest_df   = nan;
LP.jtest_pval = nan;

for hh = 1:H

    hname = ['h' num2str(hh)];   % dynamic field name for LP at this horizon

    % Construct LHS: level or long-difference relative to t-1
    Y_lead = LHS(hh:end);
    if longdiff
        Y_base = endo_lag1(1:length(Y_lead));
        Y = Y_lead - Y_base;
    else
        Y = Y_lead;
    end
    n_h = length(Y);

    if ~do_iv
        %% 4.1. OLS estimation
        % ---------------------------------------------------------------
        % Trim X to the horizon-specific sample and estimate via OLS.
        % NW bandwidth = h-1: LP residuals are MA(h-1) by construction.
        X      = RHS(1:n_h,:);
        OLSout = OLSmodel(Y,X,0,hh-1);

        % Store OLS results for this horizon
        LP.(hname).nobs    = n_h;
        LP.(hname).beta    = OLSout.beta;
        LP.(hname).tstat   = OLSout.tstat;
        LP.(hname).bstd    = OLSout.bstd;
        LP.(hname).bstd_HW = OLSout.bstd_HW;
        LP.(hname).bstd_NW = OLSout.bstd_NW;
        tout = tdis_prb(OLSout.tstat, n_h-ntotcoeff);
        LP.(hname).tprob   = tout;
        LP.(hname).resid   = OLSout.resid;
        LP.(hname).yhat    = OLSout.yhat;
        LP.(hname).y       = Y;
        LP.(hname).x       = X;
        LP.(hname).rsqr    = OLSout.rsqr;
        LP.(hname).rbar    = OLSout.rbar;
        LP.(hname).dw      = OLSout.dw;
        LP.(hname).sigma   = OLSout.sige;
        LP.(hname).nlag_nw = hh-1;

        % Extract impulse response and NW confidence bands
        IR(hh,1)  = OLSout.beta(1);
        INF(hh,1) = IR(hh) - conf*OLSout.bstd_NW(1);
        SUP(hh,1) = IR(hh) + conf*OLSout.bstd_NW(1);

        % FWL-residualized shock for joint Wald test scores.
        % By FWL, OLSout.resid equals the residuals from regressing
        % M_C*Y on M_C*shock, so score = r_shock_h .* OLSout.resid.
        if ~isempty(controls)
            C_h       = controls(1:n_h,:);
            r_shock_h = shock(1:n_h) - C_h*(C_h\shock(1:n_h));
        else
            r_shock_h = shock(1:n_h);
        end
        if n_h >= n_bal
            G_bal(1:n_bal, hh) = r_shock_h(1:n_bal) .* OLSout.resid(1:n_bal);
            C_jt(hh)           = (r_shock_h'*r_shock_h)/n_h;
        end

    else
        %% 4.2. LP-IV via horizon-by-horizon 2SLS
        % ---------------------------------------------------------------
        % All FWL is done within the horizon-specific n_h sample so that
        % point estimates exactly match Stata's per-horizon ivreghdfe
        % (Frisch-Waugh equivalence). For horizon h:
        %   1. FWL Y_h, D, and Z (with nlag_iv lags) on C_h = controls(1:n_h)
        %   2. Project r_d_h onto instrument space R_Z_h (first stage)
        %   3. 2SLS coefficient and NW HAC SE via delta-method sandwich
        %
        % The instrument matrix uses the original LPopt.IV vector for lag-k of Z:
        % LPopt.IV(1+lag_trim-k : lag_trim+n_h-k), valid when nlag_iv <= nlag <= lag_trim.
        % NW bandwidth is fixed at nlag_iv for overidentified IV (matching
        % Stata vce(hac nw nlag_iv)); for just-identified IV, bandwidth = h-1.

        % Horizon-specific controls and FWL of Y_h
        if ~isempty(controls)
            C_h   = controls(1:n_h,:);
            r_y_h = Y - C_h*(C_h\Y);
        else
            C_h   = [];
            r_y_h = Y;
        end

        % Per-horizon FWL of treatment D (TREAT over the horizon-h sample)
        D_h = treat(1:n_h);
        if ~isempty(C_h)
            r_d_h = D_h - C_h*(C_h\D_h);
        else
            r_d_h = D_h;
        end

        % Build and FWL the instrument matrix: n_h x (nlag_iv+1).
        % Column k+1 = lag-k of the instrument LPopt.IV over the trimmed window.
        Z_raw = zeros(n_h, nlag_iv+1);
        for k = 0:nlag_iv
            Z_raw(:, k+1) = LPopt.IV(1+lag_trim-k : lag_trim+n_h-k, 1);
        end
        if ~isempty(C_h)
            R_Z_h = Z_raw - C_h*(C_h\Z_raw);
        else
            R_Z_h = Z_raw;
        end

        % First stage: project r_d_h onto the instrument space
        D_hat_h = R_Z_h*(R_Z_h\r_d_h);

        % First-stage F-statistic (joint significance of all instruments)
        FS_out   = OLSmodel(r_d_h,R_Z_h,0);
        RSS_res  = r_d_h'*r_d_h;
        RSS_unr  = FS_out.resid'*FS_out.resid;
        k_z      = size(R_Z_h,2);
        Fstat_fs = ((RSS_res - RSS_unr)/k_z) / (RSS_unr/(n_h - k_z));

        % 2SLS point estimate and IV residual
        denom_h = D_hat_h'*r_d_h;
        beta_h  = (D_hat_h'*r_y_h)/denom_h;
        eps_h   = r_y_h - beta_h*r_d_h;

        % NW HAC SE via delta-method IV sandwich.
        % Bandwidth: nlag_iv (fixed, matching Stata vce(hac nw nlag_iv))
        % or h-1 for just-identified IV (nlag_iv=0).
        if nlag_iv > 0
            bw_h = nlag_iv;
        else
            bw_h = max(hh-1, 0);
        end
        g_h   = D_hat_h.*eps_h;
        g_ols = OLSmodel(g_h, ones(n_h,1), 0, bw_h);
        se_h  = g_ols.bstd_NW(1)/abs(denom_h/n_h);

        % Store scores for joint Wald test (balanced sample, before scaling)
        if n_h >= n_bal
            G_bal(1:n_bal, hh) = D_hat_h(1:n_bal).*eps_h(1:n_bal);
            C_jt(hh)           = denom_h/n_h;
        end

        % Scale to a d_norm-sized shock in the treatment D
        beta_h = beta_h*d_norm;
        se_h   = se_h*d_norm;

        % Store 2SLS results for this horizon
        LP.(hname).nobs     = n_h;
        LP.(hname).beta     = beta_h;
        LP.(hname).se_iv    = se_h;
        LP.(hname).nlag_nw  = bw_h;
        LP.(hname).Fstat_fs = Fstat_fs;
        LP.(hname).rsqr_fs  = FS_out.rsqr;
        LP.(hname).resid    = eps_h;
        LP.(hname).y        = Y;
        LP.(hname).D_hat    = D_hat_h;

        % Extract impulse response and NW confidence bands
        IR(hh,1)  = beta_h;
        INF(hh,1) = beta_h - conf*se_h;
        SUP(hh,1) = beta_h + conf*se_h;
    end
end

%% 5. JOINT WALD TEST H0: b_1 = ... = b_H = 0
% -----------------------------------------------------------------------
% Wald test using the cross-horizon NW long-run covariance of the per-
% horizon scores, evaluated over the balanced sample (first n_bal obs
% common to all H equations). The chi2(H) statistic is asymptotically
% valid under the same HAC assumptions as the per-horizon SEs.
%
% OLS scores:  g_{h,t} = r_shock_h(t) * eps_h(t);  C_jt(h) = E[r_shock^2]
% IV  scores:  g_{h,t} = D_hat_h(t) * eps_h(t);    C_jt(h) = E[D_hat*r_d]
%
% Wald statistic: n_bal * (C.*b)' * Sigma^{-1} * (C.*b) ~ chi2(H)
% NW bandwidth: nlag for OLS, nlag_iv for IV
if n_bal >= 2 && all(C_jt ~= 0)
    if do_iv
        bw_jt = nlag_iv;
    else
        bw_jt = nlag;
    end

    % NW long-run covariance matrix of scores (H x H)
    Sigma = G_bal'*G_bal/n_bal;
    for lag = 1:bw_jt
        w_l    = 1 - lag/(bw_jt+1);   % Bartlett weight
        Gcross = G_bal(lag+1:end,:)'*G_bal(1:end-lag,:)/n_bal;
        Sigma  = Sigma + w_l*(Gcross + Gcross');
    end

    % Wald statistic (d_norm cancels for IV: chi2 is scale-invariant)
    if do_iv
        b_unscaled = IR/d_norm;
    else
        b_unscaled = IR;
    end
    scaled_b = C_jt.*b_unscaled;
    chi2_val = n_bal*(scaled_b'*(Sigma\scaled_b));
    df_val   = H;
    pval_val = gammainc(chi2_val/2, df_val/2, 'upper');

    LP.jtest_chi2 = chi2_val;
    LP.jtest_df   = df_val;
    LP.jtest_pval = pval_val;
end

% Store IR, INF, SUP as top-level fields for convenient access
LP.IR  = IR;
LP.INF = INF;
LP.SUP = SUP;
