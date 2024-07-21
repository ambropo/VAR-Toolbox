function b = isdaily(str)  % --*-- Unitary tests --*--

% Tests if the input can be interpreted as a daily date.
%
% INPUTS
% - str     [char]     1×n array, string to be tested.
%
% OUTPUTS
% - b       [logical]  scalar, equal to true iff str can be interpreted as a daily date.

% Copyright © 2020 Dynare Team
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
    if isempty(regexp(str,'^-?[0-9]+[-](0[1-9]|1[0-2])+[-](0[1-9]|[1-2][0-9]|3[0-1])$','once'))
        b = false;
    else
        Thisday = strsplit(str, '-');
        thisday = str2double(Thisday(end-2:end));
        if length(Thisday)>3
            % It is the case if we have an extra minus symbol because the year is before anno Domini.
            thisday(1) = -thisday(1);
        end
        b = isvalidday(thisday);
    end
else
    b = false;
end

return

%@test:1
t(1) = isdaily('1950-03-29');
t(2) = isdaily('1950-12-31');
t(3) = isdaily('-1950-11-28');
t(4) = isdaily('1976-01-19');
t(5) = ~isdaily('1950 azd');
t(6) = ~isdaily('1950Y');
t(7) = ~isdaily('1950Q3');
t(8) = ~isdaily('1950-13-39');
t(9) = ~isdaily('2000-12-00');
t(10) = ~isdaily('1999-02-29');
t(11) = isdaily('2000-02-29');
T = all(t);
%@eof:1