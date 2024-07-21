function ext = get_file_extension(file)

% returns the extension of a file.
%
% INPUTS
%  o file      string, name of the file
%
% OUTPUTS
%  o ext       string, extension.
%
% REMARKS
%  If the provided file name has no extension, the routine will return an empty array.

% Copyright (C) 2013-2017 Dynare Team
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

[dir, fname, ext] = fileparts(file);

if ~isempty(ext)
    % Removes the leading dot.
    ext = ext(2:end);
end