function o = remove(o, p) % --*-- Unitary tests --*--

% remove method for dates class (removes dates).
%
% INPUTS
% - o [dates]
% - p [dates]
%
% OUTPUTS
% - o [dates]
%
% REMARKS
% 1. If a is a date appearing more than once in o, then all occurences are removed.
% 2. The removal of p is done by inplace modification of o (in place version of setdiff).
%
% See also pop, setdiff

% Copyright (C) 2013-2021 Dynare Team
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

if nargin<2
    error('dates:remove', 'Input argument is missing! You should read the manual')
end

if ~isdates(p)
    error('dates:remove', 'Input argument %s has to be a dates object')
end

if ~isequal(o.freq, p.freq)
    error('dates:remove', 'Inputs must have common frequency!')
end

o = copy(o);
o.remove_(p);

%@test:1
%$ % Define some dates objects
%$ d = dates('1950Q1'):dates('1952Q4');
%$ e = dates('1951Q1'):dates('1952Q4');
%$ f = dates('1950Q1'):dates('1950Q4');
%$ g = copy(d);
%$
%$ % Call the tested routine.
%$ try
%$     c = d.remove(e);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$     t(2) = dassert(c,f);
%$     t(3) = dassert(d,g);
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define some dates objects
%$ d = dates('1950Q1','1950Q2','1950Q1');
%$ e = dates('1950Q1');
%$ f = dates('1950Q2');
%$
%$ % Call the tested routine.
%$ try
%$     c = d.remove(e);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$     t(2) = dassert(c,f);
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define some dates objects
%$ d = dates('1950Q1','1950Q2','1950Q1');
%$ e = dates('1950Q1');
%$
%$ % Call the tested routine.
%$ try
%$     c = d.remove();
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define some dates objects
%$ d = dates('1950Q1','1950Q2','1950Q1');
%$ e = '1950Q1';
%$
%$ % Call the tested routine.
%$ try
%$     c = d.remove(e);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:4

%@test:5
%$ % Define some dates objects
%$ d = dates('1950Q1','1950Q2','1950Q1');
%$ e = dates('1950M1');
%$
%$ % Call the tested routine.
%$ try
%$     c = d.remove();
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:5
