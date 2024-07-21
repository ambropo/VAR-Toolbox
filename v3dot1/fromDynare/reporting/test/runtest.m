% Copyright (C) 2017-2019 Dynare Team
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

initialize_dseries_class();
initialize_reporting_toolbox();

db_a = dseries('db_a.csv');
db_q = dseries('db_q.csv');
dc_a = dseries('dc_a.csv');
dc_q = dseries('dc_q.csv');

createReport(dc_a, dc_q, db_a, db_q);
