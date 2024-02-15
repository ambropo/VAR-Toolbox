function o = ydiff_(o) % --*-- Unitary tests --*--

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

switch frequency(o)
  case 1
    o.data(2:end,:) = o.data(2:end,:)-o.data(1:end-1,:);
    o.data(1,:) = NaN;
  case 2
    o.data(3:end,:) = o.data(3:end,:)-o.data(1:end-2,:);
    o.data(1:2,:) = NaN;
  case 4
    o.data(5:end,:) = o.data(5:end,:)-o.data(1:end-4,:);
    o.data(1:4,:) = NaN;
  case 12
    o.data(13:end,:) = o.data(13:end,:)-o.data(1:end-12,:);
    o.data(1:12,:) = NaN;
  case 52
    o.data(53:end,:) = o.data(53:end,:)-o.data(1:end-52,:);
    o.data(1:52,:) = NaN;
  case 365
    o.data(366:end,:) = o.data(366:end,:)-o.data(1:end-365,:);
    o.data(1:365,:) = NaN;
  otherwise
    error(['dseries::ydiff: object ' inputname(1) ' has unknown frequency']);
end

for i = 1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {['ydiff(' o.name{i} ')']};
    else
        o.ops(i) = {['ydiff(' o.ops{i} ')']};
    end
end

return

%@test:1
try
    data = transpose(1:100);
    ts = dseries(data,'1950Q1',{'A1'},{'A_1'});
    ts.ydiff_;
    t(1) = true;
catch
    t(1) = false;
end


if t(1)
    DATA = NaN(4,ts.vobs);
    DATA = [DATA; 4*ones(ts.nobs-4,ts.vobs)];
    t(2) = dassert(ts.data,DATA);
    t(3) = dassert(ts.ops{1},['ydiff(A1)']);
end

T = all(t);
%@eof:1

%@test:2
try
    data = transpose(1:100);
    ts = dseries(data,'1950M1',{'A1'},{'A_1'});
    ts.ydiff_;
    t(1) = true;
catch
    t(1) = false;
end


if t(1)
    DATA = NaN(12,ts.vobs);
    DATA = [DATA; 12*ones(ts.nobs-12,ts.vobs)];
    t(2) = dassert(ts.data,DATA);
    t(3) = dassert(ts.ops{1},['ydiff(A1)']);
end

T = all(t);
%@eof:2

%@test:3
try
    data = transpose(1:100);
    ts = dseries(data,'1950Y',{'A1'},{'A_1'});
    ts.ydiff_;
    t(1) = true;
catch
    t(1) = false;
end


if t(1)
    DATA = NaN(1,ts.vobs);
    DATA = [DATA; ones(ts.nobs-1,ts.vobs)];
    t(2) = dassert(ts.data,DATA);
    t(3) = dassert(ts.ops{1},['ydiff(A1)']);
end

T = all(t);
%@eof:3

%@test:4
try
    data = transpose(1:100);
    ts = dseries(data,'1950H1',{'A1'},{'A_1'});
    ts.ydiff_;
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    DATA = NaN(2,ts.vobs);
    DATA = [DATA; 2*ones(ts.nobs-2,ts.vobs)];
    t(2) = dassert(ts.data,DATA);
    t(3) = dassert(ts.ops{1},['ydiff(A1)']);
end

T = all(t);
%@eof:5

%@test:6
try
    data = transpose(1:1095);
    ts = dseries(data,'1950-01-01',{'A1'},{'A_1'});
    ts.ydiff_;
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    DATA = NaN(365,ts.vobs);
    DATA = [DATA; 365*ones(ts.nobs-365,ts.vobs)];
    t(2) = dassert(ts.data,DATA);
    t(3) = dassert(ts.ops{1},['ydiff(A1)']);
end

T = all(t);
%@eof:6