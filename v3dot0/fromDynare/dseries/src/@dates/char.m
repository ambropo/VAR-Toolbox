function s = char(o) % --*-- Unitary tests --*--

% Given a one element dates object, returns a string with the formatted date.
%
% INPUTS
% - o  [dates]
%
% OUTPUTS
% - s  [string]

% Copyright © 2014-2020 Dynare Team
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

if length(o)>1
    error('dates:char:ArgCheck', 'The input argument must be a dates object with one element!')
end

s = date2string(o.time, o.freq);

return

%@test:1
% Define a dates object
o = dates('1950Q1');

% Call the tested routine.
try
    str = char(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str,'1950Q1');
end
T = all(t);
%@eof:1

%@test:2
% Define a dates object
o = dates('1950M1');

% Call the tested routine.
try
    str = char(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str,'1950M1');
end
T = all(t);
%@eof:2

%@test:3
% Define a dates object
o = dates('2020-10-01');

% Call the tested routine.
try
    str = char(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str,'2020-10-01');
end
T = all(t);
%@eof:3

%@test:4
% Define a dates object
o = dates('1950Y');

% Call the tested routine.
try
    str = char(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str,'1950Y');
end
T = all(t);
%@eof:4

%@test:5
% Define a dates object
o = dates('1950A');

% Call the tested routine.
try
    str = char(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str,'1950Y');
end
T = all(t);
%@eof:5