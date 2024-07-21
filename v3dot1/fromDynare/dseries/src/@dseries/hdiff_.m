function o = hdiff_(o) % --*-- Unitary tests --*--

% Computes bi-annual differences.
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

switch frequency(o)
  case 1
    error('dseries::hdiff: I cannot compute bi-annual differences from yearly data!')
  case 2
    o.data(2:end,:) = o.data(2:end,:)-o.data(1:end-1,:);
    o.data(1,:) = NaN;
  case 4
    o.data(3:end,:) = o.data(3:end,:)-o.data(1:end-2,:);
    o.data(1:2,:) = NaN;  
  case 12
    o.data(7:end,:) = o.data(7:end,:)-o.data(1:end-6,:);
    o.data(1:6,:) = NaN;
  case 52
    error('dseries::hdiff: I do not know yet how to compute bi-annual differences from weekly data!')
  case 365
    error('dseries::hdiff: I do not know yet how to compute bi-annual differences from daily data!')
  otherwise
    error(['dseries::hdiff: object ' inputname(1) ' has unknown frequency']);
end

for i = 1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {['hdiff(' o.name{i} ')']};
    else
        o.ops(i) = {['hdiff(' o.ops{i} ')']};
    end
end

%@test:1
%$ try
%$     data = transpose(1:100);
%$     ts = dseries(data,'1950Q1',{'H1'},{'H_1'});
%$     ts.hdiff_;
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$
%$ if t(1)
%$     DATA = NaN(2,ts.vobs);
%$     DATA = [DATA; 2*ones(ts.nobs-2,ts.vobs)];
%$     t(2) = dassert(ts.data,DATA);
%$     t(3) = dassert(ts.ops{1},['hdiff(H1)']);
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     data = transpose(1:100);
%$     ts = dseries(data,'1950M1',{'H1'},{'H_1'});
%$     ts.hdiff_;
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$
%$ if t(1)
%$     DATA = NaN(6,ts.vobs);
%$     DATA = [DATA; 6*ones(ts.nobs-6,ts.vobs)];
%$     t(2) = dassert(ts.data,DATA);
%$     t(3) = dassert(ts.ops{1},['hdiff(H1)']);
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ try
%$     data = transpose(1:100);
%$     ts = dseries(data,'1950W1',{'H1'},{'H_1'});
%$     ts.hdiff_;
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$     data = transpose(1:100);
%$     ts = dseries(data,'1950Y',{'H1'},{'H_1'});
%$     ts.hdiff_;
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:4

%@test:5
%$ try
%$     data = transpose(1:100);
%$     ts = dseries(data,'1950H1',{'H1'},{'H_1'});
%$     ts.hdiff_;
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     DATA = NaN(1,ts.vobs);
%$     DATA = [DATA; ones(ts.nobs-1,ts.vobs)];
%$     t(2) = dassert(ts.data,DATA);
%$     t(3) = dassert(ts.ops{1},['hdiff(H1)']);
%$ end
%$
%$ T = all(t);
%@eof:5

