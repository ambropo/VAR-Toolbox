function b = check_file_extension(file,type)

% Check file extension of a file. Returns 1 (true) if the extension of ```file``` is equal to
% ```type```, 0 (false) otherwise.
%
% INPUTS
% - file [str] file name.
% - type [str] file extension.
%
% OUTPUTS
% - b [bool]


% Copyright (C) 2012-2017 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dseries submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

% Clean-up path
file = strrep(file, '../', '');
file = strrep(file, './', '');

remain = file;
while ~isempty(remain)
    [ext, remain] = strtok(remain,'.');
end

b = strcmp(ext,type);