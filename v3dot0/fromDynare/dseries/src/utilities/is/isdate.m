function b = isdate(str)  % --*-- Unitary tests --*--

% Tests if the input string can be interpreted as a date.
%
% INPUTS
% - str     [char]      1×m array, date (potentially)
%
% OUTPUTS
% - b       [logical]   scalar equal to true iff str can be interpreted as a date.

% Copyright © 2013-2020 Dynare Team
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

if isnumeric(str) && isscalar(str)
    b = true;
    return
end

b = isstringdate(str);

return

%@test:1
date_1 = 1950;
date_2 = '1950m2';
date_3 = '-1950m2';
date_4 = '1950m52';
date_5 = ' 1950';
date_6 = '1950Y';
date_7 = '-1950a';
date_8 = '1950m ';
date_9 = '2000-01-01';
date_10 = '2000-02-30';

t(1) = isequal(isdate(date_1), true);
t(2) = isequal(isdate(date_2), true);
t(3) = isequal(isdate(date_3), true);
t(4) = isequal(isdate(date_4), false);
t(5) = isequal(isdate(date_5), false);
t(6) = isequal(isdate(date_6), true);
t(7) = isequal(isdate(date_7), true);
t(8) = isequal(isdate(date_8), false);
t(9) = isequal(isdate(date_9), true);
t(10) = isequal(isdate(date_10), false);
T = all(t);
%@eof:1