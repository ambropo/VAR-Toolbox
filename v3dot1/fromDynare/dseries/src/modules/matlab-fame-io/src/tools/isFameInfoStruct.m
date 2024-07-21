function b = isFameInfoStruct(a)

% Returns true iff a is the output of open_fame_connector

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

b = false;

if isstruct(a)
    if isfield(a, 'ServerID') && isa(a.ServerID,'com.fame.timeiq.persistence.Server')
        if isfield(a, 'SessionID') && isa(a.SessionID,'com.fame.timeiq.persistence.Session')
            if isfield(a, 'ConnectionID') && isa(a.ConnectionID, 'com.fame.timeiq.persistence.fame.CfmConnection')
                b = true;
            end
        end
    end
end