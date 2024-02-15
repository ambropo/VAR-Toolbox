function o = mgrowth_(o) % --*-- Unitary tests --*--

% Computes monthly growth rates.
%
% INPUTS
% - o   [dseries]
%
% OUTPUTS
% - o   [dseries]

% Copyright (C) 2017-2020 Dynare Team
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

switch frequency(o)
  case 1
    error('dseries::mgrowth: I cannot compute monthly growth rates from yearly data!')
  case 2
    error('dseries::mgrowth: I cannot compute monthly growth rates from bi-annual data!')
  case 4
    error('dseries::mgrowth: I cannot compute monthly growth rates from quaterly data!')
  case 12
    o.data(2:end,:) = o.data(2:end,:)./o.data(1:end-1,:) - 1;
    o.data(1,:) = NaN;
  case 52
    error('dseries::mgrowth: I do not know yet how to compute monthly growth rates from weekly data!')
  case 365
    error('dseries::mgrowth: I do not know yet how to compute monthly growth rates from daily data!')
  otherwise
    error(['dseries::mgrowth: object ' inputname(1) ' has unknown frequency']);
end

for i = 1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {['mgrowth(' o.name{i} ')']};
    else
        o.ops(i) = {['mgrowth(' o.ops{i} ')']};
    end
end

%@test:1
%$ try
%$     data = (1+.01).^transpose(0:1:50);
%$     ts = dseries(data,'1950Q1');
%$     ts.mgrowth_;
%$     t(1) = 0;
%$ catch
%$     t(1) = 1;
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     data = (1+.01).^transpose(0:1:80);
%$     ts = dseries(data, '1950M1');
%$     ts.mgrowth_;
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     DATA = NaN(1,ts.vobs);
%$     DATA = [DATA; (1.01-1)*ones(ts.nobs-1, ts.vobs)];
%$     t(2) = dassert(ts.data, DATA, 1e-15);
%$ end
%$
%$ T = all(t);
%@eof:2
