function y = dates2Y(d) % --*-- Unitary tests --*--

% INPUTS
% - d   [dates]    daily, monthly, qarterly or bi-annual frequency object with n elements.
%
% OUTPUTS
% - y   [dates]    annual frequency object with n elements (with repetitions).

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
elseif ismember(d.freq, [2,4,12])
    time = floor((d.time-1)/d.freq);
elseif d.freq==1
    y = d;
    return
else
    error('Unknown frequency.')
end

y = dates(1, time(:,1));

return

%@test:1
try
    m = dates2Y(dates('1938-11-22'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(m, dates('1938Y'));
end

T = all(t);
%@eof:1

%@test:2
try
    m = dates2Y(dates('1938M11'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(m, dates('1938Y'));
end

T = all(t);
%@eof:2

%@test:3
try
    m = dates2Y(dates('1938S2'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(m, dates('1938Y'));
end

T = all(t);
%@eof:3

%@test:4
try
    m = dates2Y(dates('1938Y'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(m, dates('1938Y'));
end

T = all(t);
%@eof:4