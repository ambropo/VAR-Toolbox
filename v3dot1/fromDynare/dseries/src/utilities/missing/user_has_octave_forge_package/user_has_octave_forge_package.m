function [hasPackage] = user_has_octave_forge_package(package)
% Checks for the availability of a given Octave Forge package

% Copyright (C) 2012-2017 Dynare Team
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

[desc,flag] = pkg('describe', package);

if isequal(flag{1,1}, 'Not installed')
    hasPackage = 0;
else
    if isequal(flag{1,1}, 'Not loaded')
        pkg('load', package);
    end
    hasPackage = 1;
end
