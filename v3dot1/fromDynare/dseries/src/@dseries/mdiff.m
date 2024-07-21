function o = mdiff(o) % --*-- Unitary tests --*--

% Computes monthly differences.
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

o = copy(o);
o.mdiff_();

%@test:1
%$ try
%$     data = transpose(0:1:50);
%$     ts = dseries(data,'1950M1');
%$     ds = ts.mdiff();
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     DATA = NaN(1,ds.vobs);
%$     DATA = [DATA; ones(ds.nobs-1,ds.vobs)];
%$     t(2) = dassert(ds.data, DATA, 1e-15);
%$     t(3) = dassert(ts.data, data, 1e-15);
%$ end
%$
%$ T = all(t);
%@eof:1