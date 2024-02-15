function o = lead(o, p) % --*-- Unitary tests --*--

% Returns a lagged time series
%
% INPUTS
% - o [dseries]
% - p [integer] Number of leads
%
% OUTPUTS
% - o [dseries]
%
% EXAMPLE
% Define a dseries object as follows:
%
% >> o = dseries(transpose(1:5))
%
% then o.lag(1) returns
%
%       | lead(Variable_1,1)
%    1Y | 2
%    2Y | 3
%    3Y | 4
%    4Y | 5
%    5Y | NaN

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

% Set default number of leads
if nargin<2
    p = 1;
end

o = copy(o);
o.lead_(p);

%@test:1
%$ try
%$     data = transpose(1:50);
%$     ts = dseries(data,'1950Q1');
%$     a = ts.lead;
%$     b = ts.lead.lead;
%$     c = lead(ts,2);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$
%$     DATA = [data(2:end); NaN(1)];
%$     t(2) = dassert(a.data, DATA, 1e-15);
%$     DATA = [data(3:end); NaN(2,1)];
%$     t(3) = dassert(b.data, DATA, 1e-15);
%$     t(4) = dassert(c.data, DATA, 1e-15);
%$ end
%$
%$ T = all(t);
%@eof:1