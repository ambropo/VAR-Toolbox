function o = diff_(o) % --*-- Unitary tests --*--

% Computes differences, independently of the frequency.
%
% INPUTS
% - o   [dseries]
%
% OUTPUTS
% - o   [dseries]

% Copyright (C) 2017 Dynare Team
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

o.data(2:end,:) = o.data(2:end,:)-o.data(1:end-1,:);
o.data(1,:) = NaN;

for i = 1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {['diff(' o.name{i} ')']};
    else
        o.ops(i) = {['diff(' o.ops{i} ')']};
    end
end

%@test:1
%$ try
%$     data = transpose(0:1:50);
%$     ts = dseries(data,'1950Q1');
%$     ts.diff_;
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     DATA = NaN(1,ts.vobs);
%$     DATA = [DATA; ones(ts.nobs-1,ts.vobs)];
%$     t(2) = dassert(ts.data,DATA,1e-15);
%$ end
%$
%$ T = all(t);
%@eof:1