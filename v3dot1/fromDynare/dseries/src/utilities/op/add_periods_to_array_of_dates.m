function time = add_periods_to_array_of_dates(time, freq, p)  % --*-- Unitary tests --*--

% Adds a p periods (p can be negative) to a date (or a set of dates) characterized by array time and frequency freq.

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

if isequal(rows(time),1) && length(p)>1
    time = repmat(time,length(p),1);
end

if freq==365
    time(:,1) = time(:,1) + p;
    return
end

time(:,1) = time(:,1) + fix(p/freq);
time(:,2) = time(:,2) + rem(p,freq);

id1 = find(time(:,2)>freq);
if ~isempty(id1)
    time(id1,1) = time(id1,1) + 1;
    time(id1,2) = time(id1,2) - freq;
end

id2 = find(time(:,2)<1);
if ~isempty(id2)
    time(id2,1) = time(id2,1) - 1;
    time(id2,2) = time(id2,2) + freq;
end

return

%@test:1
t(1) = isequal(add_periods_to_array_of_dates([1950 1], 4, 1),[1950 2]);
t(2) = isequal(add_periods_to_array_of_dates([1950 1], 4, 2),[1950 3]);
t(3) = isequal(add_periods_to_array_of_dates([1950 1], 4, 3),[1950 4]);
t(4) = isequal(add_periods_to_array_of_dates([1950 1], 4, 4),[1951 1]);
t(5) = isequal(add_periods_to_array_of_dates([1950 1], 4, 5),[1951 2]);
t(6) = isequal(add_periods_to_array_of_dates([1950 1], 4, 6),[1951 3]);
t(7) = isequal(add_periods_to_array_of_dates([1950 1], 4, 7),[1951 4]);
t(8) = isequal(add_periods_to_array_of_dates([1950 1], 4, 8),[1952 1]);
T = all(t);
%@eof:1

%@test:2
t(1) = isequal(add_periods_to_array_of_dates(repmat([1950 1],8,1), 4, transpose(1:8)),[1950 2; 1950 3; 1950 4; 1951 1; 1951 2; 1951 3; 1951 4; 1952 1]);
T = all(t);
%@eof:2

%@test:3
t(1) = isequal(add_periods_to_array_of_dates([1950 1], 1, 1),[1951 1]);
T = all(t);
%@eof:3

%@test:4
t(1) = isequal(add_periods_to_array_of_dates([1950 1; 1950 2; 1950 3; 1950 4], 4, 1),[1950 2; 1950 3; 1950 4; 1951 1]);
T = all(t);
%@eof:4

%@test:5
t(1) = isequal(add_periods_to_array_of_dates([1950 1], 4, transpose(1:8)),[1950 2; 1950 3; 1950 4; 1951 1; 1951 2; 1951 3; 1951 4; 1952 1]);
T = all(t);
%@eof:5

%@test:6
t(1) = isequal(add_periods_to_array_of_dates([1950 1], 4, -1),[1949 4]);
t(2) = isequal(add_periods_to_array_of_dates([1950 1], 4, -2),[1949 3]);
t(3) = isequal(add_periods_to_array_of_dates([1950 1], 4, -3),[1949 2]);
t(4) = isequal(add_periods_to_array_of_dates([1950 1], 4, -4),[1949 1]);
t(5) = isequal(add_periods_to_array_of_dates([1950 1], 4, -5),[1948 4]);
t(6) = isequal(add_periods_to_array_of_dates([1950 1], 4, -6),[1948 3]);
t(7) = isequal(add_periods_to_array_of_dates([1950 1], 4, -7),[1948 2]);
t(8) = isequal(add_periods_to_array_of_dates([1950 1], 4, -8),[1948 1]);
T = all(t);
%@eof:6