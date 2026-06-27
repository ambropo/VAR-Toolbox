function LAGplus = build_LAGplus(LAG, const, T, t_idx)
% =======================================================================
% Augment a lag vector with deterministic components (constant, trend)
% for use in the bootstrap data-simulation loop.
% =======================================================================
% LAGplus = build_LAGplus(LAG, const, T, t_idx)
% -----------------------------------------------------------------------
% INPUT
%   - LAG:   (1 x nvar*nlag) row vector of stacked lagged values [double]
%   - const: deterministic spec: 0 none; 1 constant; 2 constant+trend [integer]
%   - T:     (nobse x 1) time-trend index vector (1:nobse)' [double]
%   - t_idx: scalar index into T for the current simulation period [integer]
% -----------------------------------------------------------------------
% OUTPUT
%   - LAGplus: (1 x ntotcoeff) row vector ready to premultiply Ft [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   LAG   = randn(1, 6);
%   T     = (1:100)';
%   LAGplus = build_LAGplus(LAG, 2, T, 10);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------


%% 1. BUILD LAG-PLUS VECTOR
% -----------------------------------------------------------------------
% Prepend deterministic components to LAG in the order expected by the
% VARmodel coefficient matrix Ft: [const, trend, lags].
if const == 0
    LAGplus = LAG;
elseif const == 1
    LAGplus = [1 LAG];
elseif const == 2
    LAGplus = [1 T(t_idx) LAG];
else
    error('build_LAGplus: const must be 0, 1, or 2 (got %d)', const);
end
