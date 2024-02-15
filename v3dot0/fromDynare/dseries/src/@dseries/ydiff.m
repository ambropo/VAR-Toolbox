function o = ydiff(o) % --*-- Unitary tests --*--

% Computes yearly differences.
%
% INPUTS
% - o   [dseries]
%
% OUTPUTS
% - o   [dseries]

% Copyright © 2012-2020 Dynare Team
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
o.ydiff_();

return

%@test:1
try
    data = transpose(1:100);
    ts = dseries(data,'1950Q1',{'A1'},{'A_1'});
    ds = ts.ydiff();
    t(1) = true;
catch
    t(1) = false;
end


if t(1)
    DATA = NaN(4,ts.vobs);
    DATA = [DATA; 4*ones(ts.nobs-4,ts.vobs)];
    t(2) = dassert(ds.data,DATA);
    t(3) = dassert(ds.ops{1},['ydiff(A1)']);
    t(4) = dassert(ts.data, data);
end

T = all(t);
%@eof:1