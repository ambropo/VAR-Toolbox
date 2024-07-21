function d = lastperiod(fid)

% Returns last period across all time series in database.
%
% First input argument db is a pointer to the database to be
% scanned. First output is a dates object.

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

d = dates();

ts_iterator = get_ts_iterator(db);

info = ts_iterator.nextElement();
cfold = char(info.getTiqObjectCopy.getFrequency);
cpold = info.getLastIndex;

while ts_iterator.hasMoreElements
    info_ = ts_iterator.nextElement();
    cf = char(info_.getTiqObjectCopy.getFrequency);
    if ~isequal(cf, cfold)
        break
    end
    cfold = cf;
    cp = info_.getLastIndex;
    if cpold<cp
        info = info_;
        cpold = cp;
    end
end

if ~ts_iterator.hasMoreElements
    d = get_last_period(info);
end