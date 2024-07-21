function q = backcast(o, p, diff)  % --*-- Unitary tests --*--

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

q = copy(o);

if nargin>2
    q.backcast_(p, diff);
else
    q.backcast_(p);
end

return

%@test:1
  y = ones(10,1);
  for i=2:10
    y(i) = 1.1*y(i-1);
  end

  ds = dseries(y(6:10), '1990Q1', 'toto');
  ts = dseries(y(1:6), '1988Q4', 'popeye');

  try
    ds = backcast(ds, ts);
    t(1) = true;
  catch
    t(1) = false;
  end

  if t(1)
    t(2) = dassert(ds.freq,4);
    t(3) = dassert(ds.init.freq,4);
    t(4) = dassert(ds.init.time,1988*4+4);
    t(5) = dassert(ds.vobs,1);
    t(6) = dassert(ds.nobs,10);
    t(7) = abs(ds.data(1)-1)<1e-9;
  end

  T = all(t);
%@eof:1