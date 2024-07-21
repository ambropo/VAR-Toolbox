function i = dates2Index(d)

% Returns TimeIQ/Fame index corresponding to period d (q dates object).

% Copyright (C) 2016 Dynare Team
%
% This code is part of dseries fame toolbox.
%
% This code is free software you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This code is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

switch d.freq
  case 4
    % QUARTERLY
    switch d.subperiod
      case 1
        Month = 1;
      case 2
        Month = 4;
      case 3
        Month = 7;
      otherwise
        Month = 10;
    end
  case 12
    % MONTHLY
    Month = d.subperiod();
  case 1
    % ANNUAL
    Month = 1;
  otherwise
    error('This frequency is not yet implemented!')
end

i = com.fame.timeiq.dates.DateHelper.ymdToIndex(d.year(), Month, 1);

% % Check (last line should return true)
%
% d = dates('1960Q2');
% i = dates2Index(d);
% s = com.fame.timeiq.dates.DateHelper.dateIndexToString(i);
% isequal(s, '1Apr1960')