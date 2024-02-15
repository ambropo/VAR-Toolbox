function lastIndex = end(o, k, n) % --*-- Unitary tests --*--

% Overloads end keyword.
%
% INPUTS
%   o [dates]
%   k [integer]  index where end appears
%   n [integer]  number of indices
%
% OUTPUTS
%   lastIndex [integer] last dates index

% Copyright (C) 2013-2017 Dynare Team
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

assert(k==1 && n==1, 'dates:end:ArgCheck', 'dates only has one dimension');
lastIndex = o.ndat();

%@test:1
%$ % Define a dates object
%$ o = dates('1938Q4'):dates('2015Q4');
%$ q = dates('2015Q4');
%$
%$ % Call the tested routine.
%$ try
%$     p = o(end);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$      t(2) = dassert(p, q);
%$ end
%$
%$ T = all(t);
%@eof:1