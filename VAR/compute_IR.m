function IR = compute_IR(VAR, VARopt, B, PSI)
% =======================================================================
% Compute impulse response functions given an estimated VAR, an identified
% structural impact matrix B, and the Wold multipliers PSI.
% =======================================================================
% IR = compute_IR(VAR, VARopt, B, PSI)
% -----------------------------------------------------------------------
% INPUT
%   - VAR:    structure, result of VARmodel OLS estimation [struct]
%   - VARopt: options structure; relevant fields:
%               VARopt.nsteps: number of horizons
%               VARopt.impact: 0 = one-std-dev shock; 1 = unit shock
%               VARopt.shut:   variable index to shut down (0 = none)
%               VARopt.recurs: 'wold' (default) or 'comp' (companion)
%             [struct]
%   - B:      (nvar x nvar) structural impact matrix from recover_B [double]
%   - PSI:    (nvar x nvar x nsteps) Wold multipliers from compute_wold
%             [double]
% -----------------------------------------------------------------------
% OUTPUT
%   - IR: (nsteps x nvar x nvar) impulse responses;
%         IR(h, variable, shock) is the response of variable at horizon h
%         to a unit structural shock [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   Y  = randn(100, 3);
%   VARopt = VARoption; VARopt.nsteps = 20; VARopt.impact = 0;
%   VARopt.shut = 0;    VARopt.recurs = 'wold';
%   VAR = VARmodel(Y, 2, 1);
%   B   = chol(VAR.sigma)';
%   PSI = compute_wold(VAR, VARopt);
%   IR  = compute_IR(VAR, VARopt, B, PSI);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------


%% 1. UNPACK PARAMETERS
% -----------------------------------------------------------------------
% Extract horizon length, shock scaling, shut-down index, recursion method,
% and companion matrix from the input structures.
nsteps = VARopt.nsteps;
impact = VARopt.impact;
shut   = VARopt.shut;
recurs = VARopt.recurs;
nvar   = VAR.nvar;
Fcomp  = VAR.Fcomp;

% Pre-allocate output array with NaN so incomplete runs are detectable
IR = nan(nsteps, nvar, nvar);


%% 2. COMPUTE IMPULSE RESPONSES
% -----------------------------------------------------------------------
% Loop over structural shocks. For each shock mm, build the unit impulse
% vector, propagate it through B and PSI (or the companion form), and
% store the (nsteps x nvar) response matrix in IR(:,:,mm).
for mm = 1:nvar

    % Zero out the row of Fcomp for the shut-down variable if requested
    if shut ~= 0
        Fcomp(shut,:) = 0;
    end

    % Build the structural impulse vector for shock mm
    impulse = zeros(nvar, 1);
    if impact == 0
        impulse(mm) = 1;
    elseif impact == 1
        impulse(mm) = 1 / B(mm,mm);
    else
        error('VARopt.impact must be 0 (one std dev) or 1 (unit shock).');
    end

    % Compute the response path
    response      = zeros(nvar, nsteps);
    response(:,1) = B * impulse;
    if shut ~= 0
        response(shut,1) = 0;
    end

    % The shut-down counterfactual is defined by the modified companion
    % matrix (the row of Fcomp for variable shut was zeroed above), so the
    % response must be propagated through Fcomp whenever shut is active,
    % irrespective of VARopt.recurs. PSI was built by compute_wold from the
    % unmodified lag polynomial: under 'wold' the shut variable was zeroed
    % on impact only and responded again from horizon 2 onwards, so the two
    % recursion options implemented different counterfactuals.
    if shut ~= 0
        recurs_h = 'comp';
    else
        recurs_h = recurs;
    end

    if strcmp(recurs_h,'wold')
        for kk = 2:nsteps
            response(:,kk) = PSI(:,:,kk) * B * impulse;
        end
    elseif strcmp(recurs_h,'comp')
        for kk = 2:nsteps
            FcompN         = Fcomp^(kk-1);
            response(:,kk) = FcompN(1:nvar,1:nvar) * B * impulse;
        end
    end

    IR(:,:,mm) = response';
end
