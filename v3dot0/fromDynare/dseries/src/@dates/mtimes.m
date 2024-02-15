function p = mtimes(o,n) % --*-- Unitary tests --*--

% Overloads the times operator (*). Returns dates object o replicated n times.
%
% INPUTS
% - o [dates] object with m elements.
%
% OUTPUTS
% - p [dates] object with m*n elements.
%
% EXAMPLES
% 1. If A = dates('2000Q1'), then B=A*3 is a dates object equal to dates('2000Q1','2000Q1','2000Q1')
% 2. If A = dates('2003Q1','2009Q2'), then B=A*2 is a dates object equal to dates('2003Q1','2009Q2','2003Q1','2009Q2')

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

if ~(isscalar(n) && isint(n))
    error('dates:mtimes:ArgCheck','First and second input arguments have to be a dates object and a scalar integer!')
end

p = copy(o);
p.time = repmat(p.time, n, 1);

%@test:1
%$ % Define some dates
%$ d = dates('1950q2','1950q3');
%$ e = dates('1950q2','1950q3')+dates('1950q2','1950q3');
%$ f = d*2;
%$ i = isequal(e, f);
%$
%$ % Check the results.
%$ t(1) = dassert(i,true);
%$ T = all(t);
%@eof:1
