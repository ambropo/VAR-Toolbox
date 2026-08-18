function VARopt = VARoption
% =======================================================================
% Set default options for VAR analysis. Passed as input to VARmodel.
% =======================================================================
% VARopt = VARoption
% -----------------------------------------------------------------------
% OUTPUT
%   - VARopt: structure of options used by VARmodel and plot functions.
%       Fields listed below with defaults.
% -----------------------------------------------------------------------
% EXAMPLE
%   VARopt = VARoption;
%   VARopt.ident = 'short'; VARopt.nsteps = 20;
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-06-03
% -----------------------------------------------------------------------

%% 1. SET DEFAULT OPTIONS
% -----------------------------------------------------------------------
% Variable and shock labels
VARopt.mnem      = [];      % endogenous variable mnemonics: valid MATLAB
                            % identifiers (no spaces/special characters) used
                            % to name the per-equation sub-structs VAR.(.).
                            % Falls back to eq1,...,eqN if empty or invalid.
VARopt.vnames    = [];      % endogenous variable names: display labels for
                            % plots and tables (may contain spaces, LaTeX).
                            % Falls back to mnem if empty.
VARopt.vnames_ex = [];      % exogenous variable names
VARopt.snames    = [];      % shock names (defaults to vnames if empty)

% Identification
VARopt.ident     = '';      % identification scheme: '' (none, reduced form
                            % only), 'short' (zero contemporaneous), 'long'
                            % (zero long-run), 'sign' (sign restrictions),
                            % 'sign+iv' (sign restrictions with an
                            % IV-identified first shock), 'iv' (external
                            % instrument), 'exog' (exogenous variable)
VARopt.IV            = [];  % external instrument matrix for ident='iv' or 'sign+iv'
VARopt.exoshock      = [];  % exogenous shock variable for ident='exog'
VARopt.nlag_exoshock = 0;   % lag order for exoshock [dflt = 0, contemporaneous only]

% IRF and FEVD computation
VARopt.nsteps    = 40;      % number of horizons for IRFs and FEVDs
VARopt.impact    = 0;       % shock size: 0 = one std dev, 1 = unit shock
VARopt.shut      = 0;       % force the IRF of one variable to zero (0 = off)
VARopt.recurs    = 'wold';  % MA representation: 'wold' or companion form 'comp'

% Inference
VARopt.inference = 1;       % 1 = propagate parameter uncertainty (default); 0 = point estimates only
VARopt.ndraws    = 1000;    % number of bootstrap draws
VARopt.mult      = 10;      % print progress every mult draws
VARopt.pctg      = 95;      % outer confidence level for error bands (percent)
VARopt.method    = 'bs';    % bootstrap method: 'bs' standard (i.i.d. residual),
                            % 'mbb' moving block (Jentsch-Lunsford), 'wild' wild.
                            % 'bs' is rejected under ident='iv': see VARmodel.
VARopt.mbb_blocksize = [];  % block length for method='mbb'; [] = floor(5.03*nobs^0.25)

% Sign restrictions
VARopt.R         = [];      % sign restriction matrix or struct (required for ident='sign' or 'sign+iv')
VARopt.sr_hor    = 1;       % number of periods over which sign restrictions apply
VARopt.sr_rot    = 500;     % maximum rotations per draw
VARopt.sr_draw   = 100000;  % maximum total draws

% Figure export
VARopt.pick      = 0;       % shock to plot: 0 = all, j = shock j only
VARopt.quality   = 2;       % export quality: 2 = high via exportgraphics (recommended,
                            % R2020a+), 1 = high via ghostscript (legacy fallback),
                            % 0 = low via print -dpdf
VARopt.suptitle  = 0;       % 1 = add super-title above figure panels
% Use firstdate and frequency to control axis date labels.
VARopt.firstdate = [];      % first sample date (e.g. 1999.75 = 1999Q4)
VARopt.frequency = 'q';     % data frequency: 'q' quarterly, 'm' monthly, 'y' yearly
VARopt.datenticks = 5;      % target number of date ticks on x-axis (HD plots); fewer avoids slanted year labels in narrow panels
VARopt.figname   = [];      % prefix string for exported figure filename
VARopt.figsize   = [];      % figure window size [width, height] in cm

% Panel appearance (used by all plot functions)
VARopt.latex      = 1;      % 1 = use LaTeX interpreter for figure text
VARopt.font       = 'Helvetica'; % font name for figure text; '' = MATLAB default

VARopt.grid       = 1;      % 1 = show gridlines in plots
VARopt.marker     = 'o';    % marker style for IRF line ('o', 'none', etc.)
VARopt.subplot    = [];     % subplot grid [rows cols]; empty = auto from sqrt(nvars)
VARopt.shorttitle = 0;      % 1 = show variable name only as panel title
VARopt.color      = [];     % line and band color (RGB triplet); empty = pantone('Blue')
VARopt.linestyle  = '-';    % IR line style ('-', '--', ':', '-.')
VARopt.hstart     = 1;      % first horizon label on x-axis (0 or 1)
VARopt.xlim       = [];     % x-axis limits [lo hi]; empty = auto
VARopt.ylim       = [];     % y-axis limits [lo hi]; empty = auto
VARopt.xtick      = [];     % x-tick positions; empty = auto
VARopt.xlabel     = '';     % x-axis label applied to each panel; empty = none
VARopt.ylabel     = '';     % y-axis label applied to each panel; empty = none
VARopt.dualaxis   = 1;      % 1 = dual-axis panel style (ticks mirrored on left
                            % and right y-axes, box off, closure tick); 0 = off
VARopt.visible    = 1;      % 1 = show figure windows, 0 = suppress display (save only)
VARopt.legcols    = 1;      % number of columns in the legend (lh.NumColumns)
VARopt.legloc     = 'best'; % legend location: 'best' = auto-corner (ne/nw/se/sw);
                            % or any explicit MATLAB Location string

% Historical decomposition plot options (VARhdplot)
VARopt.hd_colors = [];      % (ncols x 3) RGB matrix to override bar colors in stack order;
                            % stack order when all fields present: const, trend,
                            % init, exo vars, shocks. Empty = use cmap(1), cmap(2), …
VARopt.hd_detc = 1;         % 1 = stack all HD components; order (bottom to top):
                            %     const, trend, init, exo vars, shocks.
                            %     Bars sum to the 'Data' reference line (default).
                            % 0 = stack shock contributions only; reference line
                            %     is data minus const and init ('Data (adj.)'),
                            %     so shock bars sum exactly to the reference.

% Narrative restrictions: date cell array aligned with the input data
% passed to VARmodel (one entry per row of the input data, before lags are
% dropped). Required by SR.m when R.narr_sign or R.narr_dom use string-format
% periods; SR.m converts the matched position to a residual-sample index.
VARopt.dates      = [];     % cell array of date strings, one per observation
