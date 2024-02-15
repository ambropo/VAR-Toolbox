function d = get_period(info, firstorlast)

% Returns the first or last period of a time series
%
% INPUTS 
% - info          [com.fame.timeiq.persistence.fame.CfmDataObjectInfo]
% - firstorlast   [string] 'Fitst' or 'Last'                                              
%
% OUPUTS 
% - d             [dates]

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

if ~strcmpi(firstorlast,'first') && ~strcmpi(firstorlast,'last')
    error('Second input argument must be a string equal to ''First'' or ''Last''!')
end

c = char(info.getTiqObjectCopy.getFrequency);

switch c
  case 'QUARTERLY'
    c = 4;
  case 'MONTHLY'
    c = 12;
  case 'ANNUAL'
    c = 1;
  case 'WEEKLY'
    c = 52;
  otherwise
    error(sprintf('Unimplemented frequency (%s is %s)', names{i}, cf))
end

if strcmpi(firstorlast,'last')
    year = com.fame.timeiq.dates.DateHelper.indexToYear(info.getLastIndex);
else
    year = com.fame.timeiq.dates.DateHelper.indexToYear(info.getFirstIndex);
end

switch c
  case 4
    if strcmpi(firstorlast,'last')
        tmp = com.fame.timeiq.dates.DateHelper.indexToMonth(info.getLastIndex);
    else
        tmp = com.fame.timeiq.dates.DateHelper.indexToMonth(info.getFirstIndex);;
    end
    switch tmp
      case 1
        subperiod = 1;
      case 4
        subperiod = 2;
      case 7
        subperiod = 3;
      case 10
        subperiod = 4;
      otherwise
        error('Unexpected subperiod!')
    end
  case 12
    if strcmpi(firstorlast,'last')
        subperiod = com.fame.timeiq.dates.DateHelper.indexToMonth(info.getLastIndex);
    else
        subperiod = com.fame.timeiq.dates.DateHelper.indexToMonth(info.getFirstIndex);;
    end
  case 1
    subperiod = 1
  case 52
    if strcmpi(firstorlast,'last')
        subperiod = com.fame.timeiq.dates.DateHelper.indexToWeek(info.getLastIndex);
    else
        subperiod = com.fame.timeiq.dates.DateHelper.indexToWeek(info.getFirstIndex);;
    end
  otherwise
    error('Unknown frequency!')
end

d = dates(c, [year subperiod]);