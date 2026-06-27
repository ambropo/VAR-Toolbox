function LPopt = LPoption
% =======================================================================
% Set default options for LP (local projection) estimation
% =======================================================================
% LPopt = LPoption
% -----------------------------------------------------------------------
% OUTPUT
%   - LPopt: structure of default LP options. Fields listed below with
%       defaults; see LPmodel and LPirplot for usage.
% -----------------------------------------------------------------------
% EXAMPLE
%   LPopt = LPoption;
%   LPopt.nsteps = 20;
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: November 2024. Updated: 2026-06-03
% -----------------------------------------------------------------------

%% 1. ESTIMATION SETTINGS
% -----------------------------------------------------------------------
% Projection horizon and confidence level for impulse response bands.
LPopt.nsteps = 40; % number of steps for computation of IRFs
LPopt.pctg   = 95; % outer confidence level for bands (percent)

% Shock normalisation: 0 standardises TREAT to unit standard deviation before
% projection; 1 leaves TREAT unchanged so the response is per unit of TREAT.
LPopt.impact = 0; % 0 = one-std-dev shock; 1 = unit shock

% Long-difference LHS: when 1, the dependent variable at horizon h is
% ENDO_{t+h} - ENDO_{t-1} instead of the level ENDO_{t+h}
LPopt.longdiff = 0;

% External instrument: when non-empty, contains the external instrument
% used to identify the endogenous treatment TREAT passed to LPmodel (e.g. the
% policy rate). This matches the VARopt.IV convention, where .IV holds the
% instrument. When empty, OLS is used (backward compatible).
LPopt.IV = [];

% Number of lags of the instrument to add as additional instruments when
% LPopt.IV is non-empty. 0 = just-identified IV (default). n > 0 adds
% lags 1,...,n of LPopt.IV (after FWL) as extra instruments for 2SLS (matches
% instruments(rz l(1/n).rz) in Stata ivreghdfe). Requires nlag_iv <= nlag.
LPopt.nlag_iv = 0;

%% 2. DISPLAY OPTIONS
% -----------------------------------------------------------------------
% Labels and export settings for LPirplot figure output.

% Variable and shock labels
LPopt.mnem       = {};    % cell array of variable mnemonics: valid MATLAB
                          % identifiers used to name the per-outcome
                          % sub-structs LP.(.). Falls back to vnames if empty.
LPopt.vnames     = {};    % cell array of variable names (display labels for
                          % plots), one per column of IR. Falls back to mnem.
LPopt.snames     = {};    % cell array of shock names (single entry for LP)

% Figure export
LPopt.figname    = [];      % prefix for the exported figure filename
LPopt.figsize    = [];      % figure window size [width, height] in cm
LPopt.quality    = 2;       % export quality: 2=high (exportgraphics), 1=high, 0=pdf
LPopt.suptitle   = 0;       % 1 = show a super-title above all panels

% Panel appearance
LPopt.latex      = 1;    % 1 = use LaTeX interpreter for figure text
LPopt.font       = 'Helvetica'; % font name for figure text; '' = MATLAB default

LPopt.grid       = 1;    % 1 = show gridlines in plots
LPopt.marker     = 'o';  % marker style for the IR line ('o', 'none', etc.)
LPopt.subplot    = [];   % subplot grid [rows cols]; empty = auto from sqrt(nvars)
LPopt.shorttitle = 0;    % 1 = show only variable name as panel title; 0 = 'var to shock'
LPopt.color      = [];   % band and line color (RGB triplet); empty = pantone('Blue')
LPopt.linestyle  = '-';  % IR line style ('-', '--', ':', '-.')
LPopt.hstart     = 1;    % first horizon label on x-axis (0 or 1)
LPopt.xlim       = [];   % x-axis limits [lo hi]; empty = auto from hstart:H
LPopt.ylim       = [];   % y-axis limits [lo hi]; empty = auto
LPopt.xtick      = [];   % x-tick positions; empty = auto
LPopt.xlabel     = '';   % x-axis label (applied to each panel; empty = none)
LPopt.ylabel     = '';   % y-axis label (applied to each panel; empty = none)
LPopt.dualaxis   = 1;    % 1 = dual-axis panel style (ticks mirrored on left
                         % and right y-axes, box off, closure tick); 0 = off
LPopt.legcols    = 1;      % number of legend columns (reserved)
LPopt.legloc     = 'best'; % legend location (reserved; LPirplot currently has no legend)
LPopt.visible    = 1;    % 1 = show figure window, 0 = suppress display (save only)
