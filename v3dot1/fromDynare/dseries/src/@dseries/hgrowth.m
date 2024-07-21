function o = hgrowth(o) % --*-- Unitary tests --*--

% Computes bi-annual growth rates.
%
% INPUTS
% - o   [dseries]
%
% OUTPUTS
% - o   [dseries]

% Copyright (C) 2020 Dynare Team
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

o = copy(o);
o.hgrowth_();

%@test:1
%$ t = zeros(2,1);
%$
%$ try
%$     data = repmat(transpose(1:2),100,1);
%$     ts = dseries(data,'1950Q1');
%$     ds = ts.hgrowth;
%$     t(1) = 1;
%$ catch
%$     t = 0;
%$ end
%$
%$
%$ if length(t)>1
%$     DATA = NaN(2,ts.vobs);
%$     DATA = [DATA; zeros(ts.nobs-2,ts.vobs)];
%$     t(2) = dassert(ds.data,DATA);
%$     t(3) = dassert(ts.data,data);
%$ end
%$
%$ T = all(t);
%@eof:1