function b = isyearly(str)  % --*-- Unitary tests --*--

% Tests if the input can be interpreted as a yearly date.
%
% INPUTS
%  o str     string.
%
% OUTPUTS
%  o b       integer scalar, equal to 1 if str can be interpreted as a yearly date or 0 otherwise.

% Copyright (C) 2012-2017 Dynare Team
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
    if isempty(regexp(str,'^-?[0-9]+[YyAa]$','once'))
        b = false;
    else
        b = true;
    end
else
    b = false;
end

%@test:1
%$
%$ date_1 = '1950M2';
%$ date_2 = '1950m2';
%$ date_3 = '-1950m2';
%$ date_4 = '1950m12';
%$ date_5 = '1950 azd ';
%$ date_6 = '1950Y';
%$ date_7 = '-1950a';
%$ date_8 = '1950m24';
%$
%$ t(1) = dassert(isyearly(date_1),false);
%$ t(2) = dassert(isyearly(date_2),false);
%$ t(3) = dassert(isyearly(date_3),false);
%$ t(4) = dassert(isyearly(date_4),false);
%$ t(5) = dassert(isyearly(date_5),false);
%$ t(6) = dassert(isyearly(date_6),true);
%$ t(7) = dassert(isyearly(date_7),true);
%$ t(8) = dassert(isyearly(date_8),false);
%$ T = all(t);
%@eof:1