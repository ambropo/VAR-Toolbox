function o = pop(o, p) % --*-- Unitary tests --*--

% pop method for dates class (removes a date).
%
% INPUTS
% - o [dates]
% - p [dates] object with one element, string which can be interpreted as a date or integer scalar.
%
% OUTPUTS
% - o [dates]
%
% REMARKS
% 1. If a is a date appearing more than once in o, then only the last occurence is removed. If one wants to
%    remove all the occurences of p in o, the remove method should be used instead.
%
% See also remove, setdiff.

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

o = copy(o);

if nargin>1
    o.pop_(p);
else
    o.pop_();
end

%@test:1
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$ B5 = '2009Q2';
%$ d = dates(B4,B3,B2,B1,B5);
%$
%$ % Define expected results
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
%$ e.freq = 4;
%$
%$ % Call the tested routine
%$ try
%$     c = d.pop();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(c.time,e.time(1:end-1,:));
%$     t(3) = dassert(c.freq,e.freq);
%$     t(4) = dassert(d.time,e.time);
%$     t(5) = dassert(d.freq,e.freq);
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$ B5 = '2009Q2';
%$ d = dates(B4,B3,B2,B1,B5);
%$
%$ % Define expected results
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
%$ e.freq = 4;
%$
%$ % Call the tested routine
%$ try
%$     c = d.pop(B5);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(c.time,e.time(1:end-1,:));
%$     t(3) = dassert(c.freq,e.freq);
%$     t(4) = dassert(d.time,e.time);
%$     t(5) = dassert(d.freq,e.freq);
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$ B5 = '2009Q2';
%$ d = dates(B4,B3,B2,B1,B5);
%$
%$ % Define expected results
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
%$ e.freq = 4;
%$
%$ % Call the tested routine
%$ try
%$     c = d.pop(dates(B5));
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(c.time,e.time(1:end-1,:));
%$     t(3) = dassert(c.freq,e.freq);
%$     t(4) = dassert(d.time,e.time);
%$     t(5) = dassert(d.freq,e.freq);
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$ B5 = '2009Q2';
%$ d = dates(B4,B3,B2,B1,B5);
%$
%$ % Define expected results
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
%$ e.freq = 4;
%$
%$ % Call the tested routine
%$ try
%$     c = d.pop(3);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(c.time,e.time([1 2 4 5],:));
%$     t(3) = dassert(c.freq,e.freq);
%$     t(4) = dassert(d.time,e.time);
%$     t(5) = dassert(d.freq,e.freq);
%$ end
%$
%$ T = all(t);
%@eof:4