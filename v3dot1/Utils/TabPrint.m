function OUT = TabPrint(DATA,hlabel,vlabel,approx)
% =======================================================================
% Prints a numerical table with labels, with specified numbers of decimal
% digits
% =======================================================================
% OUT = TabPrint(DATA,hlabel,vlabel,approx)
% -----------------------------------------------------------------------
% INPUT
%   - DATA = a (TxN) matrix of numbers
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%	- hlabel = a (Tx1) vector of horizontal labels 
%	- vlabel = a (1xT) vector of vertical labels 
%   - approx = number of decimal digits. Default = 2
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT = a cell array with the formatted table
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   hlab = {'a';'b';'c';'d';'e';}
%   vlab = {'A','B'}
%   OUT = TabPrint(x,hlab,vlab)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

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