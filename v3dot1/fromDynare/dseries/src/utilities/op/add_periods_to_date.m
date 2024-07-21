function time = add_periods_to_date(time, freq, p)  % --*-- Unitary tests --*--

% Adds a p periods (p can be negative) to a date (or a set of dates) characterized by array time and frequency freq.

% Copyright (C) 2013-2017 Dynare Team
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

if freq==365
    time(1) = time(1)+p;
end

time(1) = time(1) + fix(p/freq);
time(2) = time(2) + rem(p,freq);

if time(2)>freq
    time(1) = time(1) + 1;
    time(2) = time(2) - freq;
end

if time(2)<1
    time(1) = time(1) - 1;
    time(2) = time(2) + freq;
end

return

%@test:1
t(1) = dassert(add_periods_to_date([1950 1], 4, 1),[1950 2]);
t(2) = dassert(add_periods_to_date([1950 1], 4, 2),[1950 3]);
t(3) = dassert(add_periods_to_date([1950 1], 4, 3),[1950 4]);
t(4) = dassert(add_periods_to_date([1950 1], 4, 4),[1951 1]);
t(5) = dassert(add_periods_to_date([1950 1], 4, 5),[1951 2]);
t(6) = dassert(add_periods_to_date([1950 1], 4, 6),[1951 3]);
t(7) = dassert(add_periods_to_date([1950 1], 4, 7),[1951 4]);
t(8) = dassert(add_periods_to_date([1950 1], 4, 8),[1952 1]);
T = all(t);
%@eof:1

%@test:2
t(1) = dassert(add_periods_to_date([1950 1], 4, -1),[1949 4]);
t(2) = dassert(add_periods_to_date([1950 1], 4, -2),[1949 3]);
t(3) = dassert(add_periods_to_date([1950 1], 4, -3),[1949 2]);
t(4) = dassert(add_periods_to_date([1950 1], 4, -4),[1949 1]);
t(5) = dassert(add_periods_to_date([1950 1], 4, -5),[1948 4]);
t(6) = dassert(add_periods_to_date([1950 1], 4, -6),[1948 3]);
t(7) = dassert(add_periods_to_date([1950 1], 4, -7),[1948 2]);
t(8) = dassert(add_periods_to_date([1950 1], 4, -8),[1948 1]);
T = all(t);
%@eof:2