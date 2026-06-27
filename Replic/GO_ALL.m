% Runs all replication scripts in the Replic folder in sequence.
% =======================================================================
% Calls GO_BQ1989, GO_SW2001, GO_Uhlig2005, GO_GK2015, GO_ADRR2018,
% and GO_JT2025 in chronological order. Each script manages its own
% workspace setup, data loading, estimation, and figure saving. This
% wrapper only handles sequencing and progress reporting.
% Requires VAR Toolbox 4.0.
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 0. PRELIMINARIES
% -----------------------------------------------------------------------
% Resolve the Primer folder and toolbox root from the script location so
% relative file paths work regardless of the folder from which the script
% is launched.
clear; close all; clc
warning off all
format short g
rng('default'); rng(4);

% Identify the toolbox root from this file's location (one up from Primer)
root = fileparts(fileparts(mfilename('fullpath')));

% Add each relevant subfolder explicitly
addpath(fullfile(root, 'VAR'));
addpath(fullfile(root, 'Figure'));
addpath(fullfile(root, 'Stats'));
addpath(fullfile(root, 'Utils'));
addpath(fullfile(root, 'Primer'));
addpath(fullfile(root, 'Auxiliary'));
disp('VAR Toolbox 4.0 path set.');


%% 1. BQ1989 — Blanchard and Quah (1989, AER)
% -----------------------------------------------------------------------
% Long-run identification of supply and demand shocks in a bivariate VAR
% for US GDP growth and the unemployment rate.
fprintf('\n[1/6] Running GO_BQ1989 (Blanchard and Quah 1989)...\n')
run(fullfile(fileparts(mfilename('fullpath')), 'BQ1989', 'GO_BQ1989'));
fprintf('[1/6] Done.\n')

%% 2. SW2001 — Stock and Watson (2001, JEP)
% -----------------------------------------------------------------------
% Cholesky identification of monetary policy shocks in a trivariate VAR
% for inflation, unemployment, and the federal funds rate.
fprintf('\n[2/6] Running GO_SW2001 (Stock and Watson 2001)...\n')
run(fullfile(fileparts(mfilename('fullpath')), 'SW2001', 'GO_SW2001'));
fprintf('[2/6] Done.\n')

%% 3. UHLIG2005 — Uhlig (2005, JME)
% -----------------------------------------------------------------------
% Sign restriction identification of a contractionary monetary policy
% shock in a 6-variable monthly VAR for the US economy.
fprintf('\n[3/6] Running GO_Uhlig2005 (Uhlig 2005)...\n')
run(fullfile(fileparts(mfilename('fullpath')), 'Uhlig2005', 'GO_Uhlig2005'));
fprintf('[3/6] Done.\n')

%% 4. GK2015 — Gertler and Karadi (2015, AEJ:M)
% -----------------------------------------------------------------------
% Cholesky vs. external instrument (proxy SVAR) identification of a
% monetary policy shock in a 4-variable monthly VAR.
fprintf('\n[4/6] Running GO_GK2015 (Gertler and Karadi 2015)...\n')
run(fullfile(fileparts(mfilename('fullpath')), 'GK2015', 'GO_GK2015'));
fprintf('[4/6] Done.\n')

%% 5. ADRR2018 — Antolin-Diaz and Rubio-Ramirez (2018, AER)
% -----------------------------------------------------------------------
% Sign restrictions vs. sign + narrative sign restrictions for the Uhlig
% (2005) 6-variable monetary VAR with the October 1979 Volcker episode.
fprintf('\n[5/6] Running GO_ADRR2018 (Antolin-Diaz and Rubio-Ramirez 2018)...\n')
run(fullfile(fileparts(mfilename('fullpath')), 'ADRR2018', 'GO_ADRR2018'));
fprintf('[5/6] Done.\n')

%% 6. JT2025 — Jorda and Taylor (2025, JEL)
% -----------------------------------------------------------------------
% LP and LP-IV impulse responses to a monetary policy shock using the
% Romer-Romer instrument.
fprintf('\n[6/6] Running GO_JT2025 (Jorda and Taylor 2025)...\n')
run(fullfile(fileparts(mfilename('fullpath')), 'JT2025', 'GO_JT2025'));
fprintf('[6/6] Done.\n')

% Print a summary line confirming that all six replications finished
fprintf('\nAll 6 replications complete.\n')

% Close all figure windows opened across the replication scripts
close all