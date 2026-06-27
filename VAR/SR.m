function SRout = SR(VAR,R,VARopt)
% =======================================================================
% Compute IRs, VDs, and HDs for a VAR model identified with sign
% restrictions, with optional narrative sign restrictions. When R is a
% plain sign-restriction matrix, the call is fully backward compatible.
% =======================================================================
% SRout = SR(VAR,R,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function [struct]
%   - SIGN or R: sign and narrative restrictions. By convention, pass a
%       plain matrix as SIGN and a struct as R (see EXAMPLE). Either:
%       (a) SIGN — plain sign-restriction matrix (nvar x nshocks): +1
%           restricts positive, -1 restricts negative, 0 unrestricted;
%           narrative restrictions are skipped (fully backward compatible)
%       (b) R — struct with fields:
%           R.sign      - sign restriction matrix (nvar x nshocks) [matrix]
%           R.narr_sign - narrative sign restrictions: sign of structural
%               shock j at date t* must match the given sign. Fields
%               (each n x 1): .shock, .period, .sign (+1 or -1) [struct]
%           R.narr_dom  - dominant-shock restrictions: shock j must be
%               the dominant driver of variable i at date t*. Fields
%               (each n x 1): .shock, .period, .var [struct]
%           Both R.narr_sign and R.narr_dom are optional; omit either
%           field to skip that class of restrictions.
%           .period is the index of the date in the input data passed to
%           VARmodel. It may be given as an integer row index or as a date
%           string (e.g. '1979m10', '1990q3', '2001') matched against
%           VARopt.dates; the two forms are equivalent and refer to the
%           same row of the input data. For multiple restrictions, use a
%           numeric column vector or a cell array of strings, respectively.
%   - VARopt: options of the VAR (see VARoption from VARmodel) [struct]
%             VARopt.dates must be set to a cell array of date strings
%             aligned with the rows of the data passed to VARmodel when
%             string-format periods are used in R.narr_sign or R.narr_dom.
% -----------------------------------------------------------------------
% OUTPUT
%   - SRout: structure with the following fields [struct]:
%       * Bfp:          structural impact matrix of the Fry-Pagan draw
%                       (accepted draw with B closest to Bmed in Frobenius norm)
%       * IRfp:         point IRF from the Fry-Pagan draw (nsteps x nvar x nvar)
%       * VDfp:         point FEVD from the Fry-Pagan draw (nsteps x nvar x nvar)
%       * HDfp:         point HD struct from the Fry-Pagan draw
%                       (fields: .shock, .init, .const, .trend, .exo, .endo)
%       * Ball:         all accepted B matrices (nvar x nvar x ndraws)
%       * Bmed:         median B across accepted draws
%       * IRall, IRmed, IRinf, IRsup: IRF distribution and bands
%       * VDall, VDmed, VDinf, VDsup: FEVD distribution and bands
%       * HDall:        full HD struct over accepted draws; HDall.shock is
%                       (nobs+nlag x nvar x nvar x ndraws); other fields
%                       (init, const, trend, exo, endo) have draw dim last
%       * HDmed:        full HD struct, element-wise median of HDall.shock;
%                       non-shock components copied from HDfp (do not vary
%                       across rotation draws)
%       * HDinf, HDsup: full HD structs, percentile bands on HDall.shock;
%                       non-shock components copied from HDfp
%       * accept_rate:  share of all rotation attempts that are accepted
%                       (pass sign and, if active, narrative restrictions);
%                       equals ndraws / ndraws_tried. Counts individual
%                       rotation draws inside SignRestrictions, so it
%                       correctly reflects how tight the sign restrictions
%                       are (not just whether SignRestrictions succeeded).
%       * ndraws_tried: total rotation draws attempted; always >= ndraws;
%                       larger when sign or narrative filtering is tight
% -----------------------------------------------------------------------
% NARRATIVE RESTRICTION TYPES
%   narr_sign — Sign of structural shock at date t* (ADRR Type 1):
%       R.narr_sign.sign(k) * e(t*,j) > 0, where e = inv(B)*resid
%   narr_dom  — Dominant shock for variable i at date t* (ADRR Type 2):
%       |B(i,j)*e(t*,j)| > sum_{k~=j} |B(i,k)*e(t*,k)|
% -----------------------------------------------------------------------
% EXAMPLE
%   % Plain sign restrictions on a 3-variable VAR
%   SIGN = [1 0; -1 1; 0 -1];   % 3 vars, 2 shocks; 0 = unrestricted
%   VARopt = VARoption; VAR = VARmodel(randn(100,3), 2, 1, VARopt);
%   SRout = SR(VAR, SIGN, VARopt);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS AND PARSE R
% -----------------------------------------------------------------------
if ~exist('R','var')
    error('You have not provided sign restrictions (R)')
end
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end

% R can be a plain matrix (backward compatible) or a struct with sign and
% narrative restriction fields
if isstruct(R)
    SIGN = R.sign;
    narr_sign_active = isfield(R,'narr_sign') && ~isempty(R.narr_sign);
    narr_dom_active  = isfield(R,'narr_dom')  && ~isempty(R.narr_dom);
else
    SIGN = R;
    narr_sign_active = false;
    narr_dom_active  = false;
end
narr_active = narr_sign_active || narr_dom_active;
if narr_sign_active; n_narr_sign = length(R.narr_sign.shock); end
if narr_dom_active;  n_narr_dom  = length(R.narr_dom.shock);  end

% Convert input-data periods (integer rows or date strings) to residual-sample indices
if narr_sign_active
    R.narr_sign.period = resolve_period(R.narr_sign.period, VARopt, VAR.nlag);
end
if narr_dom_active
    R.narr_dom.period = resolve_period(R.narr_dom.period, VARopt, VAR.nlag);
end

%% 2. RETRIEVE PARAMETERS AND PREALLOCATE
% -----------------------------------------------------------------------
% Extract VAR dimensions and options needed throughout the loop
nvar    = VAR.nvar;
nvar_ex = VAR.nvar_ex;
nsteps  = VARopt.nsteps;
ndraws  = VARopt.ndraws;
nobs    = VAR.nobs;
nlag    = VAR.nlag;
pctg    = VARopt.pctg;

% Preallocate storage arrays for IRFs, VDs, and HDs across accepted draws
IRall  = nan(nsteps,nvar,nvar,ndraws);
VDall  = nan(nsteps,nvar,nvar,ndraws);
HDall.shock  = zeros(nobs+nlag,nvar,nvar,ndraws);
HDall.init   = zeros(nobs+nlag,nvar,ndraws);
HDall.const  = zeros(nobs+nlag,nvar,ndraws);
HDall.trend  = zeros(nobs+nlag,nvar,ndraws);
HDall.endo   = zeros(nobs+nlag,nvar,ndraws);
HDall.exo    = zeros(nobs+nlag,nvar,nvar_ex,ndraws);
Ball = nan(nvar,nvar,ndraws);

%% 3. SIGN RESTRICTION DRAW LOOP
% -----------------------------------------------------------------------
% Draw orthonormal rotations satisfying SIGN. For each sign-valid draw,
% compute structural shocks and apply narrative restrictions as an
% additional acceptance filter before counting the draw.
jj = 0;   % accepted draws (passed sign and narrative restrictions)
tt = 0;   % total attempted draws
ww = 1;   % index for printing progress
while jj < ndraws

    if tt > VARopt.sr_draw
        disp('------------------------------------------------------------')
        disp( 'Total number of draws for finding sign restrictions exceeded')
        disp( 'Change the restrictions or increase VARopt.sr_draw');
        disp('------------------------------------------------------------')
        error('See details above')
    end

    % Field name 'draw0' corresponds to the first accepted draw (jj=0),
    % 'draw1' to the second, etc. (0-indexed by accepted-draw count).
    label = {['draw' num2str(jj)]};
    VAR_draw.(label{1}) = VAR;

    % If inference is requested, draw F and sigma from the posterior to
    % include parameter uncertainty in addition to identification uncertainty
    if VARopt.inference == 1
        [sigma_draw, Ft_draw, F_draw, Fcomp_draw] = VARdrawpost(VAR);
        VAR_draw.(label{1}).Ft    = Ft_draw;
        VAR_draw.(label{1}).F     = F_draw;
        VAR_draw.(label{1}).Fcomp = Fcomp_draw;
        VAR_draw.(label{1}).sigma = sigma_draw;
    end

    % Draw a rotation satisfying the sign restrictions
    [B, n_rot] = SignRestrictions(SIGN, VAR_draw.(label{1}), VARopt);

    % Narrative restrictions: additional filter on sign-valid draws.
    % Compute structural shocks e = inv(B)*resid and check each narrative
    % constraint. A draw failing any constraint is discarded.
    if ~isempty(B) && narr_active
        e = (B \ VAR_draw.(label{1}).resid')';   % nobs x nvar structural shocks

        % narr_sign: sign of structural shock j at date t* must match R.narr_sign.sign
        if narr_sign_active
            for kk = 1:n_narr_sign
                if R.narr_sign.sign(kk) * e(R.narr_sign.period(kk), R.narr_sign.shock(kk)) <= 0
                    B = []; break
                end
            end
        end

        % narr_dom: |contribution of shock j to variable i| must dominate all others
        if ~isempty(B) && narr_dom_active
            for kk = 1:n_narr_dom
                contrib  = B(R.narr_dom.var(kk), :) .* e(R.narr_dom.period(kk), :);
                shock_kk = R.narr_dom.shock(kk);
                if abs(contrib(shock_kk)) <= sum(abs(contrib)) - abs(contrib(shock_kk))
                    B = []; break
                end
            end
        end
    end

    % Store outputs for accepted draw; log progress at multiples of VARopt.mult
    if ~isempty(B)
        jj = jj+1; tt = tt+n_rot;
        Ball(:,:,jj) = B;
        VAR_draw.(label{1}).B = B;

        % Compute Wold representation and store IRF, VD, HD for this draw
        [PSI, VAR_draw.(label{1})] = compute_wold(VAR_draw.(label{1}), VARopt);
        IRall(:,:,:,jj) = compute_IR(VAR_draw.(label{1}), VARopt, B, PSI);
        VDall(:,:,:,jj) = compute_VD(VAR_draw.(label{1}), VARopt, B, PSI);
        aux_hd = compute_HD(VAR_draw.(label{1}), B);
        HDall.shock(:,:,:,jj) = aux_hd.shock;
        HDall.init(:,:,jj)    = aux_hd.init;
        HDall.const(:,:,jj)   = aux_hd.const;
        HDall.trend(:,:,jj)   = aux_hd.trend;
        HDall.endo(:,:,jj)    = aux_hd.endo;
        if nvar_ex > 0; HDall.exo(:,:,:,jj) = aux_hd.exo; end

        % Print progress at each multiple of VARopt.mult accepted draws
        if jj == VARopt.mult * ww
            disp(['Rotation: ' num2str(jj) ' / ' num2str(ndraws)]);
            ww = ww + 1;
        end
    else
        tt = tt + n_rot;
    end

end
disp('-- Done!');
disp(' ');

%% 4. STORE RESULTS
% -----------------------------------------------------------------------
% Pack all accepted draws into the output structure
SRout.IRall = IRall;
SRout.VDall = VDall;
SRout.Ball  = Ball;
SRout.HDall = HDall;

% Acceptance rate and total draws attempted
SRout.accept_rate  = jj / tt;   % share of all attempted draws accepted
SRout.ndraws_tried = tt;        % total rotation draws attempted

% Median B matrix across accepted draws
SRout.Bmed = median(Ball,3);

% Select the Fry-Pagan draw: accepted draw whose B is closest to Bmed
% (Frobenius distance). Ball(:,:,n) stored under label draw(n-1).
aux = sum(sum((Ball - SRout.Bmed).^2,1),2);
sel = find(aux == min(aux));
sel = sel(1);
SRout.Bfp = Ball(:,:,sel);

% Percentile bands for IRs and VDs
pctg_inf = (100-pctg)/2;
pctg_sup = 100 - (100-pctg)/2;
SRout.IRmed = median(IRall,4);
aux = prctile(IRall,[pctg_inf pctg_sup],4);
SRout.IRinf = aux(:,:,:,1);
SRout.IRsup = aux(:,:,:,2);
SRout.VDmed = median(VDall,4);
aux = prctile(VDall,[pctg_inf pctg_sup],4);
SRout.VDinf = aux(:,:,:,1);
SRout.VDsup = aux(:,:,:,2);

% Fry-Pagan IR, VD, HD: point estimates from the draw closest to Bmed.
VAR_pt      = VAR_draw.(['draw' num2str(sel-1)]);
[PSI_pt, ~] = compute_wold(VAR_pt, VARopt);
SRout.IRfp  = compute_IR(VAR_pt, VARopt, SRout.Bfp, PSI_pt);
SRout.VDfp  = compute_VD(VAR_pt, VARopt, SRout.Bfp, PSI_pt);
SRout.HDfp  = compute_HD(VAR_pt, SRout.Bfp);

% HDmed: full struct; shock = element-wise median across accepted draws;
% non-shock components do not vary across rotation draws (they depend only
% on OLS coefficients, not on B), so they are copied from HDfp.
SRout.HDmed.shock  = median(HDall.shock, 4);
SRout.HDmed.init   = SRout.HDfp.init;
SRout.HDmed.const  = SRout.HDfp.const;
SRout.HDmed.trend  = SRout.HDfp.trend;
SRout.HDmed.exo    = SRout.HDfp.exo;
SRout.HDmed.endo   = SRout.HDfp.endo;

% HDinf / HDsup: full structs; shock = percentile bands across accepted
% draws; non-shock components copied from HDfp (no variation across draws).
aux = prctile(HDall.shock, [pctg_inf pctg_sup], 4);
SRout.HDinf.shock  = aux(:,:,:,1);
SRout.HDinf.init   = SRout.HDfp.init;
SRout.HDinf.const  = SRout.HDfp.const;
SRout.HDinf.trend  = SRout.HDfp.trend;
SRout.HDinf.exo    = SRout.HDfp.exo;
SRout.HDinf.endo   = SRout.HDfp.endo;
SRout.HDsup.shock  = aux(:,:,:,2);
SRout.HDsup.init   = SRout.HDfp.init;
SRout.HDsup.const  = SRout.HDfp.const;
SRout.HDsup.trend  = SRout.HDfp.trend;
SRout.HDsup.exo    = SRout.HDfp.exo;
SRout.HDsup.endo   = SRout.HDfp.endo;

%% LOCAL FUNCTIONS
% -----------------------------------------------------------------------
function idx = resolve_period(period, VARopt, nlag)
% Convert a period specification to a numeric residual-sample index.
% period is expressed relative to the INPUT DATA passed to VARmodel: an
% integer is the input-data row, a string is matched against VARopt.dates.
% Both forms refer to the same row of the input data and are converted to
% the residual-sample index by subtracting nlag (the first nlag rows are
% absorbed as initial conditions). VARopt.dates must be aligned with the
% rows of the data passed to VARmodel (i.e. the full sample before lags
% are dropped).
if isnumeric(period)
    idx = period - nlag;
    bad = find(idx <= 0, 1);
    if ~isempty(bad)
        error('SR:periodTooEarly', ...
            ['period index %d falls within the lag window of %d initial ' ...
            'observations (residual-sample index = %d <= 0).'], ...
            period(bad), nlag, idx(bad))
    end
    return
end

% String input: require VARopt.dates
if ~isfield(VARopt,'dates') || isempty(VARopt.dates)
    error('SR:noDates', ['String period requires VARopt.dates ' ...
        '(cell array of date strings aligned with the data passed to VARmodel).'])
end

% Wrap scalar char as 1-element cell for uniform handling
if ischar(period)
    period = {period};
end

idx = zeros(size(period));
for kk = 1:numel(period)
    pos = find(strcmp(VARopt.dates, period{kk}));
    if isempty(pos)
        error('SR:dateNotFound', ...
            'Date ''%s'' not found in VARopt.dates.', period{kk})
    end
    idx(kk) = pos - nlag;
    if idx(kk) <= 0
        error('SR:dateTooEarly', ...
            ['Date ''%s'' falls within the lag window ' ...
            '(residual-sample index = %d <= 0).'], period{kk}, idx(kk))
    end
end
