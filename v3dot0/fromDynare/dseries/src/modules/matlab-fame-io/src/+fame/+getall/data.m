function [dataarray, firstperiod, listofnames] = data(db)

% Copyright (C) 2017 Dynare Team
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

ts_iterator = get_ts_iterator(db);

info = ts_iterator.nextElement();
listofnames = {char(info.getName())};
dataarray = info.getTiqObjectCopy.getObservations.getValueList.getArray;
p = info.getFirstIndex;

while ts_iterator.hasMoreElements    
    info = ts_iterator.nextElement();
    q = info.getFirstIndex;
    if isequal(p, q)
        p = q;
    else
        error('Initial period is not constant across time series!')
    end
    listofnames = [listofnames; {char(info.getName())}];
    dataarray = [dataarray, info.getTiqObjectCopy.getObservations.getValueList.getArray];
end

firstperiod = get_first_period(info);