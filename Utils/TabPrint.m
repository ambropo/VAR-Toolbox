function OUT = TabPrint(DATA,hlabel,vlabel,approx)
% =======================================================================
% Prints a numerical table with labels, with specified numbers of decimal
% digits
% =======================================================================
% OUT = TabPrint(DATA,hlabel,vlabel,approx)
% -----------------------------------------------------------------------
% INPUT
%   - DATA   = a (n x m) matrix of numbers
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%	- hlabel = a (m x 1) vector of horizontal labels 
%	- vlabel = a (1 x n) vector of vertical labels 
%   - approx = number of decimal digits. Default = 2
%--------------------------------------------------------------------------
% OUTPUT
%   - OUT    = a cell array with the formatted table
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

[n, m] = size(DATA);

if ~exist('hlabel','var') || isempty(hlabel)
    hlabel = cell(1,m);
end

if ~exist('vlabel','var') || isempty(vlabel)
    vlabel = cell(n,1);
end

if ~exist('approx','var')
    approx = 2; 
end

if length(hlabel)~=m
    error('ERROR: horizontal label has wrong dimension')
end

if length(vlabel)~=n
    error('ERROR: vertical label has wrong dimension')
end

OUT = roundnum2cell(DATA,approx); % Trasform matrix in cell wih approx decimal digits

OUT = [hlabel ; OUT];
aux = cell(rows(hlabel),cols(vlabel));
vlabel = [aux; vlabel];
OUT = [vlabel, OUT];