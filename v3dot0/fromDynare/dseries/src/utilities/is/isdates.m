function B = isdates(A) % --*-- Unitary tests --*--

% Tests if the input A is a dates object.

% Copyright (C) 2013-2015 Dynare Team
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

B = isa(A,'dates');

%@test:1
%$ try
%$     boolean = isdates(dates('1950Q2'));
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, true);
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     boolean = isdates(dates());
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, true);
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ try
%$     boolean = isdates(dates('1950Q2'):dates('1950Q4'));
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, true);
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$     boolean = isdates(1);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, false);
%$ end
%$
%$ T = all(t);
%@eof:4

%@test:5
%$ try
%$     boolean = isdates('1938M11');
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, false);
%$ end
%$
%$ T = all(t);
%@eof:5