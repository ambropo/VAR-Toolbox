function o = rename(o, old, new) % --*-- Unitary tests --*--

% Renames variables in a dseries object.
%
% INPUTS
% - o     [dseries]
% - old   [string, cell]
% - new   [string, cell]
%
% OUTPUTS
% - o     [dseries]

% Copyright (C) 2013-2021 Dynare Team
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
if nargin<3
    o.rename_(old);
else
    o.rename_(old, new);
end

%@test:1
%$ ts = dseries([transpose(1:5), transpose(6:10)],'1950q1',{'Output'; 'Consumption'}, {'Y_t'; 'C_t'});
%$ try
%$     ds = ts.rename('Output','Production');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ds.freq,4);
%$     t(3) = dassert(ds.init.freq,4);
%$     t(4) = dassert(ds.init.time,1950*4+1);
%$     t(5) = dassert(ds.vobs,2);
%$     t(6) = dassert(ds.nobs,5);
%$     t(7) = dassert(ds.name,{'Production'; 'Consumption'});
%$     t(8) = dassert(ds.tex,{'Y_t'; 'C_t'});
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ ts = dseries(randn(10,1));
%$ try
%$     ds = ts.rename('Dora');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ds.name,{'Dora'});
%$ end
%$
%$ T = all(t);
%@eof:2