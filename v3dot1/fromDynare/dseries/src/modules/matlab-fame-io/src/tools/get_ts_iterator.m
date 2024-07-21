function iterator = get_ts_iterator(db, wildCard)

% Copyright (C) 2016-2017 Dynare Team
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

if nargin<2
    wildCard = '*';
end

screen = com.fame.timeiq.persistence.ScreeningCriteria(); 
screen.setAllClasses(0);
screen.setAllTypes(0);
screen.setAllFrequencies(0);
screen.setClass(com.fame.timeiq.TiqClass.SERIES, 1);
screen.setType(com.fame.timeiq.TiqType.DOUBLE, 1);
screen.setType(com.fame.timeiq.TiqType.FLOAT, 1);
screen.setFrequency(com.fame.timeiq.dates.TiqFrequency.MONTHLY, 1);
screen.setFrequency(com.fame.timeiq.dates.TiqFrequency.QUARTERLY, 1);
screen.setFrequency(com.fame.timeiq.dates.TiqFrequency.ANNUAL, 1);
screen.setFrequency(com.fame.timeiq.dates.TiqFrequency.WEEKLY, 1);
screen.setFrequency(com.fame.timeiq.dates.TiqFrequency.DAILY, 1);

wildcd = java.lang.String(wildCard);
iterator = db.matchWildCard(wildcd, screen);