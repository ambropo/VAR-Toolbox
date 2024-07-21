function C = issubperiod(A,B) % --*-- Unitary tests --*--

% Copyright (C) 2013-2020 Dynare Team
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

if isfreq(B)
    if B == 365
        error('issubperiod:: The function does not support daily frequency!')
    else
        C = all(isint(A)) && all(A>=1) && all(A<=B);
    end
else
    error('issubperiod:: Second input argument must be equal to 1, 2, 4, 12 or 52 (frequency)!')
end

%@test:1
%$ try
%$    b = issubperiod(1, 1);
%$    t(1) = true;
%$ catch
%$    t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(b, true);
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$    b = issubperiod(2, 4);
%$    t(1) = true;
%$ catch
%$    t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(b, true);
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ try
%$    b = issubperiod(6, 4);
%$    t(1) = true;
%$ catch
%$    t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(b, false);
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$    b = issubperiod(3, 2);
%$    t(1) = true;
%$ catch
%$    t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(b, false);
%$ end
%$
%$ T = all(t);
%@eof:4