function q = max(varargin)  % --*-- Unitary tests --*--

% Overloads the max function for dates objects.
%
% INPUTS
% - varargin [dates]
%
% OUTPUTS
% - q        [dates]

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

if ~all(cellfun(@isdates, varargin))
    error('dates:max:ArgCheck', 'All input arguments must be dates objects.')
end

switch nargin
  case 1
    q = dates();
    q.freq = varargin{1}.freq;
    q.time = max(varargin{1}.time);
  otherwise
    q = max(horzcat(varargin{:}));
end

return

%@test:1
% Define some dates
d3 = dates('1950q2');
d4 = dates('1950Q3');
d5 = dates('1950m1');
d6 = dates('1948M6');
m2 = max(d3,d4);
i2 = (m2==d4);
m3 = max(d5,d6);
i3 = (m3==d5);

% Check the results.
t(1) = dassert(i2,true);
t(2) = dassert(i3,true);
T = all(t);
%@eof:1

%@test:2
% Define some dates
d = dates('1950Q2','1951Q3','1949Q1','1950Q4');
m = max(d);
i = (m==dates('1951Q3'));

% Check the results.
t(1) = dassert(i,true);
T = all(t);
%@eof:2

%@test:3
% Define some dates
m = max(dates('1950Q2','1951Q3'),dates('1949Q1'),dates('1950Q4'));
i = (m==dates('1951Q3'));

% Check the results.
t(1) = dassert(i,true);
T = all(t);
%@eof:3

%@test:4
% Define some dates
m = max(dates('1950Q2'),dates('1951Q3'),dates('1949Q1'),dates('1950Q4'));
i = (m==dates('1951Q3'));

% Check the results.
t(1) = dassert(i,true);
T = all(t);
%@eof:4

%@test:5
try
    M = max(dates('2009-04-12', '1966-11-02'), dates('1938-11-22'), dates('1972-01-25', '1976-03-13'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = M==dates('2009-04-12');
end

T = all(t);
%@eof:5
