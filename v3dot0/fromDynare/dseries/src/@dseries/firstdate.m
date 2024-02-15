function f = firstdate(o) % --*-- Unitary tests --*--

% Copyright (C) 2014-2016 Dynare Team
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

f = o.dates(1);

%@test:1
%$ try
%$     ts = dseries(randn(10, 3),'1938Q3');
%$     dd = ts.firstdate();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(dd, dates('1938Q3'));
%$ end
%$
%$ T = all(t);
%@eof:1
