function m = strings(o) % --*-- Unitary tests --*--

% Returns a cell array of strings containing the dates
%
% INPUTS
% - o [dates]        object with n elements.
%
% OUTPUTS
% - m [cell of char] object with n elements.

% Copyright © 2013-2021 Dynare Team
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

m = cell(1, o.ndat());

for i = 1:o.length()
    m(i) = { date2string(o.time(i), o.freq) };
end

return

%@test:1
% Define a dates objects
d = dates('1950Q1'):dates('1950Q3');

% Call the tested routine.
try
    m = strings(d);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = iscell(m);
    t(3) = dassert(m{1}, '1950Q1');
    t(4) = dassert(m{2}, '1950Q2');
    t(5) = dassert(m{3}, '1950Q3');
    t(6) = dassert(length(m), 3);
end

T = all(t);
%@eof:1


%@test:2
% Define a dates objects
d = dates('2000-01-01'):dates('2000-01-03');

% Call the tested routine.
try
    m = strings(d);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = iscell(m);
    t(3) = dassert(m{1}, '2000-01-01');
    t(4) = dassert(m{2}, '2000-01-02');
    t(5) = dassert(m{3}, '2000-01-03');
    t(6) = dassert(length(m), 3);
end

T = all(t);
%@eof:2