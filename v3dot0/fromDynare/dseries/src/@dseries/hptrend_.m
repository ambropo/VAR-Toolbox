function o = hptrend_(o, lambda) % --*-- Unitary tests --*--

% Extracts the trend component from a dseries object using Hodrick Prescott filter.
%
% INPUTS
% - o         [dseries]   Original time series.
% - lambda    [double]    scalar, trend smoothness parameter.
%
% OUTPUTS
% - o         [dseries]   Trend component of the original time series.

% Copyright (C) 2013-2021 Dynare Team
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
        error(['dseries::hptrend: Lambda must be a positive integer!'])
    end
else
    lambda = [];
end

o.data = sample_hp_filter(o.data, lambda);

for i=1:vobs(o)
    if isempty(o.ops{i})
        if isempty(lambda)
            o.ops(i) = {sprintf('hptrend(%s, [])', o.name{i})};
        else
            o.ops(i) = {sprintf('hptrend(%s, %s)', o.name{i}, num2str(lambda))};
        end
    else
        if isempty(lambda)
            o.ops(i) = {sprintf('hptrend(%s, [])', o.name{i})};
        else
            o.ops(i) = {sprintf('hptrend(%s, %s)', o.name{i}, num2str(lambda))};
        end
    end
end


%@test:1
%$ plot_flag = 0;
%$
%$ % Create a dataset.
%$ e = .2*randn(200,1);
%$ u = randn(200,1);
%$ stochastic_trend = cumsum(e);
%$ deterministic_trend = .1*transpose(1:200);
%$ x = zeros(200,1);
%$ for i=2:200
%$    x(i) = .75*x(i-1) + e(i);
%$ end
%$ y = x + stochastic_trend + deterministic_trend;
%$
%$ % Test the routine.
%$ try
%$     ts0 = dseries(y,'1950Q1');
%$     ts1 = dseries(stochastic_trend+deterministic_trend,'1950Q1');
%$     ts0.hptrend(1600);
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts0.freq,4);
%$     t(3) = dassert(ts0.init.freq,4);
%$     t(4) = dassert(ts0.init.time,1950*4+1);
%$     t(5) = dassert(ts0.vobs,1);
%$     t(6) = dassert(ts0.nobs,200);
%$ end
%$
%$ % Show results
%$ if plot_flag
%$     plot(ts1.data,'-k'); % Plot of the stationary component.
%$     hold on
%$     plot(ts2.data,'--r');          % Plot of the filtered y.
%$     hold off
%$     axis tight
%$     id = get(gca,'XTick');
%$     set(gca,'XTickLabel',strings(ts1.dates(id)));
%$     legend({'Nonstationary component of y', 'Estimated trend of y'})
%$     print('-depsc2','../doc/dynare.plots/HPTrend.eps')
%$     system('convert -density 300 ../doc/dynare.plots/HPTrend.eps ../doc/dynare.plots/HPTrend.png');
%$     system('convert -density 300 ../doc/dynare.plots/HPTrend.eps ../doc/dynare.plots/HPTrend.pdf');
%$     system('convert -density 300 ../doc/dynare.plots/HPTrend.eps ../doc/dynare.plots/HPTrend.jpg');
%$ end
%$ T = all(t);
%@eof:1