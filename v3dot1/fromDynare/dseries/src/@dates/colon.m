function q = colon(varargin) % --*-- Unitary tests --*--

% Overloads the colon operator (:). This method can be used to create ranges of dates.
%
% INPUTS
%  o o [dates] Initial date.
%  o d [integer] Number of periods between each date (default value, if nargin==2, is one)
%  o p [dates] Terminal date.
%
% OUTPUTS
%  o q [dates] Object with length(p-o) elements (if d==1).
%
% REMARKS
% 1. p must be greater than o if d>0.
% 2. p and q are dates objects with one element.

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

% Check the input arguments.
if isequal(nargin, 2)
    o = varargin{1};
    p = varargin{2};
    d = 1;
    if ~(isa(o, 'dates') && isa(p, 'dates') && isequal(o.length(), 1) && isequal(p.length(), 1))
        error('dates:colon:ArgCheck', 'In an expression like A:B, A and B must be one element dates objects.')
    end
elseif isequal(nargin,3)
    o = varargin{1};
    p = varargin{3};
    d = varargin{2};
    if ~(isa(o, 'dates') && isa(p, 'dates') && isequal(o.length(), 1) && isequal(o.length(), 1) && isscalar(d) && isint(d))
        error('dates:colon:ArgCheck', 'In an expression like A:d:B, A and B must be one element dates objects and d a scalar integer.')
    end
    if isequal(d, 0)
        error('dates:colon:ArgCheck', 'In an expression like A:d:B, d (the incremental number of periods) must nonzero.')
    end
else
    error('dates:colon:ArgCheck', 'See the manual for the colon (:) operator and dates objects.')
end

if ~isequal(o.freq, p.freq)
    error('dates:colon:ArgCheck', 'Input arguments %s and %s must have common frequency.', inputname(1), inputname(2))
end

if o>p && d>0
    error('dates:colon:ArgCheck', 'First date must preceed the second one.')
end

if p>o && d<0
    error('dates:colon:ArgCheck', 'Second date must preceed the first one.')
end

% Initialize the output argument.
q = dates();

% Set the frequency in q
q.freq = o.freq;

% Set time
q.time = transpose(o.time:d:p.time);

return

%@test:1
% Define two dates
date_1 = '1950Q2';
date_2 = '1951Q4';

% Define expected results.
e.freq = 4;
e.time = [1950*4+2; 1950*4+3; 1950*4+4; 1951*4+1; 1951*4+2; 1951*4+3; 1951*4+4];

% Call the tested routine.
d1 = dates(date_1);
d2 = dates(date_2);
d3 = d1:d2;

% Check the results.
t(1) = isequal(d3.time, e.time);
t(2) = isequal(d3.freq, e.freq);
T = all(t);
%@eof:1

%@test:2
% Define expected results.
e.freq = 4;
e.time = [1950*4+2; 1950*4+3; 1950*4+4; 1951*4+1; 1951*4+2; 1951*4+3; 1951*4+4];

% Call the tested routine.
d = dates('1950Q2'):dates('1951Q4');

% Check the results.
t(1) = isequal(d.time, e.time);
t(2) = isequal(d.freq, e.freq);
T = all(t);
%@eof:2

%@test:3
% Define expected results.
e.freq = 4;
e.time = [1950*4+2; 1950*4+4; 1951*4+2; 1951*4+4];

% Call the tested routine.
d = dates('1950Q2'):2:dates('1951Q4');

% Check the results.
t(1) = isequal(d.time, e.time);
t(2) = isequal(d.freq, e.freq);
T = all(t);
%@eof:3


%@test:4
% Create an empty dates object for quaterly data
qq = dates('Q');

% Define expected results.
e.freq = 4;
e.time = [1950*4+2; 1950*4+3; 1950*4+4; 1951*4+1; 1951*4+2; 1951*4+3; 1951*4+4];

% Call the tested routine.
d = qq(1950,2):qq(1951,4);

% Check the results.
t(1) = isequal(d.time, e.time);
t(2) = isequal(d.freq, e.freq);
T = all(t);
%@eof:4

%@test:5
% Create an empty dates object for quaterly data
qq = dates('Q');

% Define expected results.
e.freq = 4;
e.time = [1950*4+1; 1950*4+2; 1950*4+3];

% Call the tested routine.
d = qq(1950,1):qq(1950,3);

% Check the results.
t(1) = isequal(d.time, e.time);
t(2) = isequal(d.freq, e.freq);
T = all(t);
%@eof:5

%@test:6
% Create an empty dates object for daily data
dd = dates('D');

% Define expected results.
e.freq = 365;
e.time = [712251; 712252; 712253];

% Call the tested routine.
d = dd(1950, 01, 28):dd(1950, 01, 30);

% Check the results.
t(1) = isequal(d.time(:,1), e.time(:,1));
t(2) = isequal(d.freq, e.freq);
T = all(t);
%@eof:6