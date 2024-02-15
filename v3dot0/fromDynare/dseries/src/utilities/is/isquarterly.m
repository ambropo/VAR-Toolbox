function b = isquarterly(str)  % --*-- Unitary tests --*--

% Tests if the input can be interpreted as a quarterly date.
%
% INPUTS
%  o str     string.
%
% OUTPUTS
%  o b       integer scalar, equal to 1 if str can be interpreted as a quarterly date or 0 otherwise.

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
    if isempty(regexp(str,'^-?[0-9]+[Qq][1-4]$','once'))
        b = false;
    else
        b = true;
    end
else
    b = false;
end

%@test:1
%$
%$ date_1 = '1950Q2';
%$ date_2 = '1950q2';
%$ date_3 = '-1950q2';
%$ date_4 = '1950q12';
%$ date_5 = '1950 azd ';
%$ date_6 = '1950Y';
%$ date_7 = '1950m24';
%$
%$ t(1) = dassert(isquarterly(date_1),true);
%$ t(2) = dassert(isquarterly(date_2),true);
%$ t(3) = dassert(isquarterly(date_3),true);
%$ t(4) = dassert(isquarterly(date_4),false);
%$ t(5) = dassert(isquarterly(date_5),false);
%$ t(6) = dassert(isquarterly(date_6),false);
%$ t(7) = dassert(isquarterly(date_7),false);
%$ T = all(t);
%@eof:1