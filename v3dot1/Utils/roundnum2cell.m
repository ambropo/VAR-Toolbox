function OUT = roundnum2cell(DATA,approx)
% =======================================================================
% Trasform numerical matrix in cell wih approx decimal digits
% =======================================================================
% OUT = roundnum2cell(DATA,approx)
% -----------------------------------------------------------------------
% INPUT
%   - DATA = a (n x m) matrix of numbers
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - approx = number of decimal digits. Default = 2
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT = a cell matrix with desired number of decimal digits
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   OUT = roundnum2cell(x,2)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

% Preliminaries
if ~exist('approx','var')
    approx = 2;
end

% Preallocate 
OUT = cell(size(DATA));

% Create cell matrix
for i=1:numel(DATA)
    XX = DATA(i);
    YY = round(XX,approx); % Approx. the number 
    ZZ = sprintf(['%0.' num2str(approx) 'f'], YY); % Convert it to string
    OUT{i} = ZZ;
end 

