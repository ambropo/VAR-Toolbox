function B = isdseries(A)

% Returns true iff ```A``` is a dseries object.

% Copyright (C) 2011-2015 Dynare Team
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

if ischar(A)
    if exist(A, 'file')
        [filepath, filename, ext] = fileparts(A);
        switch ext
          case '.mat'
            listofexpectedobjects = {'INIT__', 'FREQ__', 'NAMES__', 'TEX__', 'OPS__', 'TAGS__', 'DATA__'};
            fileContent = load(A);
            listofobjects = fieldnames(fileContent);
            if isempty(setdiff(listofexpectedobjects, listofobjects)) && isempty(setdiff(listofobjects, listofexpectedobjects))
                B = true;
            else
                B = false;
            end
          case '.m'
            listofexpectedobjects = {'INIT__', 'FREQ__', 'NAMES__', 'TEX__', 'OPS__'};
            listofobjects = getlistofvariablesinscript(A);
            listofobjects
            if isempty(setdiff(listofexpectedobjects, listofobjects))
                B = true;
            else
                B = false;
            end
          otherwise
            error('Cannot test %s files.', ext)
        end
    else
        % Input is not a char array referring to a file name.
        B = false;
    end
else
    B = isa(A,'dseries');
end