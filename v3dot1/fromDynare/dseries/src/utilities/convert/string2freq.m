function freq = string2freq(s) % --*-- Unitary tests --*--

% INPUTS
% - s        [char]     scalar equal to Y, H, Q, M, or D (resp. annual, bi-annual, quaterly, monthly, or daily)
%
% OUTPUTS
% - freq     [integer]  scalar equal to 1, 2, 4, 12, or 365 (resp. annual, bi-annual, quaterly, monthly, or daily)

% Copyright © 2013-2020 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

switch upper(s)
  case {'Y','A'}
    freq = 1;
  case 'H'
    freq = 2;
  case 'Q'
    freq = 4;
  case 'M'
    freq = 12;
  case 'D'
    freq = 365;
  otherwise
    error('dates::freq2string: Unknown frequency!')
end

return

%@test:1
try
    nY = string2freq('Y');
    nH = string2freq('H');
    nQ = string2freq('Q');
    nM = string2freq('M');
    nD = string2freq('D');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(nY, 1);
    t(3) = isequal(nH, 2);
    t(4) = isequal(nQ, 4);
    t(5) = isequal(nM, 12);
    t(6) = isequal(nD, 365);
end

T = all(t);
%@eof:1

%@test:2
try
    n = string2freq('Z');
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:2
