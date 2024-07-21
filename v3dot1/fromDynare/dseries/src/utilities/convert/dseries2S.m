function ts = dseries2S(ds, method)  % --*-- Unitary tests --*--

% INPUTS
% - ds       [dseries]    daily, monthly or quarterly frequency object with n elements.
% - method   [char]       1×m array, method used for the time aggregation, possible values are:
%                            - 'arithmetic-average' (for rates),
%                            - 'geometric-average' (for factors),
%                            - 'sum' (for flow variables), and
%                            - 'end-of-period' (for stock variables).
%
% OUTPUTS
% - ts       [dseries]    bi-annual frequency object with m<n elements.

% Copyright © 2021 Dynare Team
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

if ds.freq<2
    error('Cannot convert to higher frequency.')
end

if ds.freq==2
    ts = ds;
    return
end

dh = dates2S(ds.dates);
dH = unique(dh); % dH.ndat will be the maximum number of periods in ts

tdata = NaN(dH.ndat, ds.vobs);

switch method
  case 'arithmetic-average'
    for i=1:dH.ndat
        idh = find(dh==dH(i));
        tdata(i,:) = mean(ds.data(idh,:));
        if ds.dates.freq==365 && ~isalldays(dH(i), idh)
            warning('Not all days are available in %s.', date2string(dH(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idh), 6)
            warning('Not all months are available in %s.', date2string(dH(i)))
        end
        if ds.dates.freq==4 && ~isequal(length(idh), 2)
            warning('Not all quarters are available in %s.', date2string(dH(i)))
        end
    end
  case 'geometric-average'
    for i=1:dH.ndat
        idh = find(dh==dH(i));
        tdata(i,:) = prod(ds.data(idh,:), 1).^(1/length(idh));
        if ds.dates.freq==365 && ~isalldays(dH(i), idh)
            warning('Not all days are available in %s.', date2string(dH(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idh), 6)
            warning('Not all months are available in %s.', date2string(dH(i)))
        end
        if ds.dates.freq==4 && ~isequal(length(idh), 2)
            warning('Not all quarters are available in %s.', date2string(dH(i)))
        end
    end
  case 'sum'
    for i=1:dH.ndat
        idh = find(dh==dH(i));
        tdata(i,:) = sum(ds.data(idh,:), 1);
        if ds.dates.freq==365 && ~isalldays(dH(i), idh)
            warning('Not all days are available in %s.', date2string(dH(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idh), 6)
            warning('Not all months are available in %s.', date2string(dH(i)))
        end
        if ds.dates.freq==4 && ~isequal(length(idh), 2)
            warning('Not all quarters are available in %s.', date2string(dH(i)))
        end
    end
  case 'end-of-period'
    for i=1:dH.ndat
        idh = find(dh==dH(i));
        tdata(i,:) = ds.data(idh(end),:);
        if ds.dates.freq==365
            lastday = datevec(ds.dates.time(idh(end)));
            if lastday(3)<expectedlastday(dH(i))
                warning('The last available day is not the last day of %s.', date2string(dH(i)))
            end
        end
        if ds.dates.freq==12
            lastmonth = subperiod(ds.dates(idh(end)));
            if lastmonth<expectedlastmonth(dH(i))
                warning('The last available month is not the last month of %s.', date2string(dH(i)))
            end
        end
        if ds.dates.freq==4
            lastquarter = subperiod(ds.dates(idh(end)));
            if lastquarter<expectedlastquarter(dH(i))
                warning('The last available quarter is not the last quarter of %s.', date2string(dH(i)))
            end
        end
    end
  otherwise
    error('Unknow method.')
end

ts = dseries(tdata, dH, ds.name, ds.tex);

return

%@test:1
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2S(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:1

%@test:2
try
    ts = dseries(1.02-rand(366, 1)*0.05, '2020-01-01');
    ds = dseries2S(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:2

%@test:3
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2S(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:3

%@test:4
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2S(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:4

%@test:5
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2S(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:5

%@test:6
try
    ts = dseries(1.02-rand(12, 1)*0.5, '2020M1');
    ds = dseries2S(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:6

%@test:7
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2S(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:7

%@test:8
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2S(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:8

%@test:9
try
    ts = dseries(randn(4, 1), '2020Q1');
    ds = dseries2S(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:9

%@test:10
try
    ts = dseries(1.02-rand(4, 1)*0.5, '2020Q1');
    ds = dseries2S(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:10

%@test:11
try
    ts = dseries(randn(4, 1), '2020Q1');
    ds = dseries2S(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:11

%@test:12
try
    ts = dseries(randn(4, 1), '2020Q1');
    ds = dseries2S(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==2;
    t(3) = ds.nobs==2;
end

T = all(t);
%@eof:12