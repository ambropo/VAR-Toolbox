function [l,c,d] = isint(a) % --*-- Unitary tests --*--

%  This function tests if the input argument is an integer.
%
%  INPUT
%  - a    [double]   m*n matrix.
%
%  OUTPUT
%  - l    [logical]  m*n matrix of true and false (1 and 0). l(i,j)=true if a(i,j) is an integer.
%  - c    [integer]  p*1 vector of indices pointing to the integer elements of a.
%  - d    [integer]  q*1 vector of indices pointing to the non integer elements of a.
%
%  REMARKS
%  p+q is equal to the product of m by n.

% Copyright (C) 2009-2017 Dynare Team
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

if ~isnumeric(a)
    l = false;
    if nargout>1
        c = [];
        d = [];
    end
    return
end

l = abs(fix(a)-a)<1e-15;

if nargout>1
    c = find(l==true);
    d = find(l==false);
end

%@test:1
%$ a = 1938;
%$ try
%$     boolean = isint(a);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, true);
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ a = pi;
%$ try
%$     boolean = isint(a);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, false);
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ a = '1';
%$ try
%$     boolean = isint(a);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(boolean, false);
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ a = [1; 2; 3];
%$ try
%$     [boolean, iV, iF]  = isint(a);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(all(boolean), true);
%$     t(3) = dassert(isequal(iV, [1; 2; 3]), true);
%$     t(4) = dassert(isempty(iF), true);
%$ end
%$
%$ T = all(t);
%@eof:4

%@test:5
%$ a = [1; pi; 3];
%$ try
%$     [boolean, iV, iF]  = isint(a);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(all(boolean), false);
%$     t(3) = dassert(isequal(iV, [1; 3]), true);
%$     t(4) = dassert(isequal(iF, 2), true);
%$ end
%$
%$ T = all(t);
%@eof:5