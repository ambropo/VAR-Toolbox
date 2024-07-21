function o = flip(o) % --*-- Unitary tests --*--

% Flips the rows in the data member (without changing the
% periods order)
%
% INPUTS
% - o [dseries]
%
% OUTPUTS
% - o [dseries]

% Copyright © 2020 Dynare Team
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

o = copy(o);
o.flip_;

return
%@test:1
% Define a dates object
data = transpose(1:3);
o = dseries(data);
q = dseries(data);

% Call the tested routine.
try
    p = o.flip();
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
     t(2) = dassert(o, q);
     t(3) = dassert(p.data, [3; 2; 1]);
end

T = all(t);
%@eof:1