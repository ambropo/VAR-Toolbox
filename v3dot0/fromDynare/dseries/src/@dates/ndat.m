function s = ndat(o) % --*-- Unitary tests --*--

% Given a one element dates object, returns a string with the formatted date.
%
% INPUTS
% - o  [dates]
%
% OUTPUTS
% - s  [integer]

% Copyright © 2015-2021 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

s = length(o.time);

return

%@test:1
% Define a dates object
o = dates('1950Q1'):dates('1952Q1');

% Call the tested routine.
try
    card = ndat(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = dassert(card,9);
end
T = all(t);
%@eof:1

%@test:2
% Define a dates object
o = dates('1950M1'):dates('1951M6');

% Call the tested routine.
try
    card = ndat(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = dassert(card,18);
end
T = all(t);
%@eof:2

%@test:3
% Define a dates object
o = dates('1950Y'):dates('1959Y');

% Call the tested routine.
try
    card = ndat(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = dassert(card,10);
end
T = all(t);
%@eof:3