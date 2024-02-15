function q = plus(o, p) % --*-- Unitary tests --*--

% Overloads the plus (+) binary operator.
%
% INPUTS
% - o [dates,integer]
% - p [dates,integer]
%
% OUTPUTS
% - q [dates]
%
% REMARKS
% 1. If o and p are dates objects the method combines o and p without removing repetitions.
% 2. If  one of the inputs is an integer or a vector of integers, the method shifts the dates
%    object by X (the interger input) periods forward.

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

if isa(o, 'dates') && isa(p, 'dates')
    % Concatenate dates objects without removing repetitions if o and p are not disjoint sets of dates.
    if ~isequal(o.freq, p.freq)
        error('dates:plus:ArgCheck', 'Input arguments must have common frequency.')
    end
    if isempty(p)
        q = copy(o);
        return
    end
    if isempty(o)
        q = copy(p);
        return
    end
    q = dates();
    q.freq = o.freq;
    q.time = [o.time; p.time];
elseif isa(o, 'dates') || isa(p, 'dates')
    if isa(o, 'dates') && ((isvector(p) && isequal(length(p), o.ndat()) && all(isint(p))) || ...
                          (isequal(o.length(), 1) && isvector(p) && all(isint(p))) || ...
                          (isscalar(p) && isint(p)))
        q = dates();
        q.freq = o.freq;
        q.time = o.time+p(:);
    elseif isa(p, 'dates') && ((isvector(o) && isequal(length(o), p.ndat()) && all(isint(o))) || ...
                              (isequal(p.length(), 1) && isvector(o) && all(isint(o))) || ...
                              (isscalar(o) && isint(o)) )
        q = dates();
        q.freq = p.freq;
        q.time = p.time+o(:);
    else
        error('dates:plus:ArgCheck','Please read the manual.')
    end
else
    error('dates:plus:ArgCheck','Please read the manual.')
end

return

%@test:1
% Define some dates objects
d1 = dates('1950Q1','1950Q2') ;
d2 = dates('1950Q3','1950Q4') ;
d3 = dates('1950Q1','1950Q2','1950Q3','1950Q4') ;

% Call the tested routine.
try
  e1 = d1+d2;
  e2 = d1+d2+d3;
  t(1) = 1;
catch
  t(1) = 0;
end

if t(1)
  t(2) = dassert(e1,d3);
  t(3) = dassert(e2,dates('1950Q1','1950Q2','1950Q3','1950Q4','1950Q1','1950Q2','1950Q3','1950Q4'));
end
T = all(t);
%@eof:1

%@test:2
% Define some dates objects
d1 = dates('1950Q1');
e1 = dates('1950Q2');
e2 = dates('1950Q3');
e3 = dates('1950Q4');
e4 = dates('1951Q1');
e5 = dates('1950Q2','1950Q3','1950Q4','1951Q1');

% Call the tested routine.
try
  f1 = d1+1;
  f2 = d1+2;
  f3 = d1+3;
  f4 = d1+4;
  f5 = d1+transpose(1:4);
  t(1) = 1;
catch
  t(1) = 0;
end

if t(1)
  t(2) = dassert(e1,f1);
  t(3) = dassert(e2,f2);
  t(4) = dassert(e3,f3);
  t(5) = dassert(e4,f4);
  t(6) = dassert(e5,f5);
end
T = all(t);
%@eof:2

%@test:3
% Define some dates objects
d1 = dates('1950Q1');
e1 = dates('1949Q4');
e2 = dates('1949Q3');
e3 = dates('1949Q2');
e4 = dates('1949Q1');
e5 = dates('1948Q4');

% Call the tested routine.
try
  f1 = d1+(-1);
  f2 = d1+(-2);
  f3 = d1+(-3);
  f4 = d1+(-4);
  f5 = d1+(-5);
  t(1) = 1;
catch
  t(1) = 0;
end

if t(1)
  t(2) = dassert(e1,f1);
  t(3) = dassert(e2,f2);
  t(4) = dassert(e3,f3);
  t(5) = dassert(e4,f4);
  t(6) = dassert(e5,f5);
end
T = all(t);
%@eof:3

%@test:4
% Define some dates objects
d1 = dates('2000-12-31');
d2 = dates('2000-02-29');
d3 = dates('2001-02-28');

% Call the tested routine.
try
  f1 = d1+1;
  f2 = d2+1;
  f3 = d3+1;
  t(1) = true;
catch
  t(1) = false;
end

if t(1)
  t(2) = isequal(char(f1), '2001-01-01');
  t(3) = isequal(char(f2), '2000-03-01');
  t(4) = isequal(char(f3), '2001-03-01');
end
T = all(t);
%@eof:4

