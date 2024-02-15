function o = sort(o) % --*-- Unitary tests --*--

% Sort method for dates class (with copy).
%
% INPUTS
% - o [dates]
%
% OUTPUTS
% - o [dates] with dates sorted by increasing order.

% Copyright (C) 2011-2021 Dynare Team
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

o = copy(o);
o.sort_();

%@test:1
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$
%$ % Define expected results.
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4];
%$ e.freq = 4;
%$ f.time = [1953*4+4; 1950*4+2; 1950*4+1; 1945*4+3];
%$
%$ % Call the tested routine.
%$ d = dates(B1,B2,B3,B4);
%$ try
%$     c = d.sort();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$     t(2) = dassert(d.time,f.time);
%$     t(3) = dassert(c.time,e.time);
%$     t(4) = dassert(d.freq,e.freq);
%$     t(5) = dassert(c.freq,e.freq);
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$
%$ % Define expected results.
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4];
%$ e.freq = 4;
%$ f.time = [1953*4+4; 1950*4+2; 1950*4+1; 1945*4+3];
%$
%$ % Call the tested routine.
%$ d = dates(B1,B2,B3,B4);
%$ try
%$     c = sort(d);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$     t(2) = dassert(d.time,f.time);
%$     t(3) = dassert(c.time,e.time);
%$     t(4) = dassert(d.freq,e.freq);
%$     t(5) = dassert(c.freq,e.freq);
%$ end
%$ T = all(t);
%@eof:2