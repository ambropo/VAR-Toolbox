function y = year(d)  % --*-- Unitary tests --*--

% Returns the year.

% Copyright © 2016-2021 Dynare Team
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

if d.freq==365
    tmp = datevec(d.time(1));
    y = tmp(1);
    return
end

if d.freq>1
    y = floor((d.time-1)/d.freq);
else
    y = d.time;
end

return

%@test:1
try
    y = year(dates('2020-01-01'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = y==2020;
end

T = all(t);
%@eof:1

%@test:2
try
    y = year(dates('1938-11-22'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = y==1938;
end

T = all(t);
%@eof:2

%@test:3
try
    y = year(dates('2020S2'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = y==2020;
end

T = all(t);
%@eof:3

%@test:4
try
    y = year(dates('2020Q1'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = y==2020;
end

T = all(t);
%@eof:4

%@test:5
try
    y = year(dates('2019M3'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = y==2019;
end

T = all(t);
%@eof:5