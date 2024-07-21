function r = octave_ver_less_than(verstr)
% function r = octave_ver_less_than(verstr)
%
% Returns 1 if current Octave version is strictly older than
% the one given in argument.
%
% Note that this function will fail under Matlab.
%
% INPUTS
%    verstr: a string of the format 'x.y' or 'x.y.z'
%
% OUTPUTS
%    r: 0 or 1
%
% SPECIAL REQUIREMENTS
%    none

% Copyright (C) 2008-2019 Dynare Team
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

r = compare_versions(version(), verstr, "<");

endfunction
