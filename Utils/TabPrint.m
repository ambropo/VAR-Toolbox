function OUT = TabPrint(DATA,hlabel,vlabel,approx)
% =======================================================================
% Prints a numerical table with labels, with specified numbers of decimal
% digits
% =======================================================================
% OUT = TabPrint(DATA,hlabel,vlabel,approx)
% -----------------------------------------------------------------------
% INPUT
%   - DATA = a (T x N) matrix of numbers
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%	- hlabel = a (1 x N) cell array of column headers
%	- vlabel = a (T x 1) cell array of row labels
%   - approx = number of decimal digits [dflt = 2]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT = a cell array with the formatted table
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   hlab = {'A','B'};
%   vlab = {'a';'b';'c';'d';'e'};
%   OUT = TabPrint(x,hlab,vlab)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Read size of DATA and set defaults for all optional arguments
[n, m] = size(DATA);

% Default to empty headers if hlabel is not supplied
if ~exist('hlabel','var') || isempty(hlabel)
    hlabel = cell(1,m);
end

% Default to empty row labels if vlabel is not supplied
if ~exist('vlabel','var') || isempty(vlabel)
    vlabel = cell(n,1);
end

% Default to two decimal places if approx is not supplied
if ~exist('approx','var')
    approx = 2;
end

% Validate that hlabel has exactly one entry per column
if length(hlabel)~=m
    error('TabPrint: hlabel must have one entry per column of DATA (%d expected, %d supplied)', m, length(hlabel))
end

% Validate that vlabel has exactly one entry per row
if length(vlabel)~=n
    error('TabPrint: vlabel must have one entry per row of DATA (%d expected, %d supplied)', n, length(vlabel))
end

%% 2. ASSEMBLE LABELLED TABLE
% -----------------------------------------------------------------------
% Convert numbers to strings with approx decimal places
OUT = roundnum2cell(DATA,approx);

% Prepend column headers above the data
OUT = [hlabel ; OUT];

% Build a 1×1 blank cell for the top-left corner: rows(hlabel)=1 (one header
% row) and cols(vlabel)=1 (one label column), so aux is always a single cell.
aux = cell(rows(hlabel),cols(vlabel));
vlabel = [aux; vlabel];

% Prepend row labels on the left
OUT = [vlabel, OUT];
