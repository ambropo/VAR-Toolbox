function m = mean(o, geometric) % --*-- Unitary tests --*--

% Returns the mean of the variables in a @dseries object o.
%
% INPUTS
%  o o             dseries object [mandatory].
%  o geometric     logical [default is false], if true returns the geometric mean.
%
% OUTPUTS
%  o m             1*vobs(o) vector of doubles.

% Copyright (C) 2016 Dynare Team
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

if nargin<2
    geometric = false;
end

if geometric
    m = prod(o.data, 1).^(1/nobs(o));
else
    m = mean(o.data);
end

%@test:1
%$ % Define a dataset.
%$ A = repmat([1.005, 1.05], 10, 1);
%$
%$ % Instantiate a time series object and compute the mean.
%$ try
%$    ts = dseries(A);
%$    m = mean(ts, true);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(m),[1, 2]), true);
%$    t(3) = dassert(m, [1.005, 1.05]);
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a dataset.
%$ A = repmat([1.005, 1.05], 10, 1);
%$
%$ % Instantiate a time series object and compute the mean.
%$ try
%$    ts = dseries(A);
%$    m = ts.mean(true);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(m),[1, 2]), true);
%$    t(3) = dassert(m, [1.005, 1.05]);
%$ end
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define a dataset.
%$ A = bsxfun(@plus, randn(100000000,2)*.1, [.5, 2]);
%$
%$ % Instantiate time series objects and compute the mean.
%$ try
%$    ts = dseries(A);
%$    m1 = mean(ts);
%$    m2 = mean(ts, true);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(m1),[1, 2]), true);
%$    t(3) = dassert(isequal(size(m2),[1, 2]), true);
%$    t(4) = dassert(max(abs(m1-[.5, 2]))<.0001, true);
%$    t(5) = isinf(m2(2));
%$    t(6) = isequal(m2(1), 0);
%$ end
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define a dataset.
%$ A = bsxfun(@plus, randn(100000000,2)*.1, [.5, 2]);
%$
%$ % Instantiate time series objects and compute the mean.
%$ try
%$    ts = dseries(A);
%$    m1 = ts.mean();
%$    m2 = ts.mean(true);
%$    m3 = ts.mean(false);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(m1),[1, 2]), true);
%$    t(3) = dassert(isequal(size(m2),[1, 2]), true);
%$    t(4) = dassert(max(abs(m1-[.5, 2]))<.0001, true);
%$    t(5) = isinf(m2(2));
%$    t(6) = isequal(m2(1), 0);
%$    t(7) = isequal(m1, m3);
%$ end
%$ T = all(t);
%@eof:4