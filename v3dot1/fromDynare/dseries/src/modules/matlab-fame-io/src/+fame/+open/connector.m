function FameInfo = connector(sname, varargin)

% Opens fame connector.

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

if ~nargin || isempty(sname)
    sname = '';
end

if nargin>1
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
    props.setProperty('kind','fame');
    props.setProperty('speed','fast');
end
                    
try
    ServerID = com.fame.timeiq.persistence.Server.getInstance();
    SessionID = ServerID.getSession();
    ConnectionID = SessionID.createConnection(sname, props);
    FameInfo = struct('ServerID', ServerID, 'SessionID', SessionID, 'ConnectionID', ConnectionID);
catch
    FameInfo = [];
end