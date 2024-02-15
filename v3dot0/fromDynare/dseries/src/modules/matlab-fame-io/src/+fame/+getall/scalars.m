function s = scalars(db, varargin)

% Loads scalars in fame DB.
%
% INPUTS
% - db                     Pointer to the Fame database (returned by fame.open)
% - ...        [string]    Filter the scalars, see below.
%
% OUTPUTS
% - s          [struct]    Structure containing the scalars.
%
% REMARKS
% The fieldnames are the names of the scalars. By default all the scalars in db are
% loaded. These variables can be filtered by passing additional strings to the routine
% (varargin). For instance, scalars(db, 'PCB','YOY', 'ALPHA') would only load the scalars
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

iterator = get_sc_iterator(db, wildCard);
info = iterator.nextElement();

s = struct();
s.(char(info.getName())) = char(info.getTiqObjectCopy.getTiqValue());

while iterator.hasMoreElements    
    info = iterator.nextElement();
    s.(char(info.getName())) = char(info.getTiqObjectCopy.getTiqValue());
end
