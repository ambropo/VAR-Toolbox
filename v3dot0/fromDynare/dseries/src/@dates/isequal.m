function l = isequal(o, p, fake) % --*-- Unitary tests --*--

% Overloads isequal function for dates objects. Returns true true iff o and p have the same elements.
%
% INPUTS
% - o [dates]
% - p [dates]
%
% OUTPUTS
% - l [logical]

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

if ~isa(o, 'dates') || ~isa(p, 'dates')
    error('dates:isequal:ArgCheck', 'Both inputs must be dates objects!')
end

l = isequal(o.freq, p.freq) && isequal(o.time, p.time);

return

%@test:1
d1 = dates('1938Q1');
d2 = dates('1938Q1');
% Test if this object is empty
try
    t(1) = isequal(d1, d2);
catch
    t(1) = false;
end
T = all(t);
%@eof:1

%@test:2
d1 = dates('1938Q1');
d2 = dates('1938Q2');
% Test if this object is empty
try
    t(1) = ~isequal(d1,d2);
catch
    t(1) = false;
end
T = all(t);
%@eof:2

%@test:3
d1 = dates('1938Q4');
d2 = dates('1938M11');
% Test if this object is empty
try
    t(1) = ~isequal(d1,d2);
catch
    t(1) = false;
end
T = all(t);
%@eof:3

%@test:4
d1 = dates('1938Q4','1938Q3');
d2 = dates('1938Q3','1938Q1');
% Test if this object is empty
try
    t(1) = ~isequal(d1,d2);
catch
    t(1) = false;
end
T = all(t);
%@eof:4

%@test:5
d1 = dates('1938Q4','1938Q3','1938Q2');
d2 = dates('1938Q3','1938Q1');
% Test if this object is empty
try
    t(1) = ~isequal(d1,d2);
catch
    t(1) = false;
end
T = all(t);
%@eof:5

%@test:6
d1 = dates('1938-11-22');
d2 = dates('1945-09-01');
% Test if this object is empty
try
    t(1) = ~isequal(d1,d2);
catch
    t(1) = false;
end
T = all(t);
%@eof:6
