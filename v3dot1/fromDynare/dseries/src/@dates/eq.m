function l = eq(varargin) % --*-- Unitary tests --*--

% Overloads == operator for dates objects.
%
% INPUTS
% - o [dates] dates object with n or 1 elements.
% - p [dates] dates object with n or 1 elements.
%
% OUTPUTS
% - l [logical] column vector of max(n,1) elements (zeros or ones).

% Copyright © 2013-2020 Dynare Team
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

if varargin{1}.ndat>1 && varargin{2}.ndat>1 && ~isequal(varargin{1}.ndat, varargin{2}.ndat)
    l = false;
    return
end

[o, p] = comparison_arg_checks(varargin{:});

if isequal(o.ndat(), p.ndat())
    l = eq(o.time(:),p.time(:));
else
    l = bsxfun(@eq,o.time(:,1),p.time(:,1));
end

return

%@test:1
% Define some dates objects
d1 = dates('1950Q1','1950Q2','1950Q3','1950Q4') ;
d2 = dates('1960Q1','1960Q2','1960Q3','1960Q4') ;
d3 = dates('1950Q1','1960Q2','1950Q3','1960Q4') ;

% Call the tested routine.
try
    t1 = d1==d1;
    t2 = d1==d2;
    t3 = d1==d3;
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(t1, true(4,1));
    t(3) = isequal(t2, false(4,1));
    t(4) = isequal(t3, [true; false; true; false]);
end
T = all(t);
%@eof:1

%@test:2
% Define some dates objects
d1 = dates('1950Q1') ;
d2 = dates('1960Q1') ;
d3 = dates('1960Q1') ;

% Call the tested routine.
try
    t1 = d1==d1;
    t2 = d1==d2;
    t3 = d1==d3;
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = t1;
    t(3) = ~t2;
    t(4) = ~t3;
end

T = all(t);
%@eof:2

%@test:3
% Define some dates objects
d1 = dates('1950Q1','1950Q2','1950Q3','1950Q4') ;
d2 = dates('1950Q2') ;
d3 = dates('1970Q1') ;

% Call the tested routine.
try
    t1 = d1==d2;
    t2 = d1==d3;
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = isequal(t1, [false; true; false; false]);
    t(3) = isequal(t2, false(4,1));
end

T = all(t);
%@eof:3

%@test:4
% Define some dates objects
d1 = dates('2000-01-01','2000-01-02','2000-01-03');
d2 = dates('2000-01-02');


% Call the tested routine.
try
    t1 = d1==d2;
    t(1) = true;
catch
    t(1) = false;
end

% Check the results.
if t(1)
    t(2) = ~t1(1) && t1(2) && ~t1(3);
end

T = all(t);
%@eof:4