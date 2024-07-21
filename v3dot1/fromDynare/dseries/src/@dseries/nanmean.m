function m = nanmean(o, geometric) % --*-- Unitary tests --*--

% Returns the mean of the variables in a @dseries object o (robust
% to the presence of NaNs).
%
% INPUTS
% - o             dseries object [mandatory].
% - geometric     logical [default is false], if true returns the geometric mean.
%
% OUTPUTS
% - m             1*vobs(o) vector of doubles.

% Copyright © 2019-2020 Dynare Team
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

if nargin<2
    geometric = false;
end

if geometric
    m = NaN(1,o.vobs());
    for i = 1:o.vobs()
        tmp = o.data(~isnan(o.data(:,i)),i);
        m(i) = prod(tmp)^(1.0/length(tmp));
    end
else
    m = nanmean(o.data);
end

return
%@test:1
% Define a dataset.
A = repmat([1.005, 1.05], 10, 1);
A(3,1) = NaN;
A(5,2) = NaN;

% Instantiate a time series object and compute the mean.
try
   ts = dseries(A);
   m = nanmean(ts);
   t(1) = 1;
catch
   t = 0;
end

if t(1)
   t(2) = dassert(isequal(size(m),[1, 2]), true);
   t(3) = dassert(m, [1.005, 1.05]);
end
T = all(t);
%@eof:1

%@test:2
% Define a dataset.
a = [1 0; NaN 2; 3 4];

% Instantiate a time series object and compute the geometric mean.
try
   ts = dseries(a);
   m = nanmean(ts, true);
   t(1) = 1;
catch
   t = 0;
end

if t(1)
   t(2) = dassert(isequal(size(m),[1, 2]), true);
   t(3) = dassert(m, [sqrt(3), 0]);
end
T = all(t);
%@eof:2