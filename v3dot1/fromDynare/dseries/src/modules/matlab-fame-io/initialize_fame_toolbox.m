function initialize_fame_toolbox()

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

% Get path to the current script.
[FAME_TOOLBOX_ROOT_DIRECTORY, ~, ~] = fileparts(which('initialize_fame_toolbox'));

% Load path to TIMEIQ Java library.
try
    locals;
catch
    error('Cannot find the file setting path to TIMEIQ')
end

% Add timeiq.jar if missing in javapath.
jpath = javaclasspath('-all');
TIMEIQ_LIB = [TIMEIQ_PATH filesep() 'lib' filesep() 'timeiq.jar'];
if ~ismember(TIMEIQ_LIB, jpath)
    javaaddpath(TIMEIQ_LIB);
end

% Add fame toolbox in path if missing in matlab path
if isempty(strfind(path, [FAME_TOOLBOX_ROOT_DIRECTORY filesep() 'src']))
    addpath([FAME_TOOLBOX_ROOT_DIRECTORY filesep() 'src'])
end
if isempty(strfind(path, [FAME_TOOLBOX_ROOT_DIRECTORY filesep() 'src' filesep() 'tools']))
    addpath([FAME_TOOLBOX_ROOT_DIRECTORY filesep() 'src' filesep() 'tools'])
end