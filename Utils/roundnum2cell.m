function OUT = roundnum2cell(DATA,approx)
% =====================================================================
% Convert a numeric matrix to a cell array of fixed-decimal strings
% =====================================================================
% OUT = roundnum2cell(DATA,approx)
% ---------------------------------------------------------------------
% INPUT
%   - DATA: numeric matrix to convert [n x m double]
% ---------------------------------------------------------------------
% OPTIONAL INPUT
%   - approx: number of decimal digits to retain [dflt = 2]
% ---------------------------------------------------------------------
% OUTPUT
%   - OUT: cell array of strings with the requested decimal precision
%          [n x m cell]
% ---------------------------------------------------------------------
% EXAMPLE
%   DATA = randn(4,3);
%   OUT  = roundnum2cell(DATA, 3);
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. CHECK INPUTS
% ---------------------------------------------------------------------
% Set default decimal precision if the optional argument is not supplied.
if ~exist('approx','var')
    approx = 2;
end

%% 2. CONVERT EACH ELEMENT TO A FIXED-DECIMAL STRING
% ---------------------------------------------------------------------
% Pre-compute the format string once; sprintf handles rounding internally.
fmt = ['%0.' num2str(approx) 'f'];
OUT = cell(size(DATA));
for i=1:numel(DATA)
    OUT{i} = sprintf(fmt, DATA(i));
end
