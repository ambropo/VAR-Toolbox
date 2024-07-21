function b = isstringdate(str)  % --*-- Unitary tests --*--

% Tests if the input string can be interpreted as a date.
%
% INPUTS
%  o str     string.
%
% OUTPUTS
%  o b       integer scalar, equal to 1 if str can be interpreted as a date or 0 otherwise.

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

if ischar(str)
    b = isquarterly(str) || isyearly(str) || isbiannual(str) || ismonthly(str) || isdaily(str);
else
    b = false;
end

return

%@test:1
date_1 = '1950M2';
date_2 = '1950m2';
date_3 = '-1950m2';
date_4 = '1950m52';
date_5 = ' 1950';
date_6 = '1950Y';
date_7 = '-1950a';
date_8 = '1950m ';
date_9 = 'A';
date_10 = '1938Q';
date_11 = 'Q4';
date_12 = '1938M';
date_13 = 'M11';
date_14 = '1W';
date_15 = 'X1';
date_16 = '1948H1';
date_17 = 'h2';
date_18 = '1948-02-12';
date_19 = '12-30';

t(1) = isstringdate(date_1);
t(2) = isstringdate(date_2);
t(3) = isstringdate(date_3);
t(4) = ~isstringdate(date_4);
t(5) = ~isstringdate(date_5);
t(6) = isstringdate(date_6);
t(7) = isstringdate(date_7);
t(8) = ~isstringdate(date_8);
t(9) = ~isstringdate(date_9);
t(10) = ~isstringdate(date_10);
t(11) = ~isstringdate(date_11);
t(12) = ~isstringdate(date_12);
t(13) = ~isstringdate(date_13);
t(14) = ~isstringdate(date_14);
t(15) = ~isstringdate(date_15);
t(16) = isstringdate(date_16);
t(17) = ~isstringdate(date_17);
t(16) = isstringdate(date_18);
t(17) = ~isstringdate(date_19);

T = all(t);
%@eof:1