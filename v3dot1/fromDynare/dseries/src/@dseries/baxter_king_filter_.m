function o = baxter_king_filter_(o, high_frequency, low_frequency, K) % --*-- Unitary tests --*--

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

% translate periods into frequencies.
hf=2.0*pi/high_frequency;
lf=2.0*pi/low_frequency;

% Set weights for the band-pass filter's lag polynomial.
weights = zeros(K+1,1); lpowers = transpose(1:K);
weights(2:K+1) = (sin(lpowers*hf)-sin(lpowers*lf))./(lpowers*pi);
weights(1) = (hf-lf)/pi;

% Set the constraint on the sum of weights.
if low_frequency>1000
    % => low pass filter.
    sum_of_weights_constraint = 1.0;
else
    sum_of_weights_constraint = 0.0;
end

% Compute the sum of weights.
sum_of_weights = weights(1) + 2*sum(weights(2:K+1));

% Correct the weights.
weights = weights + (sum_of_weights_constraint - sum_of_weights)/(2*K+1);

% Weights are symmetric!
weights = [flipud(weights(2:K+1)); weights];

tmp = zeros(size(o.data));

% Filtering step.
for t = K+1:nobs(o)-K
    tmp(t,:)  = weights'*o.data(t-K:t+K,:);
end

% Update dseries object.
o.data = tmp(K+1:end-K,:);
init = firstdate(o)+K;
o.dates = init:init+(nobs(o)-1);
for i=1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {sprintf('baxter_king_filter(%s, %s, %s, %s)', ...
                            o.name{i}, ...
                            num2str(high_frequency), ...
                            num2str(low_frequency), ...
                            num2str(K))};
    else
        o.ops(i) = {sprintf('baxter_king_filter(%s, %s, %s, %s)', ...
                            o.ops{i}, ...
                            num2str(high_frequency), ...
                            num2str(low_frequency), ...
                            num2str(K))};
    end
end


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
%$     ts.baxter_king_filter_();
%$     xx = dseries(x,'1950Q1');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(ts.init.freq,4);
%$     t(4) = dassert(ts.init.time,1953*4+1);
%$     t(5) = dassert(ts.vobs,1);
%$     t(6) = dassert(ts.nobs,176);
%$     t(7) = dassert(ts.name{1},'Variable_1');
%$     t(8) = dassert(ts.ops{1},'baxter_king_filter(Variable_1, 6, 32, 12)');
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
