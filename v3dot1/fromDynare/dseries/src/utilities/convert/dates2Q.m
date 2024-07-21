function m = dates2Q(d)  % --*-- Unitary tests --*--

% INPUTS
% - d   [dates]    daily, monthly or quarterly frequency object with n elements.
%
% OUTPUTS
% - q   [dates]    quaterly frequency object with n elements (with repetitions).

% Copyright © 2020 Dynare Team
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
    time = datevec(d.time(:,1));
elseif d.freq==12
    y = floor((d.time-1)/d.freq);
    s = d.time-y*d.freq;
    time = [y, s];
elseif d.freq==4
    m = d;
    return
else
    error('Cannot convert to higher frequency.')
end

isq1 = arrayfun( @(m) ismember(m, [1, 2, 3]), time(:,2));
isq2 = arrayfun( @(m) ismember(m, [4, 5, 6]), time(:,2));
isq3 = arrayfun( @(m) ismember(m, [7, 8, 9]), time(:,2));
isq4 = arrayfun( @(m) ismember(m, [10, 11, 12]), time(:,2));

time(isq1,2) = 1;
time(isq2,2) = 2;
time(isq3,2) = 3;
time(isq4,2) = 4;

m = dates(4, time(:,1:2));

return

%@test:1
try
    m = dates2Q(dates('1938-11-22'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(m, dates('1938Q4'));
end

T = all(t);
%@eof:1

%@test:2
try
    m = dates2Q(dates('1938M11'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(m, dates('1938Q4'));
end

T = all(t);
%@eof:2

%@test:3
try
    m = dates2Q(dates('1938Q4'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(m, dates('1938Q4'));
end

T = all(t);
%@eof:3

%@test:4
try
    m = dates2Q(dates('1938S2'));
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:4