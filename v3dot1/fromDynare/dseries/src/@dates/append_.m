function o = append_(o, d) % --*-- Unitary tests --*--

% append method for dates class (in place modification).
%
% INPUTS
% - o [dates]
% - d [dates,char]  date to be appended (if not a dates object, it must be a row char array that can be interpreted as a date).
%
% OUTPUTS
% - o [dates] dates object containing dates defined in o and d.

% Copyright © 2012-2021 Dynare Team
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

if isa(d, 'dates')
    if ~isequal(length(d), 1)
        error('dates:append_:ArgCheck','Input argument %s has to be a dates object with one element.', inputname(2))
    end
    if isempty(d)
        return
    end
elseif isdate(d)
    d = dates(d);
end

if ~isequal(o.freq, d.freq)
    error('dates:append_:ArgCheck','dates must have common frequency!')
end

o.time = [o.time; d.time];

return

%@test:1
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950Q1';
B4 = '1945Q3';
B5 = '2009Q2';

% Define expected results.
e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
e.freq = 4;

% Call the tested routine.
d = dates(B4,B3,B2,B1);
try
    d.append_(dates(B5));
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(d.time,e.time);
    t(3) = isequal(d.freq,e.freq);
end
T = all(t);
%@eof:1

%@test:2
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950Q1';
B4 = '1945Q3';
B5 = '2009Q2';

% Define expected results.
e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
e.freq = 4;

% Call the tested routine.
d = dates(B4,B3,B2,B1);
try
    d.append_(B5);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(d.time,e.time);
    t(3) = isequal(d.freq,e.freq);
end
T = all(t);
%@eof:2

%@test:3
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950Q1';
B4 = '1945Q3';
B5 = '2009Q2';

% Define expected results.
e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
e.freq = 4;

% Call the tested routine.
d = dates(B4,B3,B2,B1);
try
    c = d.append_(B5);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(d.time,e.time);
    t(3) = isequal(c.time,e.time);
    t(4) = isequal(d.freq,e.freq);
    t(5) = isequal(c.freq,e.freq);
end
T = all(t);
%@eof:3


%@test:4
% Define some dates
B1 = '1953Q4';
B2 = '1950Q2';
B3 = '1950Q1';
B4 = '1945Q3';
B5 = '2009Q2';

% Call the tested routine.
d = dates(B4,B3);
e = dates(B1,B2,B5);
try
    d.append_(e);
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:4

%@test:5
% Define some dates
B = '1950Q2';

% Call the tested routine.
d = dates(B);
try
    d.append_('1950Q3');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(d.time, [1950*4+2; 1950*4+3]);
end

T = all(t);
%@eof:5

%@test:6
% Define some dates
B = '1950Q2';

% Call the tested routine.
d = dates(B);
try
    d.append_('1950Z3');
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:6

%@test:7
% Define some dates
B1 = '2020-01-01';
B2 = '2020-01-02';
B3 = '2020-01-03';
B4 = '2020-01-04';
B5 = '2020-01-05';

% Call the tested routine.
d = dates(B4,B3);
e = dates(B1,B2,B5);
try
    d.append_(e);
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:7

%@test:8
% Define some dates
B1 = '2020-01-01';
B2 = '2020-01-02';
B3 = '2020Q1';

% Call the tested routine.
d = dates(B1,B2);
e = dates(B3);
try
    d.append_(e);
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:8