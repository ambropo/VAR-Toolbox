function o = unique(o) % --*-- Unitary tests --*--

% Overloads the unique function for dates objects.
%
% INPUTS
% - o [dates]
%
% OUPUTS
% - o [dates]
%
% REMARKS
% 1. Only the last occurence of a date is kept.

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

if o.ndat()<=1
    return
end

o = copy(o);
o.unique_();

return

%@test:1
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950q1';
B4 = '1945Q3';
B5 = '1950Q2';

% Define expected results.
e.time = [1953*4+4; 1950*4+1; 1945*4+3; 1950*4+2];
e.freq = 4;
f.time = [1953*4+4; 1950*4+2; 1950*4+1; 1945*4+3; 1950*4+2];

% Call the tested routine.
d = dates(B1, B2, B3, B4, B5);
try
    c = d.unique();
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = dassert(d.time,f.time);
    t(3) = dassert(c.time,e.time);
    t(4) = dassert(d.freq,e.freq);
end
T = all(t);
%@eof:1

%@test:2
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950q1';
B4 = '1945Q3';
B5 = '1950Q2';

% Define expected results.
e.time = [1953*4+4; 1950*4+1; 1945*4+3; 1950*4+2];
e.freq = 4;
f.time = [1953*4+4; 1950*4+2; 1950*4+1; 1945*4+3; 1950*4+2];

% Call the tested routine.
d = dates(B1,B2,B3,B4,B5);
try
    c = unique(d);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = dassert(d.time,f.time);
    t(3) = dassert(c.time,e.time);
    t(4) = dassert(d.freq,e.freq);
end
T = all(t);
%@eof:2

%@test:3
% Define some dates
B1 = '1953Q4';

% Define expected results.
e.time = 1953*4+4;
e.freq = 4;
f.time = e.time;

% Call the tested routine.
d = dates(B1);
try
    c = d.unique();
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = dassert(d.time,f.time);
    t(3) = dassert(c.time,e.time);
    t(4) = dassert(d.freq,e.freq);
end
T = all(t);
%@eof:3

%@test:4
% Define some dates
d1 = [dates('2000-01-01'), dates('2000-01-02'), dates('2000-01-01')];

% Call the tested routine.
try
    d2 = d1.unique();
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(d2, dates('2000-01-02', '2000-01-01'));
end
T = all(t);
%@eof:4