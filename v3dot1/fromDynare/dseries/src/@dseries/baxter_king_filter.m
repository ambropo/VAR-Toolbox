function o = baxter_king_filter(o, high_frequency, low_frequency, K) % --*-- Unitary tests --*--

% Implementation of Baxter and King (1999) band pass filter for dseries objects. The code is adapted from
% the one provided by Baxter and King. This filter isolates business cycle fluctuations with a period of length
% ranging between high_frequency to low_frequency (quarters).
%
% INPUTS
%  - o                  dseries object.
%  - high_frequency     positive scalar, period length (default value is 6).
%  - low_frequency      positive scalar, period length (default value is 32).
%  - K                  positive scalar integer, truncation parameter (default value is 12).
%
% OUTPUTS
%  - o                  dseries object.
%
% REMARKS
% This filter use a (symmetric) moving average smoother, so that K observations at the beginning and at the end of the
% sample are lost in the computation of the filter.

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

if nargin<4 || isempty(K)
    K = 12;
    if nargin<3 || isempty(low_frequency)
        % Set default number of periods corresponding to the lowest frequency.
        low_frequency = 32;
        if nargin<2 || isempty(high_frequency)
            % Set default number of periods corresponding to the highest frequency.
            high_frequency = 6;
            if nargin<1
                error('dseries::baxter_king_filter: I need at least one argument')
            end
        else
            if high_frequency<2
                error('dseries::baxter_king_filter: Second argument must be greater than 2!')
            end
            if high_frequency>low_frequency
                error('dseries::baxter_king_filter: Second argument must be smaller than the third argument!')
            end
        end
    end
end

o = copy(o);
o.baxter_king_filter_(high_frequency, low_frequency, K);

%@test:1
%$ plot_flag = false;
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
%$     ts = dseries(y,'1950Q1');
%$     ds = ts.baxter_king_filter();
%$     xx = dseries(x,'1950Q1');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ds.freq, 4);
%$     t(3) = dassert(ds.init.freq, 4);
%$     t(4) = dassert(ds.init.time, 1953*4+1);
%$     t(5) = dassert(ds.vobs, 1);
%$     t(6) = dassert(ds.nobs, 176);
%$     t(7) = dassert(ds.name{1}, 'Variable_1');
%$     t(8) = dassert(ds.ops{1}, 'baxter_king_filter(Variable_1, 6, 32, 12)');
%$     t(9) = dassert(ts.freq, 4);
%$     t(10) = dassert(ts.name{1}, 'Variable_1');
%$     t(11) = dassert(ts.init.freq, 4);
%$     t(12) = dassert(ts.init.time, 1950*4+1);
%$     t(13) = dassert(ts.vobs, 1);
%$     t(14) = dassert(ts.nobs, length(y));
%$     t(15) = dassert(ts.data, y);
%$     t(16) = isempty(ts.ops{1});
%$ end
%$
%$ % Show results
%$ if plot_flag
%$     plot(xx(ts.dates).data,'-k');
%$     hold on
%$     plot(ts.data,'--r');
%$     hold off
%$     axis tight
%$     id = get(gca,'XTick');
%$     set(gca,'XTickLabel',strings(ts.dates(id)));
%$     legend({'Stationary component of y', 'Filtered y'})
%$     print('-depsc2','../doc/dynare.plots/BaxterKingFilter.eps')
%$     system('convert -density 300 ../doc/dynare.plots/BaxterKingFilter.eps ../doc/dynare.plots/BaxterKingFilter.png');
%$     system('convert -density 300 ../doc/dynare.plots/BaxterKingFilter.eps ../doc/dynare.plots/BaxterKingFilter.pdf');
%$     system('convert -density 300 ../doc/dynare.plots/BaxterKingFilter.eps ../doc/dynare.plots/BaxterKingFilter.jpg');
%$ end
%$
%$ T = all(t);
%@eof:1
