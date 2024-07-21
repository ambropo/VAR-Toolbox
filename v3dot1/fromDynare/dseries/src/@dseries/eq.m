function b = eq(o, p) % --*-- Unitary tests --*--

% Overloads eq (==) operator.
%
% INPUTS
%  o A      dseries object (T periods, N variables).
%  o B      dseries object (T periods, N variables).
%
% OUTPUTS
%  o C      T*N matrix of zeros and ones. Element C(t,n) is nonzero iff observation t of variable n in A and B are equal.
%
% REMARKS
%  If the number of variables, the number of observations or the frequencies are different in A and B, the function returns a zero scalar.

% Copyright (C) 2013-2017 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if nargin~=2
    error('dseries::eq: I need exactly two input arguments!')
end

if ~(isdseries(o) && isdseries(p))
    error('dseries::eq: Both input arguments must be dseries objects!')
end

if ~isequal(nobs(o), nobs(p))
    warning('dseries::eq: Both input arguments should have the same number of observations!')
    b = 0;
    return
end

if ~isequal(vobs(o), vobs(p))
    warning('dseries::eq: Both input arguments should have the same number of observations!')
    b = 0;
    return
end

if ~isequal(frequency(o),frequency(p))
    warning('dseries::eq: Both input arguments should have the same frequencies!')
    b = 0;
    return
end

if ~isequal(firstdate(o),firstdate(p))
    warning('dseries::eq: Both input arguments should have the same initial period!')
    b = 0;
    return
end

b = eq(o.data, p.data);

%@test:1
%$ % Define a datasets.
%$ A = rand(10,3);
%$
%$ % Define names
%$ A_name = {'A1';'A2';'A3'};
%$
%$ t = zeros(2,1);
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = ts1;
%$    a = eq(ts1,ts2);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(a,logical(ones(10,3)));
%$ end
%$ T = all(t);
%@eof:1