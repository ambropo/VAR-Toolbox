function r = matlab_ver_less_than(verstr)

% Returns 1 if current Matlab version is strictly older than the one given in argument.
%
% INPUTS
% - verstr  [string]  Matlab's version as 'x.y' or 'x.y.z'
%
% OUTPUTS
% - r       [logical] true or false (0 or 1)
%
% REMARKS
% 1. This function will fail under Octave.

% Copyright (C) 2008-2017 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

r = verLessThan('matlab', verstr);