function b = is64bit()

% Returns true iff operating system is 64-bit
%
% The test logic is the same as in dynare.m when selecting the preprocessor
% flavour.

% Copyright (C) 2017-2019 Dynare Team
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

if ispc
    arch = getenv('PROCESSOR_ARCHITECTURE');
else
    [~, arch] = system('uname -m');
end

b = ~isempty(strfind(arch, '64'));
