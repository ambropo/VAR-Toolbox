function o = sort_(o) % --*-- Unitary tests --*--

% Sort method for dates class (in place modification).
%
% INPUTS
% - o [dates]
%
% OUTPUTS
% - o [dates] with dates sorted by increasing order.

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

if isequal(o.ndat(),1)
    return
end

o.time = sort(o.time);

return

%@test:1
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950Q1';
B4 = '1945Q3';

% Define expected results.
e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4];
e.freq = 4;

% Call the tested routine.
d = dates(B1,B2,B3,B4);
try
    d.sort_();
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = dassert(d.time,e.time);
    t(3) = dassert(d.freq,e.freq);
end
T = all(t);
%@eof:1

%@test:2
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950Q1';
B4 = '1945Q3';

% Define expected results.
e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4];
e.freq = 4;

% Call the tested routine.
d = dates(B1,B2,B3,B4);
try
    c = sort_(d);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = dassert(d.time,e.time);
    t(3) = dassert(d.freq,e.freq);
end
T = all(t);
%@eof:2

%@test:3
d = dates('2000-01-01', '2001-01-01', '1999-01-02');
try
    d.sort_();
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(d,dates('1999-01-02', '2000-01-01', '2001-01-01'));
end
T = all(t);
%@eof:3