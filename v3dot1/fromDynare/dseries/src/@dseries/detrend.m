function o = detrend(o, model) % --*-- Unitary tests --*--

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

o = copy(o);
o.detrend_(model);

%@test:1
%$ % Define a dataset.
%$ A = ones(3,1);
%$ a = dseries(A);
%$
%$ try
%$   b = a.detrend();
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = max(max(abs(a.data-A)))<1e-12;
%$ end
%$
%$ T = all(t);
%@eof:1