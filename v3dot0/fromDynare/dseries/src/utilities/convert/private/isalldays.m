function iad = isalldays(d, id)

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
        iad = length(id)==30;
    elseif ismember(subperiod(d), [1,3,5,7,8,10,12])
        iad = length(id)==31;
    else % February
        if isleapyear(year(d))
            iad = length(id)==29;
        else
            iad = length(id)==28;
        end
    end
  case 4
    if ismember(subperiod(d), [3, 4])
        iad = length(id)==92;
    elseif subperiod(d)==2
        iad = length(id)==91;
    else % contains February
        if isleapyear(year(d))
            iad = length(id)==91;
        else
            iad = length(id)==90;
        end
    end
  case 2
    if subperiod(d)==2
        iad = length(id)==184;
    else
        if isleapyear(year(d))
            iad = length(id)==182;
        else
            iad = length(id)==181;
        end
    end
  case 1
      if isleapyear(year(d))
          iad = length(id)==366;
      else
          iad = length(id)==365;
      end
  otherwise
end