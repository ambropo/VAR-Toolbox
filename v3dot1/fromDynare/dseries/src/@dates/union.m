function o = union(varargin) % --*-- Unitary tests --*--

% Overloads union function for dates objects (removes repetitions if any).
%
% INPUTS
% - varargin [dates]
%
% OUPUTS
% - o        [dates]
%
% REMARKS
% 1. Elements in o are sorted by increasing order.

% Copyright © 2013-2021 Dynare Team
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

if ~all(cellfun(@isdates,varargin))
    error('dates:union:ArgCheck', 'All input arguments must be dates objects.')
end

if isequal(nargin, 1)
    o = sort(unique(varargin{1}));
    return;
end

o = sort(unique(horzcat(varargin{:})));

return

%@test:1
% Define some dates objects
d1 = dates('1950Q1'):dates('1959Q4') ;
d2 = dates('1960Q1'):dates('1969Q4') ;
d3 = dates('1970Q1'):dates('1979Q4') ;

% Call the tested routine.
e1 = union(d1);
e2 = union(d1,d2);
e3 = union(d1,d2,d3);
e4 = union(d1,d2,d3,d2+d3);
e5 = union(d1,d2,d3,d2);

% Check the results.
t(1) = dassert(e1,d1);
t(2) = dassert(e2,d1+d2);
t(3) = dassert(e3,d1+d2+d3);
t(4) = dassert(e4,d1+d2+d3);
t(5) = dassert(e5,d1+d2+d3);
T = all(t);
%@eof:1

%@test:1
% Define some dates objects
d1 = dates('2000-01-01'):dates('2000-01-05');
d2 = dates('2000-01-05'):dates('2000-01-10');
d3 = dates('2000-01-01'):dates('2000-01-10');

% Call the tested routine.
e1 = union(d1);
e2 = union(d1,d2);

% Check the results.
t(1) = isequal(e1, d1);
t(2) = isequal(e2, d3);
T = all(t);
%@eof:1