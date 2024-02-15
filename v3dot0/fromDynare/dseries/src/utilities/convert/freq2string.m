function s = freq2string(freq) % --*-- Unitary tests --*--

% INPUTS
% - freq  [integer]   scalar equal to 1, 2, 4, 12, or 365 (resp. annual, bi-annual, quaterly, monthly, or daily)
%
% OUTPUTS
% - s     [char]      scalar equal to Y, S, Q, M, or D (resp. annual, bi-annual, quaterly, monthly, or daily)

% Copyright © 2013-2021 Dynare Team
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

switch freq
  case 1
    s = 'Y';
  case 2
    s = 'S';
  case 4
    s = 'Q';
  case 12
    s = 'M';
  case 365
    s = 'D';
  otherwise
    error('dates::freq2string: Unknown frequency!')
end

return

%@test:1
try
    strY = freq2string(1);
    strH = freq2string(2);
    strQ = freq2string(4);
    strM = freq2string(12);
    strD = freq2string(365);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(strY, 'Y');
    t(3) = isequal(strH, 'S');
    t(4) = isequal(strQ, 'Q');
    t(5) = isequal(strM, 'M');
    t(6) = isequal(strD, 'D');
end

T = all(t);
%@eof:1

%@test:2
try
    str = freq2string(13);
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:2
