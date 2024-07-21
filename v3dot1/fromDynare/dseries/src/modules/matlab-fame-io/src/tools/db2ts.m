function ts = db2ts(database, what, varargin)

% Load objects (time series, scalars or case series) from a fame database.
%
% INPUTS
% - database [string]     path to a database.
% - what     [string]     'TS', 'CS' or 'SC', specify type of the objects to be loaded.
% - ...
%
% OUPUTS
% - ts        [struct]    structure of loaded objects.
%
% REMARKS
%
% additional arguments are for wildcards to limit the data retrieve, e.g.:
%
%    db2ts('afame.db','TS','wild1','wild2')
%
% is equivalent to providing a single wild card 'wild1*wild2':
%
%    db2ts('afame.db','TS','wild1*wild2')
%
% Order of the wildcards matters, you can have as many as possible: they will be linked with '*'.
%
% Note that the following statements:
%
%    db2ts('afame.db','TS', 'wild1')
%
% and
%
%    db2ts('afame.db','TS','*wild1*')
%
% are not equivalent. The first one will try to get a single series, the other
% will try to retrieve all the series containing 'wild1'.
%
% Wildcard parameter * stands for whatever number of (various) characters. Wildcard parameter ?
% stands for a single character.
%
% If the database is in Unix (detected by the path containing '/' ) the last argument should be the server name, e.g.:
%
%    db2ts('afame.db','TS','server@name')
%
% or
%    db2ts('afame.db','TS','awildcard','server@name.com')

% Copyright (C) 2018 Dynare Team
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

if ~contains(database, '/')
    FameInfo = fame.open.connector();
    tmp = 0;
else
    if contains(varargin{end},'@')
        FameInfo = fame.open.connector(varargin{end}, 'transport', 'always');
        tmp=1; %to substract the last arg from the varargin list (due to the server)
    else
        error('For a database located in Unix, the last argument for db2ts should be the server name.')
    end
end

db = fame.open.database(FameInfo, database);

try
    switch upper(what)
        case {'TS'}
            ts = getdseries(db, varargin{1:end-tmp});
        case {'SC'}
            ts = fame.getall.scalars(db, varargin{1:end-tmp});
        case {'CS'}
            ts = fame.getall.caseseries(db, varargin{1:end-tmp});
        otherwise
            fprintf('Unimplemented type of data (%s) to read', what)
            fprintf('Use ''TS'' for Time Series, ''SC'' for SCalars, ''CS'' for Case Series')
    end
    fame.close.database(db);
    fame.close.connector(FameInfo);
catch me
    fame.close.database(db);
    fame.close.connector(FameInfo);
    error(me.message);
end