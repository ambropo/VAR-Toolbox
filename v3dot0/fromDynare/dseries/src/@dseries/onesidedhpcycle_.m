function o = onesidedhpcycle_(o, lambda, init) % --*-- Unitary tests --*--

% Extracts the cycle component from a dseries object using a one sided HP filter.
%
% INPUTS
% - o         [dseries]   Original time series.
% - lambda    [double]    scalar, trend smoothness parameter.
%
% OUTPUTS
% - o         [dseries]   Cycle component of the original time series.

% Copyright (C) 2017 Dynare Team
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

if nargin>1
    if lambda<=0
        error('dseries::onesidedhpcycle: Lambda must be a positive integer!')
    end
    if nargin>2
        if ~isequal(init, 'hpfilter')
            error('dseries::onesidedhpcycle: Unknown option!')
        end
    end
else
    lambda = [];
end

for i=1:vobs(o)
    if isempty(o.ops{i})
        if isempty(lambda)
            if nargin>2
                o.ops(i) = {sprintf('onesidedhpcycle(%s, [], ''%s'')', o.name{i}, init)};
            else
                o.ops(i) = {sprintf('onesidedhpcycle(%s, [])', o.name{i})};
            end
        else
            if nargin>2
                o.ops(i) = {sprintf('onesidedhpcycle(%s, %s, ''%s'')', o.name{i}, num2str(lambda), init)};
            else
                o.ops(i) = {sprintf('onesidedhpcycle(%s, %s)', o.name{i}, num2str(lambda))};
            end
        end
    else
        if isempty(lambda)
            if nargin>2
                o.ops(i) = {sprintf('onesidedhpcycle(%s, [], ''%s'')', o.ops{i}, init)};
            else
                o.ops(i) = {sprintf('onesidedhpcycle(%s, [])', o.ops{i})};
            end
        else
            if nargin>2
                o.ops(i) = {sprintf('onesidedhpcycle(%s, %s, ''%s'')', o.ops{i}, num2str(lambda), init)};
            else
                o.ops(i) = {sprintf('onesidedhpcycle(%s, %s)', o.ops{i}, num2str(lambda))};
            end
        end
    end
end

if nargin>2
    trend = o.hptrend(lambda);
    x0 = trend.data(1:2,:);
    [~, o.data] = one_sided_hp_filter(o.data, lambda, x0);
else    
    [~, o.data] = one_sided_hp_filter(o.data, lambda);
end

return

%@test:1
e = .2*randn(200,1);
u = randn(200,1);
stochastic_trend = cumsum(e);
deterministic_trend = .1*transpose(1:200);
x = zeros(200,1);
for i=2:200
    x(i) = .75*x(i-1) + e(i);
end
y = x + stochastic_trend + deterministic_trend;

try
    ts0 = dseries(y,'1950Q1');
    ts0.onesidedhpcycle_(1600);
    t(1) = 1;
catch
    t(1) = 0;
end

T = all(t);
%@eof:1

%@test:2
e = .2*randn(200,2);
u = randn(200,2);
stochastic_trends = cumsum(e);
deterministic_trends = transpose(1:200)*[.1, -.2];
x = zeros(200,2);
for i=2:200
    x(i, 1) = .75*x(i-1, 1) + e(i, 1);
    x(i, 2) = -.10*x(i-1, 2) + e(i, 2);
end
y = x + stochastic_trends + deterministic_trends;

try
    ts0 = dseries(y,'1950Q1');
    ts0.onesidedhpcycle_(1600);
    t(1) = 1;
catch
    t(1) = 0;
end

T = all(t);
%@eof:2