function b = isvalidday(day)  % --*-- Unitary tests --*--

% Tests if the input can be interpreted as a daily date.
%
% INPUTS
% - day     [integer]     1×3 array, [year month day].
%
% OUTPUTS
% - b       [logical]  scalar, equal to true iff day can be interpreted as a daily date.

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

if isnumeric(day) && isrow(day) && length(day)==3
    if day(2)>12 || day(2)<1
        b = false;
        return
    end
    if day(3)<1
        b = false;
        return
    end
    if ismember(day(2), [1 3 5 7 8 10 12]) && day(3)>31
        b = false;
        return
    end
    if ismember(day(2), [4 6 9 11]) && day(3)>30
        b = false;
        return
    end
    if day(2)==2
        if isleapyear(day(1))
            if day(3)>29
                b = false;
                return
            end
        else
            if day(3)>28
                b = false;
                return
            end
        end
    end
else
    error('Input must be a row vector of integers with 3 elements.')
end

b = true;

return

%@test:1
t(1) = isvalidday([2000,1,1]) && isvalidday([2000,1,31]) && ~isvalidday([2000, 1, 32]);
t(2) = isvalidday([2000,2,1]) && isvalidday([2000,2,29]) && ~isvalidday([2000, 2, 30]);
t(3) = isvalidday([2000,3,1]) && isvalidday([2000,3,31]) && ~isvalidday([2000, 3, 32]);
t(4) = isvalidday([2000,4,1]) && isvalidday([2000,4,30]) && ~isvalidday([2000, 4, 31]);
t(5) = isvalidday([2000,5,1]) && isvalidday([2000,5,31]) && ~isvalidday([2000, 5, 32]);
t(6) = isvalidday([2000,6,1]) && isvalidday([2000,6,30]) && ~isvalidday([2000, 6, 31]);
t(7) = isvalidday([2000,7,1]) && isvalidday([2000,7,31]) && ~isvalidday([2000, 6, 32]);
t(8) = isvalidday([2000,8,1]) && isvalidday([2000,8,31]) && ~isvalidday([2000, 8, 32]);
t(9) = isvalidday([2000,9,1]) && isvalidday([2000,9,30]) && ~isvalidday([2000, 9, 31]);
t(10) = isvalidday([2000,10,1]) && isvalidday([2000,10,31]) && ~isvalidday([2000, 10, 32]);
t(11) = isvalidday([2000,11,1]) && isvalidday([2000,11,30]) && ~isvalidday([2000, 11, 31]);
t(12) = isvalidday([2000,11,1]) && isvalidday([2000,11,30]) && ~isvalidday([2000, 11, 31]);
t(13) = isvalidday([2001,2,1]) && isvalidday([2001,2,28]) && ~isvalidday([2001, 2, 29]);
t(14) = ~isvalidday([2000, 1, 0]);
t(15) = ~isvalidday([2000, 0, 1]);
t(16) = isvalidday([0, 1, 1]);
T = all(t);
%@eof:1