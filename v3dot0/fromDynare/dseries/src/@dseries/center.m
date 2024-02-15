function o = center(o, geometric) % --*-- Unitary tests --*--

% Centers dseries object o around its mean (arithmetic or geometric).
%
% INPUTS
%  - o             dseries object [mandatory].
%  - geometric     logical [default is false], if true returns the geometric mean.
%
% OUTPUTS
%  - o             dseries object.

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

o = copy(o);
o.center_(geometric);

%@test:1
%$ % Define a dataset.
%$ A = repmat([1.005, 1.05], 10, 1);
%$
%$ % Instantiate a time series object and compute the mean.
%$ try
%$    ts = dseries(A);
%$    ds = ts.center(true);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = all(all(abs(ds.data-ones(10,2))<1e-12));
%$    t(3) = all(all(abs(ts.data-A)<1e-12));
%$    t(4) = dassert(ds.ops{1}, 'center(Variable_1, 1)');
%$    t(5) = dassert(ds.name{1}, 'Variable_1');
%$    t(6) = isempty(ts.ops{1});
%$    t(7) = dassert(ds.name{1}, 'Variable_1');
%$ end
%$ T = all(t);
%@eof:1
