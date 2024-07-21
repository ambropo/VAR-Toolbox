function [q, io] = setdiff(o, p) % --*-- Unitary tests --*--

% Overloads setdiff function for dates objects.
%
% INPUTS
% - o  [dates]
% - p  [dates]
%
% OUTPUTS
% - q  [dates]   with n elements
% - io [integer] n*1 vector of integers such that q = o(io)
%
% See also pop, remove.

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

if ~isa(o, 'dates') || ~isa(o, 'dates')
    error('dates:setdiff', 'All input arguments must be dates objects.')
end

if ~isequal(o.freq, p.freq)
    error('dates:setdiff', 'All input arguments must have common frequency.')
end

if isempty(p)
    q = copy(o);
    if nargout>1, io = 1:length(q); end
    return
end

if isequal(o.length(), p.length()) && isequal(o, p)
    % Return an empty dates object.
    q = dates(o.freq);
    if nargout>1, io = []; end
    return
end

if isoctave && octave_ver_less_than('6')
    if nargout<2
        time = setdiff(o.time, p.time);
    else
        [time, io] = setdiff(o.time, p.time);
    end
else
    if nargout<2
        time = setdiff(o.time, p.time, 'legacy');
    else
        [time, io] = setdiff(o.time, p.time, 'legacy');
    end
end

q = dates(o.freq);
q.time = time;

return

%@test:1
% Define some dates objects
d1 = dates('1950Q1'):dates('1950Q4') ;
d2 = dates('1950Q3'):dates('1950Q4') ;

% Call the tested routine.
try
    c1 = setdiff(d1,d2);
    [c2, i] = setdiff(d1,d2);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(c1,c2);
    t(3) = isequal(d1(i),c2);
end
T = all(t);
%@eof:1

%@test:2
% Define some dates objects
d1 = dates('1950Q1'):dates('1950Q4') ;
d2 = dates('1950M3'):dates('1950M4') ;

% Call the tested routine.
try
    c1 = setdiff(d1,d2);
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:2

%@test:3
% Define some dates objects
d = dates('1950Q1'):dates('1950Q4') ;

% Call the tested routine.
try
    c1 = setdiff(d,1);
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:3

%@test:4
% Define some dates objects
d1 = dates('1950Q1'):dates('1950Q4') ;
d2 = dates('1951Q3'):dates('1951Q4') ;

% Call the tested routine.
try
    c1 = setdiff(d1,d2);
    [c2, i] = setdiff(d1,d2);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(isequal(c1,d1),true);
    t(3) = isequal(isequal(c1,d1(i)),true);
end
T = all(t);
%@eof:4

%@test:5
% Define some dates objects
d1 = dates('1950Q1'):dates('1950Q4') ;

% Call the tested routine.
try
    c1 = setdiff(d1,d1);
    [c2, i] = setdiff(d1,d1);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(isempty(c1),true);
    t(3) = isequal(isempty(c2),true);
    t(4) = isequal(isempty(i),true);
end
T = all(t);
%@eof:5

%@test:6
% Define some dates objects
d1 = dates('2000-01-01'):dates('2000-01-10');
d2 = dates('2000-01-05'):dates('2000-01-10');
d3 = dates('2000-01-01'):dates('2000-01-04');
% Call the tested routine.
try
    c1 = setdiff(d1, d2);
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(c1, d3);
end
T = all(t);
%@eof:6
