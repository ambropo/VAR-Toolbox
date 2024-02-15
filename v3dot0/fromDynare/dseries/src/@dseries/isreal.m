function b = isreal(o) % --*-- Unitary tests --*--

% Returns true if no elements of the dseries have imaginary parts.
% Returns false otherwise
%
% INPUTS
% - o [dseries]    with N variables and T periods.
%
% OUTPUTS
% - b [logical]    true iff all elements are real; false otherwise.


% Copyright (C) 2019 Dynare Team
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

b = isreal(o.data);

%@test:1
%$ try
%$     data = randn(100, 10);
%$     cnan = randi(10, 50, 1);
%$     rnan = randi(100, 50, 1);
%$     for i=1:50, data(rnan(i),cnan(i)) = sqrt(-1); end
%$     ireal = isreal(data);
%$     ts = dseries(data);
%$     dd = ts.isreal();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(dd, ireal);
%$ end
%$
%$ T = all(t);
%@eof:1
