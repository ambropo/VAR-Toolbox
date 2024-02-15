function s = caseseries(db, varargin)

% Loads case series in fame DB.
%
% INPUTS
% - db                     Pointer to the Fame database (returned by fame.open)
% - ...        [string]    Filter the case series, see below.
%
% OUTPUTS
% - s          [struct]    Structure containing the case series.
%
% REMARKS
% The fieldnames are the names of the case series. By default all the case series in db are
% loaded. These variables can be filtered by passing additional strings to the routine
% (varargin). For instance, caseseries(db, 'PCB','YOY', 'ALPHA') would only load the case series
% matching '*PCB*YOY*BLBL*' as:
%                                 'PCB_CONTRIBUTIONS_YOY_1_ALPHA_0'
%                                 'PCB_CONTRIBUTIONS_YOY_2_ALPHA_0'
%                                 'PCB_CONTRIBUTIONS_YOY_1_ALPHA_1'
%                                 'PCB_CONTRIBUTIONS_YOY_1_ALPHA_1' ...
% Obviously the ordering of the additional arguments matters.

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

if nargin > 1
    assert(ischar(varargin{1}), 'Input argument 2 must be a string!');
    b = varargin{1};
    for i=1:length(varargin)-1
        assert(ischar(varargin{i+1}), 'Input argument %i must be a string!', i+1)
        b = sprintf('%s*%s', b, varargin{i+1});
    end
    wildCard = sprintf('*%s*', b);
else
    wildCard='*';
end

iterator = get_cs_iterator(db, wildCard);
info = iterator.nextElement();
data = info.getTiqObjectCopy.getObservations.getValueList.getArray;

s = struct();
s.(char(info.getName())) = char(data);

while iterator.hasMoreElements
    info = iterator.nextElement();
    data=info.getTiqObjectCopy.getObservations.getValueList.getArray;
    s.(char(info.getName())) = char(data);
end