function p = copy(o) % --*-- Unitary tests --*--

% Do a copy of a dates object.
%
% INPUTS
% - o [dates]
%
% OUTPUTS
% - p [dates]

% Copyright © 2014-2020 Dynare Team
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

p = dates();
p.freq = o.freq;
p.time = o.time;

return

%@test:1
% Define a dates object
o = dates('1945Q3','1944Q4');
q = dates('1945Q3','1944Q4');

% Call the tested routine.
try
    p = copy(o);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
     o.sort_();
     t(2) = dassert(p, q);
end

T = all(t);
%@eof:1