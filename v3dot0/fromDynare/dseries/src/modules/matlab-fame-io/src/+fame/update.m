function update(datafilename, ts)

% Updates a Fame database.
%
% INPUTS
% - datafilename [string]  Name of the file to be written (db extension).
% - ts           [dseries] Time series to be saved.
%
% OUTPUTS
% None
%
% REMARKS
% Returns an error if datafilename does not exist.

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

% Get frequency.
switch ts.freq
  case 4
    calendar = com.fame.timeiq.dates.RegularCalendar.QUARTERLY;
  case 1
    calendar = com.fame.timeiq.dates.RegularCalendar.ANNUAL;
  case 12
    calendar = com.fame.timeiq.dates.RegularCalendar.MONTHLY;
  otherwise
    error('This frequency is not yet implemented!')
end

% Get first and last periods.
firstperiod = dates2Index(ts.init);
lastperiod = dates2Index(ts.last);

% Get connection to Fame/TimeIQ
FameInfo = fame.open.connector();

% Create a fame database.
if ~exist(datafilename)
    fame.close.connector(FameInfo);
    error('File %s does not exist.', datafilename)
end

% Reopen database in READ/WRITE mode
db = fame.open.database(FameInfo, datafilename,'mode','READ_WRITE');

% Write dseries object in database.
fame.transaction.begin(FameInfo);
for i=1:ts.vobs
    cperiod = ts.init;
    variable_name = java.lang.String(ts.name{i});
    status = com.fame.timeiq.data.ByteList(false(ts.nobs, 1));
    thisdata = com.fame.timeiq.data.ObservationList(calendar, firstperiod, lastperiod, com.fame.timeiq.data.DoubleList(ts.data(:,i)), status);
    db.setObservations(variable_name, thisdata);
end
fame.transaction.commit(FameInfo);

fame.close.database(db);
fame.close.connector(FameInfo);