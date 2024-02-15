function o = detrend_(o, model) % --*-- Unitary tests --*--

% Detrends a dseries object with a polynomial of order model.
%
% INPUTS
% - o       [dseries]   time series to be detrended.
% - model   [integer]   scalar, order of the fitted polynomial.
%
% OUTPUTS
% - o       [dseries]   detrended time series.

% Copyright (C) 2014-2017 Dynare Team
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

% Set default for the order of the polynomial trend (constant).
if nargin<2
    model = 0;
end

if isnumeric(model)
    if isscalar(model) && isint(model)
        switch model
          case 0
            o.data = demean(o.data);
          otherwise
            x = NaN(nobs(o), model+1);
            x(:,1) = ones(nobs(o), 1);
            x(:,2) = transpose(1:nobs(o));
            for c=3:model+1
                x(:,c) = x(:,c-1).*x(:,2);
            end
            o.data = o.data - x*(x\o.data);
        end
    else
        error('dseries::detrend: Second argument must be a positive integer scalar!')
    end
else
    error('dseries::detrend: Second argument must be a positive integer scalar!')
end

for i=1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {sprintf('detrend(%s, %s)', o.name{i}, num2str(model))};
    else
        o.ops(i) = {sprintf('detrend(%s, %s)', o.ops{i}, num2str(model))};
    end
end

%@test:1
%$ % Define a dataset.
%$ a = dseries(randn(1000,3));
%$
%$ % detrend (default).
%$ try
%$    b = copy(a);
%$    b1 = b.detrend_();
%$    t(1) = 1;
%$ catch
%$    t(1) = 0;
%$ end
%$
%$ % detrend (constant).
%$ if t(1)
%$    try
%$       b = copy(a);
%$       b2 = b.detrend_(0);
%$       t(2) = 1;
%$    catch
%$       t(2) = 0;
%$    end
%$ end
%$
%$ % detrend (linear).
%$ if t(1) && t(2)
%$    try
%$       b = copy(a);
%$       b3 = b.detrend_(1);
%$       t(3) = 1;
%$    catch
%$       t(3) = 0;
%$    end
%$ end
%$
%$ % detrend (quadratic).
%$ if t(1) && t(2) && t(3)
%$    try
%$       b = copy(a);
%$       b4 = b.detrend_(2);
%$       t(4) = 1;
%$    catch
%$       t(4) = 0;
%$    end
%$ end
%$
%$ % detrend (cubic).
%$ if t(1) && t(2) && t(3) && t(4)
%$    try
%$       b = copy(a);
%$       b5 = b.detrend_(3);
%$       t(5) = 1;
%$    catch
%$       t(5) = 0;
%$    end
%$ end
%$
%$ if t(1) && t(2) && t(3) && t(4) && t(5)
%$    t(6) = dassert(max(mean(b1.data)), 0,1e-12);
%$    t(7) = dassert(max(mean(b2.data)), 0,1e-12);
%$    t(8) = dassert(max(mean(b3.data)), 0,1e-12);
%$    t(9) = dassert(max(mean(b4.data)), 0,1e-12);
%$    t(10) = dassert(max(mean(b5.data)), 0,1e-9);
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a dataset.
%$ A = randn(1000,3);
%$ a = dseries(randn(1000,3));
%$
%$ try
%$   b = a.detrend_();
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = max(max(abs(a.data-A)))>1e-8;
%$ end
%$
%$ T = all(t);
%@eof:2