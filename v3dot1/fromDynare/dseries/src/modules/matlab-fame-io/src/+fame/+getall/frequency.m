function f = frequency(db)

% Returns common frequency of all the time series in database. If
% frequencies are heterogeneous, returns an empty array.
%
% Note that only QUARTERLY, MONTHLY, ANNUAL and WEEKLY are implemented. 

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

f = [];

ts_iterator = get_ts_iterator(db);

info = ts_iterator.nextElement();
cfold = char(info.getTiqObjectCopy.getFrequency);

while ts_iterator.hasMoreElements
    info = ts_iterator.nextElement();
    cf = char(info.getTiqObjectCopy.getFrequency);
    if ~isequal(cf, cfold)
        break
    end
    cfold = cf;
end

switch cf
  case 'QUARTERLY'
    f = 4;
  case 'MONTHLY'
    f = 12;
  case 'ANNUAL'
    f = 1;
  case 'WEEKLY'
    f = 52;
  otherwise
    error(sprintf('Unimplemented frequency (%s is %s)', names{i}, cf))
end