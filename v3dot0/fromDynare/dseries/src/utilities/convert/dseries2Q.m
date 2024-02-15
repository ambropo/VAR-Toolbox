function ts = dseries2Q(ds, method)  % --*-- Unitary tests --*--

% INPUTS
% - ds       [dseries]    daily or monthly frequency object with n elements.
% - method   [char]       1×m array, method used for the time aggregation, possible values are:
%                            - 'arithmetic-average' (for rates),
%                            - 'geometric-average' (for factors),
%                            - 'sum' (for flow variables), and
%                            - 'end-of-period' (for stock variables).
%
% OUTPUTS
% - ts       [dseries]    quaterly frequency object with m<n elements.

% Copyright © 2020-2021 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if ds.freq<4
    error('Cannot convert to higher frequency.')
end

if ds.freq==4
    ts = ds;
    return
end

dq = dates2Q(ds.dates);
dQ = unique(dq); % dQ.ndat will be the maximum number of periods in ts

tdata = NaN(dQ.ndat, ds.vobs);

switch method
  case 'arithmetic-average'
    for i=1:dQ.ndat
        idq = find(dq==dQ(i));
        tdata(i,:) = mean(ds.data(idq,:));
        if ds.dates.freq==365 && ~isalldays(dQ(i), idq)
            warning('Not all days are available in %s.', date2string(dQ(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idq), 3)
            warning('Not all months are available in %s.', date2string(dQ(i)))
        end
    end
  case 'geometric-average'
    for i=1:dQ.ndat
        idq = find(dq==dQ(i));
        tdata(i,:) = prod(ds.data(idq,:), 1).^(1/length(idq));
        if ds.dates.freq==365 && ~isalldays(dQ(i), idq)
            warning('Not all days are available in %s.', date2string(dQ(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idq), 3)
            warning('Not all months are available in %s.', date2string(dQ(i)))
        end
    end
  case 'sum'
    for i=1:dQ.ndat
        idq = find(dq==dQ(i));
        tdata(i,:) = sum(ds.data(idq,:), 1);
        if ds.dates.freq==365 && ~isalldays(dQ(i), idq)
            warning('Not all days are available in %s.', date2string(dQ(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idq), 3)
            warning('Not all months are available in %s.', date2string(dQ(i)))
        end
    end
  case 'end-of-period'
    for i=1:dQ.ndat
        idq = find(dq==dQ(i));
        tdata(i,:) = ds.data(idq(end),:);
        if ds.dates.freq==365
            lastday = datevec(ds.dates.time(idq(end)));
            if lastday(3)<expectedlastday(dQ(i))
                warning('The last available day is not the last day of %s.', date2string(dQ(i)))
            end
        end
        if ds.dates.freq==12
            lastmonth = subperiod(ds.dates(idq(end)));
            if lastmonth<expectedlastmonth(dQ(i))
                warning('The last available month is not the last month of %s.', date2string(dQ(i)))
            end
        end
    end
  otherwise
    error('Unknow method.')
end

ts = dseries(tdata, dQ, ds.name, ds.tex);

return

%@test:1
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2Q(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:1

%@test:2
try
    ts = dseries(1.02-rand(366, 1)*0.05, '2020-01-01');
    ds = dseries2Q(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:2

%@test:3
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2Q(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:3

%@test:4
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2Q(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:4

%@test:5
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2Q(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:5

%@test:6
try
    ts = dseries(1.02-rand(12, 1)*0.5, '2020M1');
    ds = dseries2Q(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:6

%@test:7
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2Q(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:7

%@test:8
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2Q(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==4;
    t(3) = ds.nobs==4;
end

T = all(t);
%@eof:8