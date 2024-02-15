function S = shiftS(S,n) % --*-- Unitary tests --*--

% Removes the first n elements of a one dimensional cell array.

% Copyright (C) 2009-2017 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if length(S) >= n+1
    S = S(n+1:end);
else
    S = {};
end

%@test:1
%$ Cell = {'1', '2', '3'};
%$ try
%$     Cell = shiftS(Cell,1);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(length(Cell), 2);
%$     t(3) = dassert(Cell, {'2', '3'});
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:1
%$ Cell = {'1', '2', '3'};
%$ try
%$     Cell = shiftS(Cell,3);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(length(Cell), 0);
%$     t(3) = dassert(isequal(Cell, {}), true);
%$ end
%$
%$ T = all(t);
%@eof:1
