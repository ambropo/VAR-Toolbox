function B = isfreq(A) % --*-- Unitary tests --*--

% Tests if A can be interpreted as a frequency.
%
% INPUTS
% - A     [integer, char]  scalar, frequency code.
%
% OUTPUTS
% - B     [logical]        scalar equal to true iff A can be interpreted as a frequency.

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

B = false;

if ischar(A)
    if isequal(length(A),1) && ismember(upper(A),{'Y','A', 'H', 'Q', 'M', 'D'})
        B = true;
        return
    end
end

if isnumeric(A) && isequal(length(A),1) && ismember(A,[1 2 4 12 52 365])
    B = true;
end

return

%@test:1
try
    b = isfreq('M') && isfreq(12);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = b;
end

T = all(t);
%@eof:1

%@test:2
try
    b = isfreq('Q') && isfreq(4);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = b;
end

T = all(t);
%@eof:2

%@test:3
try
    b = isfreq('Y') && isfreq(1);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = b;
end

T = all(t);
%@eof:3

%@test:4
try
    b = isfreq('H') && isfreq(2);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = b;
end

T = all(t);
%@eof:4

%@test:5
try
    b = isfreq('D') && isfreq(365);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = b;
end

T = all(t);
%@eof:5