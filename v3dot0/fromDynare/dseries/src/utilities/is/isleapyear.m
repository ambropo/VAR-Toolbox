function b = isleapyear(y)

% Returns true iff y is a leap year.
%
% INPUTS
% - y     [integer]     scalar, year.
%
% OUTPUTS
% - b     [logical]     scalar, equal to true iff y is a leap year.


% Copyright © 2015-2020 Dynare Team
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

if isnumeric(y) && isscalar(y) && isint(y)
    b = isequal(mod(y,4), 0) && ( ~isequal(mod(y, 100), 0) || isequal(mod(y, 400), 0) );
else
    error('Input must be an integer scalar.')
end