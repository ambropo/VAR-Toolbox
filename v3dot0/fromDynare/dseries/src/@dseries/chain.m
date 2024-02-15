function q = chain(o, p)  % --*-- Unitary tests --*--

% Chains two dseries objects.
%
% INPUTS
% - o     [dseries]
% - p     [dseries]
%
% OUTPUTS
% - q     [dseries]
%
% REMARKS
% The two dseries objects must have common frequency and the same number of variables. Also the
% two samples must overlap.

% Copyright (C) 2014-2021 Dynare Team
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

q = copy(o);
q.chain_(p);

%@test:1
%$ try
%$     ts = dseries([1; 2; 3; 4],dates('1950Q1')) ;
%$     us = dseries([3; 4; 5; 6],dates('1950Q3')) ;
%$     vs = chain(ts,us);
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(vs.freq, 4);
%$     t(3) = dassert(vs.init.freq, 4);
%$     t(4) = dassert(vs.init.time, 1950*4+1);
%$     t(5) = dassert(vs.vobs, 1);
%$     t(6) = dassert(vs.nobs, 6);
%$     t(7) = isequal(vs.data, transpose(1:6));
%$     t(8) = isequal(ts.data, transpose(1:4));
%$     t(9) = isequal(ts.init.time, 1950*4+1);
%$ end
%$
%$ T = all(t);
%@eof:1