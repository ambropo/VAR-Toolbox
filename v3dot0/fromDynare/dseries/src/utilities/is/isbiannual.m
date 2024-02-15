function b = isbiannual(str)  % --*-- Unitary tests --*--

% Tests if the input can be interpreted as a bi-annual date (semester).
%
% INPUTS
%  o str     string.
%
% OUTPUTS
%  o b       integer scalar, equal to 1 if str can be interpreted as a bi-annual date or 0 otherwise.

% Copyright © 2021 Dynare Team
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
    if isempty(regexp(str,'^-?[0-9]+[HhSs][1-2]$','once'))
        b = false;
    else
        b = true;
    end
else
    b = false;
end

%@test:1
%$
%$ date_1 = '1950H2';
%$ date_2 = '1950h2';
%$ date_3 = '-1950h2';
%$ date_4 = '1950h3';
%$ date_5 = '1950 azd ';
%$ date_6 = '1950Y';
%$ date_7 = '1950m24';
%$ date_8 = '1950S2';
%$ date_9 = '1950s2';
%$
%$ t(1) = dassert(isbiannual(date_1),true);
%$ t(2) = dassert(isbiannual(date_2),true);
%$ t(3) = dassert(isbiannual(date_3),true);
%$ t(4) = dassert(isbiannual(date_4),false);
%$ t(5) = dassert(isbiannual(date_5),false);
%$ t(6) = dassert(isbiannual(date_6),false);
%$ t(7) = dassert(isbiannual(date_7),false);
%$ t(8) = dassert(isbiannual(date_8),true);
%$ t(9) = dassert(isbiannual(date_9),true);
%$ T = all(t);
%@eof:1