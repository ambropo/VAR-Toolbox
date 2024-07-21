function o = uplus(o)  % --*-- Unitary tests --*--

% Overloads the unary plus operator for dates objects. Shifts all the elements by one period.
%
% INPUTS
% - o [dates]
%
% OUTPUTS
% - o [dates]

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

o.time = o.time+1;

return

%@test:1
% Define some dates
date_1 = '1950Y';
date_2 = '1950Q2';
date_3 = '1950Q4';
date_4 = '1950M2';
date_5 = '1950M12';

% Call the tested routine.
try
    d1 = dates(date_1); +d1;
    d2 = dates(date_2); +d2;
    d3 = dates(date_3); +d3;
    d4 = dates(date_4); +d4;
    d5 = dates(date_5); +d5;
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = (d1==dates('1951Y'));
    t(3) = (d2==dates('1950Q3'));
    t(4) = (d3==dates('1951Q1'));
    t(5) = (d4==dates('1950M3'));
    t(6) = (d5==dates('1951M1'));
end

T = all(t);
%@eof:1

%@test:2
d1 = dates('1950Q1','1950Q2','1950Q3','1950Q4','1951Q1');
d2 = dates('1950Q2','1950Q3','1950Q4','1951Q1','1951Q2');
try
  +d1;
  t(1) = true;
catch
  t(1) = false;
end

if t(1)
  t(2) = isequal(d2, d1);
end

T = all(t);
%@eof:2

%@test:3
d1 = dates('2001-02-27','2001-02-28','2001-12-31');
d2 = dates('2001-02-28','2001-03-01','2002-01-01');
try
  +d1;
  t(1) = true;
catch
  t(1) = false;
end

if t(1)
  t(2) = isequal(d2, d1);
end

T = all(t);
%@eof:3