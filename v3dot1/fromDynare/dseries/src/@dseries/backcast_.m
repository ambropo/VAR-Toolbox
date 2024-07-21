function o = backcast_(o, p, diff)  % --*-- Unitary tests --*--

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

if nargin<3
    % By default o is backcasted with growth rates of p.
    diff = false;
end

if ~isequal(vobs(o), vobs(p))
    error('dseries objects must have the same number of variables!')
end

if ~isequal(frequency(o), frequency(p))
    error('dseries objects must have common frequencies!')
end

if firstdate(o)>lastdate(p)
    error('The first period (%s) in the first dseries object cannot be posterior to the last period (%s) in the second object.\n ==> dseries objects have to overlap.', date2string(o.dates(1)), date2string(o.dates(end)))
end

if firstdate(o)<=firstdate(p)
    error('The first period (%s) in the second dseries object does not preceed the first period (%s) in the first object.\n ==> Cannot backcast first dseries object.', date2string(p.dates(1)), date2string(o.dates(1)))
end

idp = find(o.dates(1)==p.dates);

if diff
    FirstDifference = p.data(2:idp,:)-p.data(1:idp-1,:);
    CumulatedDifferences = rcumsum(FirstDifference);
    o.data = [bsxfun(@minus, o.data(1), CumulatedDifferences); o.data];
else
    GrowthFactor = p.data(2:idp,:)./p.data(1:idp-1,:);
    CumulatedGrowthFactors = rcumprod(GrowthFactor);
    o.data = [bsxfun(@rdivide, o.data(1), CumulatedGrowthFactors); o.data];
end

o.dates = firstdate(p):lastdate(o);

for i=1:o.vobs
    if isempty(o.ops{i})
        arg1 = o.name{i};
    else
        arg1 = o.ops{i};
    end
    if diff
        o.ops(i) = {sprintf('backcast(%s, %s.%s, diff)', arg1, inputname(2), p.name{i})};
    else
        o.ops(i) = {sprintf('backcast(%s, %s.%s)', arg1, inputname(2), p.name{i})};
    end
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
    ds.backcast_(ts);
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

%@test:2
  y = ones(10,1);
  for i=2:10
    y(i) = y(i-1) + 1;
  end

  ds = dseries(y(6:10), '1990Q1', 'toto');
  ts = dseries(y(1:6), '1988Q4', 'popeye');

  try
    ds.backcast_(ts, true);
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
%@eof:2