function fid = database(FameInfo, dbname, varargin)

% Open fame database.
%
% By default the file is opened in read only mode. Available modes are READ_ONLY, READ_WRITE,
% CREATE, EXCLUSIVE, UNSAFE_EXCLUSIVE, OVERWRITE and DIRECT (report to TIMEIQ reference manual).
%
% Example. To create a new database:
% >> FameInfo = open_fame_connector();
% >> fid = fame.open(FameInfo, 'C:\works\DynareTeam\fame\tests\FameDataBases\toto.db', 'mode', 'CREATE');

% Copyright (C) 2016-2018 Dynare Team
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
    error('Needs at least two input arguments!')
end

if ~ischar(dbname)
    error('Second input argument has to be a string (name of the fame database with path)!')
end

if ~isFameInfoStruct(FameInfo)
    error('First input argument has to be a structure as returned by open_fame_connector routine!')
end

if nargin>2
    if mod(length(varargin), 2)>0
        error('Wrong number of arguments! Properties should come in pairs Name/Value.')
    end
    p = 1;
    props = java.util.Properties();
    while p<=length(varargin)-1
        props.setProperty(varargin{p}, varargin{p+1});
        p = p+2;
    end
else
    props = java.util.Properties();
    props.setProperty('mode','READ_ONLY');
end

try
    fid = FameInfo.ConnectionID.getDataStore(dbname, props);
catch me
    message=split(me.message,':');
    message=split(message{3},'at com.');
    message=strtrim(message{1});
    error(message)
end