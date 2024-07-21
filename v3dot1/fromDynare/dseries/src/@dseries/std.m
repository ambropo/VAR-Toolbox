function s = std(o, geometric) % --*-- Unitary tests --*--

% Returns the standard deviation of the variables in a @dseries object o.
% See https://en.wikipedia.org/wiki/Geometric_standard_deviation
%
% INPUTS
% - o             [dseries]   T observations and N variables.
% - geometric     [logical]   if true returns the geometric standard deviation (default is false).
%
% OUTPUTS
% - s             [double]    1*N vector.

% Copyright (C) 2016-2017 Dynare Team
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
    m = mean(o, true);
    s = exp(sqrt(sum(log(bsxfun(@rdivide, o.data, m)).^2, 1)/nobs(o)));
else
    s = std(o.data);
end

%@test:1
%$ % Define a dataset.
%$ A = repmat([1.005, 1.05], 10, 1);
%$
%$ % Instantiate a time series object and compute the mean.
%$ try
%$    ts = dseries(A);
%$    s1 = std(ts, true);
%$    s2 = std(ts);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(s1),[1, 2]), true);
%$    t(3) = dassert(isequal(size(s2),[1, 2]), true);
%$    t(4) = dassert(s1, [1, 1]);
%$    t(4) = all(abs(s2)<1e-12);
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
%$    s1 = ts.std(true);
%$    s2 = ts.std();
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(s1),[1, 2]), true);
%$    t(3) = dassert(isequal(size(s2),[1, 2]), true);
%$    t(4) = dassert(s1, [1, 1]);
%$    t(4) = all(abs(s2)<1e-12);
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
%$    s = std(ts);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(s),[1, 2]), true);
%$    t(3) = dassert(max(abs(s-[.1, .1]))<.0001, true);
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
%$    s = ts.std();
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(isequal(size(s),[1, 2]), true);
%$    t(3) = dassert(max(abs(s-[.1, .1]))<.0001, true);
%$ end
%$ T = all(t);
%@eof:4