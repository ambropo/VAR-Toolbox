function s = nanstd(o, geometric) % --*-- Unitary tests --*--

% Returns the standard deviation of the variables in a @dseries object o (robust
% to the presence of NaNs).
%
% INPUTS
% - o             dseries object [mandatory].
% - geometric     logical [default is false], if true returns the geometric mean.
%
% OUTPUTS
% - s             1*vobs(o) vector of doubles.
%
% REMARKS
% See https://en.wikipedia.org/wiki/Geometric_standard_deviation for the definition of the geometric standard deviation.

% Copyright © 2020 Dynare Team
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

s = NaN(1, o.vobs());

if geometric
    for i = 1:o.vobs()
        tmp = o.data(~isnan(o.data(:,i)),i);
        m = prod(tmp)^(1.0/length(tmp));
        s(i) = exp(sqrt(sum(log(bsxfun(@rdivide, tmp, m)).^2, 1)/nobs(tmp)));
    end
else
    for i=1:o.vobs()
        tmp = o.data(~isnan(o.data(:,i)),i);
        s(i) = std(tmp);
    end
end

return
%@test:1
% Define a dataset.
A = randn(10000000,2);
A(3,1) = NaN;
A(5,2) = NaN;

% Instantiate a time series object and compute the mean.
try
   ts = dseries(A);
   s = nanstd(ts);
   t(1) = true;
catch
   t = false;
end

if t(1)
   t(2) = dassert(isequal(size(s),[1, 2]), true);
   t(3) = all(abs(s-ones(1, 2))<1e-3);
end
T = all(t);
%@eof:1