function VAR = VARmodel(ENDO, nlag, const, VARopt, EXOG, nlag_ex)
% =======================================================================
% Estimate a VAR model with OLS and, optionally, identify structural
% shocks and compute impulse responses, variance decompositions, and
% historical decompositions — with or without bootstrap inference.
% =======================================================================
% VAR = VARmodel(ENDO, nlag, const, VARopt, EXOG, nlag_ex)
% -----------------------------------------------------------------------
% INPUT
%   - ENDO:   (nobs x nvar) matrix of endogenous variables
%   - nlag:   lag length
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - const:  0 no constant; 1 constant; 2 constant+trend [dflt = 1]
%   - VARopt: options structure from VARoption [dflt = VARoption]
%             Key fields controlling this function:
%               VARopt.ident     = '' | 'short' | 'long' | 'sign' | 'sign+iv' | 'iv' | 'exog'
%               VARopt.inference = 0 (point estimates only) | 1 (bootstrap bands)
%               VARopt.IV            = instrument matrix (required for ident='iv')
%               VARopt.exoshock      = exogenous shock variable (required for
%                                      ident='exog'); nobs x 1 vector
%               VARopt.nlag_exoshock = lag order for exoshock [dflt = 0]
%               VARopt.R             = sign restriction matrix or struct
%                                      (required for ident='sign' or 'sign+iv'); see SR.m
%   - EXOG:   (nobs x nvar_ex) matrix of additional exogenous regressors
%             [dflt = none]; distinct from VARopt.exoshock
%   - nlag_ex: lag order for EXOG regressors [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - VAR: structure with OLS estimates and, depending on VARopt settings:
%       Always present (OLS):
%         .ENDO, .nlag, .nvar, .nobs, .nvar_ex, .nlag_ex, .const
%         .Ft, .F, .sigma, .resid, .X, .Y
%         .Fcomp, .maxEig
%         .eq1 ... .eqN  (equation-by-equation OLS results)
%       When ident = 'short'|'long'|'iv'|'exog' (point-identified):
%         .B              structural impact matrix (nvar x nvar)
%         .IR             point IRF  (nsteps x nvar x nvar)
%         .VD             point FEVD (nsteps x nvar x nvar); for ident='iv',
%                           VD(:,2:end,:) = 0 (only shock 1 is identified)
%         .HD             point HD struct; fields:
%                           .shock  (nobs+nlag x nvar x nvar)
%                             dim2=shock j, dim3=variable i:
%                             HD.shock(:,j,i) = contribution of shock j
%                             to variable i over the sample
%                           .init   (nobs+nlag x nvar) — initial conditions
%                           .const  (nobs+nlag x nvar) — constant term
%                           .trend  (nobs+nlag x nvar) — linear trend
%                           .exo    (nobs+nlag x nvar x nvar_ex) — exog.
%                           .exoshock (nobs+nlag x nvar) — observed exog.
%                             shock regressor block (ident='exog'; else 0)
%                           .endo   (nobs+nlag x nvar) — observed data
%                             (sum of all components; equals ENDO after lags)
%                         First nlag rows NaN (lag-period padding).
%       When inference = 1 (point-identified + bootstrap):
%         .IRall          IRF draws  (nsteps x nvar x nvar x ndraws)
%         .IRbar          bootstrap mean IRF (replaces old IRmed)
%         .IRinf, .IRsup  percentile bands
%         .VDall, .VDbar, .VDinf, .VDsup  (same convention)
%         .HDall          struct (same field layout as .HD, plus draw dim):
%                           .shock  (nobs+nlag x nvar x nvar x ndraws)
%                           .init   (nobs+nlag x nvar x ndraws)
%                           .const  (nobs+nlag x nvar x ndraws)
%                           .trend  (nobs+nlag x nvar x ndraws)
%                           .exo    (nobs+nlag x nvar x nvar_ex x ndraws)
%                           .exoshock (nobs+nlag x nvar x ndraws)
%                           .endo   (nobs+nlag x nvar x ndraws)
%                         (compute_HD does not produce trend2; no such field)
%         .HDbar          full HD struct, bootstrap mean of all components
%         .HDinf, .HDsup  full HD structs, percentile bands on all components
%       When ident = 'sign'|'sign+iv' (set-identified, always distributional):
%         .Bfp            Fry-Pagan structural impact matrix
%         .IRfp           IRF from Fry-Pagan draw (nsteps x nvar x nvar)
%         .VDfp           FEVD from Fry-Pagan draw (nsteps x nvar x nvar)
%         .HDfp           HD struct from Fry-Pagan draw (full, all components)
%         .Ball, .Bmed    all accepted B matrices; element-wise median B
%         .IRall, .IRmed, .IRinf, .IRsup
%         .VDall, .VDmed, .VDinf, .VDsup
%         .HDall          full HD struct over accepted draws (from SR.m)
%         .HDmed          full HD struct; shock = element-wise median across
%                           accepted draws; other components = OLS point est.
%         .HDinf, .HDsup  full HD structs; shock = percentile bands;
%                           other components = OLS point est.
% -----------------------------------------------------------------------
% EXAMPLE
%   ENDO = randn(120,3);
%   VARopt = VARoption; VARopt.ident = 'short'; VARopt.nsteps = 20;
%   VAR = VARmodel(ENDO, 2, 1, VARopt);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-06-01
% -----------------------------------------------------------------------

%% 1. PARSE INPUTS
% -----------------------------------------------------------------------
[nobs, nvar] = size(ENDO);

% Default: constant included
if nargin < 3 || isempty(const)
    const = 1;
end
if ~isscalar(const) || ~ismember(const, [0 1 2])
    error('VARmodel: const must be 0, 1, or 2 (got %s)', mat2str(const));
end

% Default VARopt: call VARoption if not supplied
if nargin < 4 || isempty(VARopt)
    VARopt = VARoption;
end

% R for sign restrictions: read from VARopt
if isfield(VARopt, 'R')
    R = VARopt.R;
else
    R = [];
end

% Guard: R is mandatory for sign restrictions
if (strcmp(VARopt.ident,'sign') || strcmp(VARopt.ident,'sign+iv')) && isempty(R)
    error('VARmodel: VARopt.R (sign restriction matrix or struct) is required when VARopt.ident = ''sign'' or ''sign+iv''.');
end

% Guard: VARopt.IV is mandatory for iv identification
if strcmp(VARopt.ident,'iv') && isempty(VARopt.IV)
    error('VARmodel: VARopt.IV must be set when VARopt.ident = ''iv''.');
end

% Guard: VARopt.IV is mandatory for sign+iv identification
if strcmp(VARopt.ident,'sign+iv') && isempty(VARopt.IV)
    error('VARmodel: VARopt.IV must be set when VARopt.ident = ''sign+iv''.');
end

% Guard: VARopt.exoshock is mandatory for exog identification
if strcmp(VARopt.ident,'exog') && isempty(VARopt.exoshock)
    error('VARmodel: VARopt.exoshock must be set when VARopt.ident = ''exog''.');
end

% Default exogenous variables: none
if nargin < 5 || isempty(EXOG)
    EXOG    = [];
    nvar_ex = 0;
    nlag_ex = 0;
else
    [nobs2, nvar_ex] = size(EXOG);
    if nobs2 ~= nobs
        error('VARmodel: nobs in EXOG does not match ENDO.');
    end
    if nargin < 6 || isempty(nlag_ex)
        nlag_ex = 0;
    end
end

% Parse exoshock from VARopt (used for ident='exog')
exoshock = VARopt.exoshock;
nlag_es  = VARopt.nlag_exoshock;
if ~isempty(exoshock)
    if numel(exoshock) ~= nobs
        error('VARmodel: length of VARopt.exoshock (%d) does not match ENDO (%d).', numel(exoshock), nobs);
    end
    if nlag_es > nlag
        error('VARmodel: VARopt.nlag_exoshock (%d) cannot exceed nlag (%d).', nlag_es, nlag);
    end
    ncoeff_es = nlag_es + 1;  % contemporaneous + lags
else
    ncoeff_es = 0;
end

% Store basic dimensions
VAR.ENDO      = ENDO;
VAR.nlag      = nlag;
VAR.const     = const;
VAR.EXOG      = EXOG;
VAR.nvar      = nvar;
VAR.nvar_ex   = nvar_ex;
VAR.nlag_ex   = nlag_ex;
VAR.ncoeff_es = ncoeff_es;

%% 2. OLS ESTIMATION
% -----------------------------------------------------------------------
% Effective sample size after accounting for lags
nobse         = nobs - max(nlag, nlag_ex);
VAR.nobs      = nobse;
ncoeff        = nvar * nlag;
VAR.ncoeff    = ncoeff;
ncoeff_ex     = nvar_ex * (nlag_ex + 1);
ntotcoeff     = ncoeff + ncoeff_es + ncoeff_ex + const;
VAR.ntotcoeff = ntotcoeff;

% Build left-hand-side vector Y and regressor matrix X (lagged endo + deterministics)
[Y, X] = VARmakexy(ENDO, nlag, const);

% Append exoshock block before general EXOG so its contemporaneous coefficient
% always sits at column const+ncoeff+1 in VAR.F (required by recover_B).
% VARmakelags puts contemporaneous values first; nlag_es <= nlag is enforced
% by the guard above, so we only ever need to trim rows from the top.
if ~isempty(exoshock)
    X_ES = VARmakelags(exoshock, nlag_es);
    if nlag > nlag_es
        X_ES = X_ES(nlag - nlag_es + 1 : end, :);
    end
    X = [X X_ES];
    VAR.X_ES = X_ES;
end

% Append lagged exogenous variables if present, aligning samples
if nvar_ex > 0
    X_EX = VARmakelags(EXOG, nlag_ex);
    if nlag == nlag_ex
        X = [X X_EX];
    elseif nlag > nlag_ex
        diff = nlag - nlag_ex;
        X_EX = X_EX(diff+1:end,:);
        X = [X X_EX];
    else
        diff = nlag_ex - nlag;
        Y = Y(diff+1:end,:);
        X = [X(diff+1:end,:) X_EX];
    end
    VAR.X_EX = X_EX;
end

% Per-equation field names: use VARopt.mnem when supplied as nvar unique,
% valid MATLAB identifiers that do not collide with the top-level field
% names; otherwise fall back to eq1,...,eqN (mirrors LPmodel). mnem is the
% sole source for field names; VARopt.vnames (display labels, which may
% contain spaces) is never used here. The resolved names are stored in
% VAR.eqnames so downstream code (e.g. VARprint) reads the equations by the
% same labels.
reserved = {'ENDO','nlag','const','EXOG','nvar','nvar_ex','nlag_ex','ncoeff_es', ...
    'nobs','ncoeff','ntotcoeff','Ft','F','sigma','resid','X','Y','X_ES','X_EX', ...
    'Fcomp','maxEig','B','PSI','Fp','IR','VD','HD','ident','eqnames', ...
    'IRall','IRbar','IRmed','IRinf','IRsup','VDall','VDbar','VDmed','VDinf','VDsup', ...
    'HDall','HDbar','HDmed','HDinf','HDsup','Bfp','IRfp','VDfp','HDfp', ...
    'Ball','Bmed','accept_rate','ndraws_tried'};
vn = VARopt.mnem;
use_mnem = ~isempty(vn) && numel(vn)==nvar && ...
    all(cellfun(@(s) (ischar(s)||(isstring(s)&&isscalar(s))) && isvarname(char(s)), vn)) && ...
    numel(unique(cellfun(@char, vn, 'UniformOutput', false)))==nvar && ...
    ~any(ismember(cellfun(@char, vn, 'UniformOutput', false), reserved));
eqnames = cell(nvar,1);
for j = 1:nvar
    if use_mnem
        eqnames{j} = char(vn{j});
    else
        eqnames{j} = ['eq' num2str(j)];
    end
end
VAR.eqnames = eqnames;

% Equation-by-equation OLS; results stored in VAR.(eqnames{j}), i.e.
% VAR.eq1 ... VAR.eqN unless VARopt.vnames supplies valid field names
for j = 1:nvar
    Yvec   = Y(:,j);
    OLSout = OLSmodel(Yvec, X, 0);
    aux    = eqnames{j};
    VAR.(aux).beta  = OLSout.beta;
    VAR.(aux).tstat = OLSout.tstat;
    VAR.(aux).bstd  = OLSout.bstd;
    VAR.(aux).tprob = tdis_prb(OLSout.tstat, nobse - ntotcoeff);
    VAR.(aux).resid = OLSout.resid;
    VAR.(aux).yhat  = OLSout.yhat;
    VAR.(aux).y     = Yvec;
    VAR.(aux).rsqr  = OLSout.rsqr;
    VAR.(aux).rbar  = OLSout.rbar;
    VAR.(aux).sige  = OLSout.sige;
    VAR.(aux).dw    = OLSout.dw;
end

% Stack OLS estimates: Ft is (ntotcoeff x nvar), F is (nvar x ntotcoeff)
Ft        = (X'*X) \ (X'*Y);
VAR.Ft    = Ft;
VAR.F     = Ft';

% Degrees-of-freedom-adjusted VCV
SIGMA     = (1/(nobse-ntotcoeff)) * (Y-X*Ft)' * (Y-X*Ft);
VAR.sigma = SIGMA;
VAR.resid = Y - X*Ft;
VAR.X     = X;
VAR.Y     = Y;

%% 3. COMPANION MATRIX
% -----------------------------------------------------------------------
% Build the nvar*nlag companion form to assess stationarity
F     = Ft';
Fcomp = [F(:,1+const:nvar*nlag+const); eye(nvar*(nlag-1)) zeros(nvar*(nlag-1),nvar)];
VAR.Fcomp  = Fcomp;
VAR.maxEig = max(abs(eig(Fcomp)));

% Initialize structural fields populated by sections below
VAR.B   = [];
VAR.PSI = [];
VAR.Fp  = [];
VAR.IR  = [];
VAR.VD  = [];
VAR.HD  = [];
VAR.ident = VARopt.ident;

%% 4. IDENTIFICATION AND POINT ESTIMATES
% -----------------------------------------------------------------------
% Skip if ident is empty: return reduced-form estimates only
if isempty(VARopt.ident)
    return
end

% Guard: reject unrecognised identification schemes early
valid_ident = {'short', 'long', 'sign', 'sign+iv', 'iv', 'exog'};
if ~any(strcmp(VARopt.ident, valid_ident))
    error('VARmodel: VARopt.ident = ''%s'' is not recognised. Choose: %s.', ...
        VARopt.ident, strjoin(valid_ident, ', '));
end

% Two identification paths: sign restrictions (set-identified, handled by
% SR.m which runs its own rotation-draw loop and returns distributional
% output) versus all other schemes (point-identified, via recover_B then
% the Wold + IRF pipeline). Bootstrap inference in section 5 applies only
% to the non-sign path; sign restrictions return here. The sign+iv scheme
% follows the sign path but pre-populates VAR.B(:,1) via an IV stage first.
if strcmp(VARopt.ident, 'sign') || strcmp(VARopt.ident, 'sign+iv')

    % For sign+iv: run IV stage first to populate VAR.B(:,1) and VAR.sigma_b,
    % which SignRestrictions uses to condition the rotation on the IV column.
    if strcmp(VARopt.ident, 'sign+iv')
        VARopt_iv       = VARopt;
        VARopt_iv.ident = 'iv';
        [B_iv, VAR] = recover_B(VAR, VARopt_iv);
        VAR.B = B_iv;
    end

    % Delegate to SR.m which handles draws, rotation, and distributional output
    SRout = SR(VAR, R, VARopt);

    % Fry-Pagan draw (accepted draw with B closest to Bmed)
    VAR.Bfp  = SRout.Bfp;
    VAR.IRfp = SRout.IRfp;
    VAR.VDfp = SRout.VDfp;
    VAR.HDfp = SRout.HDfp;

    % Distribution over accepted draws
    VAR.Ball  = SRout.Ball;
    VAR.Bmed  = SRout.Bmed;
    VAR.IRall = SRout.IRall;
    VAR.IRmed = SRout.IRmed;
    VAR.IRinf = SRout.IRinf;
    VAR.IRsup = SRout.IRsup;
    VAR.VDall = SRout.VDall;
    VAR.VDmed = SRout.VDmed;
    VAR.VDinf = SRout.VDinf;
    VAR.VDsup = SRout.VDsup;
    VAR.accept_rate  = SRout.accept_rate;
    VAR.ndraws_tried = SRout.ndraws_tried;

    % HD distribution: full struct from SR.m; HDmed/HDinf/HDsup already
    % computed there as full structs (shock bands; other components from HDfp)
    VAR.HDall = SRout.HDall;
    VAR.HDmed = SRout.HDmed;
    VAR.HDinf = SRout.HDinf;
    VAR.HDsup = SRout.HDsup;

    % Remove empty placeholders left by the initialization block above
    VAR = rmfield(VAR, {'B', 'IR', 'VD', 'HD'});

    % Sign path is complete; exit before the non-sign pipeline below
    return

else

    % Recover structural impact matrix B under the specified scheme
    [B, VAR] = recover_B(VAR, VARopt);
    VAR.B = B;

    % Wold multipliers (MA representation)
    [PSI, VAR] = compute_wold(VAR, VARopt);
    VAR.PSI = PSI;

    % Point estimates: IR, VD, and HD. Computed with the full-rank B returned
    % by recover_B; for iv/exog this includes the numerical completion in
    % columns 2:n (compute_HD requires an invertible B for eps = B\u).
    VAR.IR = compute_IR(VAR, VARopt, B, PSI);
    VAR.VD = compute_VD(VAR, VARopt, B, PSI);
    VAR.HD = compute_HD(VAR, B);

    % For iv and exog: only shock 1 is identified. Columns 2:n of B are a
    % Cholesky completion used solely to make B invertible for the structural-
    % shock backout in compute_HD; they carry no economic content. Zero them
    % everywhere they are exposed so the stored objects reflect only what is
    % identified: the completion columns of B, their impulse responses (IR),
    % their variance-decomposition shares (VD), and their historical-
    % decomposition contributions (HD.shock). HD.endo, HD.init, and HD.const
    % are computed before zeroing with the full B and are unaffected.
    % Dimension conventions differ by object: B(:,shock); IR(h,variable,shock)
    % (shock is the 3rd dimension); VD(h,shock,variable) and
    % HD.shock(time,shock,variable) (shock is the 2nd dimension).
    if any(strcmp(VARopt.ident, {'iv', 'exog'}))
        VAR.B(:,2:end)          = 0;
        VAR.IR(:,:,2:end)       = 0;
        VAR.VD(:,2:end,:)       = 0;
        VAR.HD.shock(:,2:end,:) = 0;
    end

end

%% 5. BOOTSTRAP INFERENCE
% -----------------------------------------------------------------------
% Skip if inference is not requested
if VARopt.inference == 0
    return
end

% Unpack bootstrap settings from VARopt
ndraws  = VARopt.ndraws;
pctg    = VARopt.pctg;
method  = VARopt.method;
nsteps  = VARopt.nsteps;
resid   = VAR.resid;
IV      = VARopt.IV;

% Guard: the i.i.d. residual bootstrap is invalid under iv identification.
% Resampling residual dates independently of the instrument breaks the
% contemporaneous pairing of z_t with u_t, which is the identifying moment
% of the proxy SVAR: the draws remain conformable and the program completes,
% but the resulting bands carry no identification content.
if strcmp(method,'bs') && strcmp(VARopt.ident,'iv')
    error(['VARmodel: method = ''bs'' is not valid with ident = ''iv''. The i.i.d. ' ...
        'residual bootstrap resamples residual dates independently of the instrument, ' ...
        'destroying the contemporaneous instrument/innovation pairing on which ' ...
        'proxy-SVAR identification rests. Use method = ''mbb'' (moving block ' ...
        'bootstrap) or method = ''wild''.']);
end

% Inner VARopt: same settings but no bootstrap (avoids infinite recursion)
VARopt_inner           = VARopt;
VARopt_inner.inference = 0;

% Moving block bootstrap: precompute the block structure and the recentering
% terms once, outside the draw loop. Blocks of consecutive residuals (and, under
% iv, of the instrument at the SAME dates) preserve both the serial dependence
% of the residuals and their contemporaneous pairing with the instrument.
% Follows Jentsch and Lunsford; the instrument recentering uses the deviation of
% the block-position mean from the full-sample mean, computed over observed
% (non-NaN) entries only.
if strcmp(method,'mbb')
    if isempty(VARopt.mbb_blocksize)
        BlockSize = floor(5.03 * nobs^0.25);   % Jentsch-Lunsford rule of thumb
    else
        BlockSize = VARopt.mbb_blocksize;
    end
    BlockSize = max(1, min(round(BlockSize), nobse));
    nBlock    = ceil(nobse / BlockSize);       % blocks needed to cover the sample
    nStart    = nobse - BlockSize + 1;         % number of admissible block starts

    % Recentering for the residuals: position j within a block is recentered on
    % the mean of all residuals that can occupy position j
    mbb_ctr = zeros(BlockSize, nvar);
    for j = 1:BlockSize
        mbb_ctr(j,:) = mean(resid(j:nobse-BlockSize+j, :), 1);
    end
    mbb_ctr = repmat(mbb_ctr, [nBlock, 1]);
    mbb_ctr = mbb_ctr(1:nobse, :);

    % Recentering for the instrument (iv only), over observed entries only
    if strcmp(VARopt.ident,'iv')
        IV_eff  = IV(nlag+1:end, :);
        nIV     = size(IV_eff, 2);
        mbb_Mctr = zeros(BlockSize, nIV);
        for j = 1:BlockSize
            subM = IV_eff(j:nobse-BlockSize+j, :);
            for c = 1:nIV
                mbb_Mctr(j,c) = mean(subM(~isnan(subM(:,c)), c)) ...
                              - mean(IV_eff(~isnan(IV_eff(:,c)), c));
            end
        end
        mbb_Mctr = repmat(mbb_Mctr, [nBlock, 1]);
        mbb_Mctr = mbb_Mctr(1:nobse, :);
    end
end

% Preallocate storage arrays; draws accumulated along 4th dimension
IRall        = zeros(nsteps,    nvar, nvar,    ndraws);
VDall        = zeros(nsteps,    nvar, nvar,    ndraws);
HDall_shock  = zeros(nobse+nlag, nvar, nvar,    ndraws);
HDall_init   = zeros(nobse+nlag, nvar,           ndraws);
HDall_const  = zeros(nobse+nlag, nvar,           ndraws);
HDall_trend  = zeros(nobse+nlag, nvar,           ndraws);
HDall_exo    = zeros(nobse+nlag, nvar, nvar_ex,  ndraws);
HDall_exosh  = zeros(nobse+nlag, nvar,           ndraws);
HDall_endo   = zeros(nobse+nlag, nvar,           ndraws);

% Buffer for the simulated endogenous data in each bootstrap draw
y_artificial = zeros(nobse+nlag, nvar);

% Draw counters: tt tracks accepted draws, ww tracks progress display intervals
tt = 1;  % accepted draws
ww = 1;  % progress counter

% Main bootstrap loop: iterate until ndraws stationary draws are accepted
while tt <= ndraws

    % Display progress
    if tt == VARopt.mult * ww
        disp(['Bootstrap draw ' num2str(tt) ' / ' num2str(ndraws)])
        ww = ww + 1;
    end

    % Step 1: draw bootstrap residuals
    if strcmp(method,'bs')
        % Standard bootstrap: sample rows of residual matrix with replacement.
        % Rejected above for ident='iv' (breaks the instrument/innovation pairing).
        u = resid(ceil(size(resid,1)*rand(nobse,1)),:);
    elseif strcmp(method,'mbb')
        % Moving block bootstrap: draw nBlock blocks of BlockSize consecutive
        % rows with replacement, concatenate, trim to the sample length, and
        % recenter. Under iv the instrument is blocked with the SAME start
        % indices, so each artificial residual keeps the instrument observation
        % it was paired with in the data.
        bidx = ceil(nStart * rand(nBlock,1));
        u    = zeros(nBlock*BlockSize, nvar);
        for j = 1:nBlock
            u(1+BlockSize*(j-1):BlockSize*j, :) = resid(bidx(j):bidx(j)+BlockSize-1, :);
        end
        u = u(1:nobse,:) - mbb_ctr;

        if strcmp(VARopt.ident,'iv')
            Zb = zeros(nBlock*BlockSize, nIV);
            for j = 1:nBlock
                Zb(1+BlockSize*(j-1):BlockSize*j, :) = IV_eff(bidx(j):bidx(j)+BlockSize-1, :);
            end
            Zb  = Zb(1:nobse,:);
            obs = ~isnan(Zb);                  % recenter observed entries only
            Zb(obs) = Zb(obs) - mbb_Mctr(obs);
            VARopt_inner.IV = [IV(1:nlag,:); Zb];
        end
    elseif strcmp(method,'wild')
        % Wild bootstrap: Rademacher weights applied to original residuals
        if strcmp(VARopt.ident,'iv')
            % For iv, one weight per observation is applied to the whole
            % residual row AND to every instrument column, so the pairing is
            % preserved. Drawing one weight per instrument and multiplying by
            % ones(nIV,nvar) (as before) summed the independent signs, giving
            % residual weights on {-nIV,...,+nIV} instead of {-1,+1} and
            % annihilating any row whose signs cancelled.
            rr = 1-2*(rand(nobse,1)>0.5);
            u  = resid .* (rr*ones(1,nvar));
            Z  = [IV(1:nlag,:); IV(nlag+1:end,:) .* (rr*ones(1,size(IV,2)))];
            VARopt_inner.IV = Z;
        else
            rr = 1-2*(rand(nobse,1)>0.5);
            u  = resid .* (rr*ones(1,nvar));
        end
    else
        error(['Bootstrap method ''' method ''' not recognised. Choose ''bs'', ''mbb'', or ''wild''.'])
    end

    % Step 2: simulate artificial data
    % Initialize the first nlag rows with actual data and build lag matrix
    LAG = [];
    for jj = 1:nlag
        y_artificial(jj,:) = ENDO(jj,:);
        LAG = [y_artificial(jj,:) LAG]; %#ok<AGROW>
    end

    % Augment lag matrix with deterministics for the first simulated period
    T       = (1:nobse)';
    LAGplus = build_LAGplus(LAG, const, T, 1);
    if ~isempty(exoshock)
        LAGplus = [LAGplus VAR.X_ES(1,:)];
    end
    if nvar_ex > 0
        LAGplus = [LAGplus VAR.X_EX(1,:)];
    end

    % Simulate observations nlag+1 to nobse+nlag recursively
    for jj = nlag+1:nobse+nlag
        for mm = 1:nvar
            y_artificial(jj,mm) = LAGplus * Ft(1:end,mm) + u(jj-nlag,mm);
        end
        if jj < nobse+nlag
            LAG     = [y_artificial(jj,:) LAG(1,1:(nlag-1)*nvar)];
            LAGplus = build_LAGplus(LAG, const, T, jj-nlag+1);
            if ~isempty(exoshock)
                LAGplus = [LAGplus VAR.X_ES(jj-nlag+1,:)]; %#ok<AGROW>
            end
            if nvar_ex > 0
                LAGplus = [LAGplus VAR.X_EX(jj-nlag+1,:)]; %#ok<AGROW>
            end
        end
    end

    % Step 3: re-estimate VAR on artificial data (inference=0 avoids recursion)
    if nvar_ex > 0
        VAR_draw = VARmodel(y_artificial, nlag, const, VARopt_inner, EXOG, nlag_ex);
    else
        VAR_draw = VARmodel(y_artificial, nlag, const, VARopt_inner);
    end

    % Step 4: store draw if bootstrapped VAR is stationary
    if VAR_draw.maxEig < .9999
        IRall(:,:,:,tt)        = VAR_draw.IR;
        VDall(:,:,:,tt)        = VAR_draw.VD;
        HDall_shock(:,:,:,tt)  = VAR_draw.HD.shock;
        HDall_init(:,:,tt)     = VAR_draw.HD.init;
        HDall_const(:,:,tt)    = VAR_draw.HD.const;
        HDall_trend(:,:,tt)    = VAR_draw.HD.trend;
        HDall_exo(:,:,:,tt)    = VAR_draw.HD.exo;
        HDall_exosh(:,:,tt)    = VAR_draw.HD.exoshock;
        HDall_endo(:,:,tt)     = VAR_draw.HD.endo;
        tt = tt + 1;
    end
end
disp('-- Done!');
disp(' ');

%% 6. COMPUTE PERCENTILE BANDS
% -----------------------------------------------------------------------
% Derive lower and upper percentile cutoffs from the requested coverage level
pctg_inf = (100 - pctg) / 2;
pctg_sup = 100 - (100 - pctg) / 2;

% IRF: store all draws, bootstrap mean, and percentile bands
VAR.IRall = IRall;
VAR.IRbar = mean(IRall, 4);
aux       = prctile(IRall, [pctg_inf pctg_sup], 4);
VAR.IRinf = aux(:,:,:,1);
VAR.IRsup = aux(:,:,:,2);

% FEVD: store all draws, bootstrap mean, and percentile bands
VAR.VDall = VDall;
VAR.VDbar = mean(VDall, 4);
aux       = prctile(VDall, [pctg_inf pctg_sup], 4);
VAR.VDinf = aux(:,:,:,1);
VAR.VDsup = aux(:,:,:,2);

% HD: pack all draws into a struct
VAR.HDall        = struct();
VAR.HDall.shock  = HDall_shock;
VAR.HDall.init   = HDall_init;
VAR.HDall.const  = HDall_const;
VAR.HDall.trend  = HDall_trend;
VAR.HDall.exo    = HDall_exo;
VAR.HDall.exoshock = HDall_exosh;
VAR.HDall.endo   = HDall_endo;

% HDbar: full struct, bootstrap mean of all components
VAR.HDbar.shock  = mean(HDall_shock, 4);
VAR.HDbar.init   = mean(HDall_init,  3);
VAR.HDbar.const  = mean(HDall_const, 3);
VAR.HDbar.trend  = mean(HDall_trend, 3);
VAR.HDbar.exo    = mean(HDall_exo,   4);
VAR.HDbar.exoshock = mean(HDall_exosh, 3);
VAR.HDbar.endo   = mean(HDall_endo,  3);

% HDinf / HDsup: full structs, percentile bands on all components
aux              = prctile(HDall_shock, [pctg_inf pctg_sup], 4);
VAR.HDinf.shock  = aux(:,:,:,1);
VAR.HDsup.shock  = aux(:,:,:,2);
aux              = prctile(HDall_init,  [pctg_inf pctg_sup], 3);
VAR.HDinf.init   = aux(:,:,1);
VAR.HDsup.init   = aux(:,:,2);
aux              = prctile(HDall_const, [pctg_inf pctg_sup], 3);
VAR.HDinf.const  = aux(:,:,1);
VAR.HDsup.const  = aux(:,:,2);
aux              = prctile(HDall_trend, [pctg_inf pctg_sup], 3);
VAR.HDinf.trend  = aux(:,:,1);
VAR.HDsup.trend  = aux(:,:,2);
aux              = prctile(HDall_exo,   [pctg_inf pctg_sup], 4);
VAR.HDinf.exo    = aux(:,:,:,1);
VAR.HDsup.exo    = aux(:,:,:,2);
aux              = prctile(HDall_exosh, [pctg_inf pctg_sup], 3);
VAR.HDinf.exoshock = aux(:,:,1);
VAR.HDsup.exoshock = aux(:,:,2);
aux              = prctile(HDall_endo,  [pctg_inf pctg_sup], 3);
VAR.HDinf.endo   = aux(:,:,1);
VAR.HDsup.endo   = aux(:,:,2);
