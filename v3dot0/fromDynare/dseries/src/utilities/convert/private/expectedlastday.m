function eld = expectedlastday(d)

% Copyright © 2020-2021 Dynare Team
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

switch d.freq
  case 12
    if ismember(subperiod(d), [4,6,9,11])
        eld = 30;
    elseif ismember(subperiod(d), [1,3,5,7,8,10,12])
        eld = 31;
    else % February
        if isleapyear(year(d))
            eld = 29;
        else
            eld = 28;
        end
    end
  case 4
    if ismember(subperiod(d), [1,4])
        eld = 31; % last day of March or December
    else
        eld = 30; % last day of June or September
    end
  case 2
    if subperiod(d)==2
        eld = 31;
    else
        eld = 30;
    end
  case 1
    eld = 31;
  otherwise
end