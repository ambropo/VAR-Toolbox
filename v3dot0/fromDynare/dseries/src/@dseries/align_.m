function [o, p] = align_(o, p) % --*-- Unitary tests --*--

% If necessay completes dseries object o and p so that they are defined on the same time range
% (in place modification).
%
% INPUTS
% - o [dseries]
% - p [dseries]
%
% OUTPUTS
% - o [dseries]
% - p [dseries]

% Copyright (C) 2013-2018 Dynare Team
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

if ~isequal(frequency(o),frequency(p))
    error(['dseries::align: ''' inputname(1) ''' and ''' inputname(2) ''' dseries objects must have common frequencies!'])
end

if isempty(intersect(o.dates,p.dates))
    error(['dseries::align: ''' inputname(1) ''' and ''' inputname(2) ''' dseries object must have at least one common date!'])
end

init = min(firstdate(o),firstdate(p));
last = max(lastdate(o),lastdate(p));

if firstdate(p)>init
    n = firstdate(p)-init;
    p.data = [NaN(n, vobs(p)); p.data];
end

if firstdate(o)>init
    n = firstdate(o)-init;
    o.data = [NaN(n, vobs(o)); o.data];
end

if lastdate(p)<last
    n = last-lastdate(p);
    p.data = [p.data; NaN(n, vobs(p))];
end

if lastdate(o)<last
    n = last-lastdate(o);
    o.data = [o.data; NaN(n, vobs(o))];
end

o.dates = init:init+(nobs(o)-1);
p.dates = init:init+(nobs(p)-1);

%@test:1
%$ % Define a datasets.
%$ A = rand(8,3); B = rand(7,2);
%$
%$ % Define names
%$ A_name = {'A1';'A2';'A3'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define initial dates
%$ A_init = '1990Q1';
%$ B_init = '1989Q2';
%$
%$ % Instantiate two dseries objects
%$ ts1 = dseries(A,A_init,A_name);
%$ ts2 = dseries(B,B_init,B_name);
%$
%$ try
%$   [ts1, ts2] = align(ts1, ts2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(ts1.nobs,ts2.nobs);
%$   t(3) = dassert(ts1.init,ts2.init);
%$   t(4) = dassert(ts1.data,[NaN(3,3); A], 1e-15);
%$   t(5) = dassert(ts2.data,[B; NaN(4,2)], 1e-15);
%$   t(6) = dassert(ts1.dates, ts2.dates);
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a datasets.
%$ A = rand(8,3); B = rand(7,2);
%$
%$ % Define names
%$ A_name = {'A1';'A2';'A3'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define initial dates
%$ A_init = '1990Q1';
%$ B_init = '1990Q1';
%$
%$ % Instantiate two dseries objects
%$ ts1 = dseries(A,A_init,A_name);
%$ ts2 = dseries(B,B_init,B_name);
%$
%$ try
%$   [ts1, ts2] = align(ts1, ts2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(ts1.nobs,ts2.nobs);
%$   t(3) = dassert(ts1.init,ts2.init);
%$   t(4) = dassert(ts1.data,A, 1e-15);
%$   t(5) = dassert(ts2.data,[B; NaN(1,2)], 1e-15);
%$   t(6) = dassert(ts1.dates, ts2.dates);
%$ end
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define a datasets.
%$ A = rand(8,3); B = rand(7,2);
%$
%$ % Define names
%$ A_name = {'A1';'A2';'A3'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define initial dates
%$ A_init = '1990Q1';
%$ B_init = '1990Q1';
%$
%$ % Instantiate two dseries objects
%$ ts1 = dseries(A,A_init,A_name);
%$ ts2 = dseries(B,B_init,B_name);
%$
%$ try
%$   [ts2, ts1] = align(ts2, ts1);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(ts1.nobs,ts2.nobs);
%$   t(3) = dassert(ts1.init,ts2.init);
%$   t(4) = dassert(ts1.data,A, 1e-15);
%$   t(5) = dassert(ts2.data,[B; NaN(1,2)], 1e-15);
%$   t(6) = dassert(ts1.dates, ts2.dates);
%$ end
%$ T = all(t);
%@eof:3