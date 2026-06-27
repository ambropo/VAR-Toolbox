function [CORR, TABLE] = CorrTable(x,vnames,pairwise)
% =======================================================================
% Computes the correlation matrix of a matrix of time series with titles
% =======================================================================
% [CORR, TABLE] = CorrTable(x,vnames,pairwise)
% -----------------------------------------------------------------------
% INPUT
%   - x: matrix (rows x cols) [double]
%   - vnames: array (1 x cols) with names of the (cols) series [cell]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - pairwise: 1 to compute pairwise (ignores NaN row-wise per pair) [dflt = 0]
% -----------------------------------------------------------------------
% OUTPUT
%   - CORR: correlation matrix [double]
%   - TABLE: table of correlation matrix with titles [cell]
%   Note: mprint also prints CORR as a formatted table to the command
%         window as a side effect.
% -----------------------------------------------------------------------
% EXAMPLE
%   x = randn(50,3);
%   vnames = {'X1','X2','X3'};
%   [CORR, TABLE] = CorrTable(x,vnames);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate required inputs and set default for optional argument.
if nargin < 2
    error('CorrTable: x and vnames are required inputs.')
end

% Default: listwise deletion (drop any row containing a NaN)
if ~exist('pairwise','var')
    pairwise = 0;
end

% vnames must be a row vector
if size(vnames,1)>1
    vnames = vnames';
end

%% 2. COMPUTE CORRELATION MATRIX
% -----------------------------------------------------------------------
% Compute full correlation matrix; pairwise=1 maximises usable observations
% per pair by ignoring NaN entries row-wise for each pair individually.
if pairwise==0
    CORR = corr(x);
elseif pairwise==1
    % 'pairwise' uses all available obs for each pair, ignoring NaNs
    CORR = corr(x,'rows','pairwise');
end
[r, ~] = size(CORR);

% Zero out the strictly upper triangle (keep lower triangle and diagonal)
CORR(logical(triu(ones(r), 1))) = NaN;

%% 3. FORMAT AND PRINT OUTPUT TABLE
% -----------------------------------------------------------------------
% Assemble a cell array with variable names as row and column labels,
% then print a formatted version to the command window via mprint.
TAB = num2cell(CORR);
TAB = [vnames ; TAB];          % column headers on top
aux = [{''} vnames]';
TABLE = [aux TAB];             % row labels on the left

% Print formatted table to command window
info.cvnames = char(vnames);
info.rvnames = char([{' '} vnames]);
mprint(CORR,info);
