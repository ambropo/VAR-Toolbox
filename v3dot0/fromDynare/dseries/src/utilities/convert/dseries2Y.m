function ts = dseries2Y(ds, method)  % --*-- Unitary tests --*--

% INPUTS
% - ds       [dseries]    daily, monthly, quarterly, bi-annual or yearly frequency object with n elements.
% - method   [char]       1×m array, method used for the time aggregation, possible values are:
%                            - 'arithmetic-average' (for rates),
%                            - 'geometric-average' (for factors),
%                            - 'sum' (for flow variables), and
%                            - 'end-of-period' (for stock variables).
%
% OUTPUTS
% - ts       [dseries]    annual frequency object with m<n elements.

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

if ds.freq==1
    ts = ds;
    return
end

dy = dates2Y(ds.dates);
dY = unique(dy); % dY.ndat will be the maximum number of periods in ts

tdata = NaN(dY.ndat, ds.vobs);

switch method
  case 'arithmetic-average'
    for i=1:dY.ndat
        idy = find(dy==dY(i));
        tdata(i,:) = mean(ds.data(idy,:));
        if ds.dates.freq==365 && ~isalldays(dY(i), idy)
            warning('Not all days are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idy), 12)
            warning('Not all months are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==4 && ~isequal(length(idy), 4)
            warning('Not all quarters are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==2 && ~isequal(length(idy), 2)
            warning('Not all semesters are available in %s.', date2string(dY(i)))
        end
    end
  case 'geometric-average'
    for i=1:dY.ndat
        idy = find(dy==dY(i));
        tdata(i,:) = prod(ds.data(idy,:), 1).^(1/length(idy));
        if ds.dates.freq==365 && ~isalldays(dY(i), idy)
            warning('Not all days are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idy), 12)
            warning('Not all months are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==4 && ~isequal(length(idy), 4)
            warning('Not all quarters are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==2 && ~isequal(length(idy), 2)
            warning('Not all semesters are available in %s.', date2string(dY(i)))
        end
    end
  case 'sum'
    for i=1:dY.ndat
        idy = find(dy==dY(i));
        tdata(i,:) = sum(ds.data(idy,:), 1);
        if ds.dates.freq==365 && ~isalldays(dY(i), idy)
            warning('Not all days are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==12 && ~isequal(length(idy), 12)
            warning('Not all months are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==4 && ~isequal(length(idy), 4)
            warning('Not all quarters are available in %s.', date2string(dY(i)))
        end
        if ds.dates.freq==2 && ~isequal(length(idy), 2)
            warning('Not all semesters are available in %s.', date2string(dY(i)))
        end
    end
  case 'end-of-period'
    for i=1:dY.ndat
        idy = find(dy==dY(i));
        tdata(i,:) = ds.data(idy(end),:);
        if ds.dates.freq==365
            lastday = datevec(ds.dates.time(idy(end)));
            if lastday(3)<expectedlastday(dY(i))
                warning('The last available day is not the last day of %s.', date2string(dY(i)))
            end
        end
        if ds.dates.freq==12
            lastmonth = subperiod(ds.dates(idy(end)));
            if lastmonth<12
                warning('The last available month is not the last month of %s.', date2string(dY(i)))
            end
        end
        if ds.dates.freq==4
            lastquarter = subperiod(ds.dates(idy(end)));
            if lastquarter<4
                warning('The last available quarter is not the last quarter of %s.', date2string(dY(i)))
            end
        end
        if ds.dates.freq==2
            lastsemester = subperiod(ds.dates(idy(end)));
            if lastsemester<2
                warning('The last available semester is not the last semester of %s.', date2string(dY(i)))
            end
        end
    end
  otherwise
    error('Unknow method.')
end

ts = dseries(tdata, dY, ds.name, ds.tex);

return

%@test:1
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2Y(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:1

%@test:2
try
    ts = dseries(1.02-rand(366, 1)*0.05, '2020-01-01');
    ds = dseries2Y(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:2

%@test:3
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2Y(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:3

%@test:4
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2Y(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:4

%@test:5
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2Y(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:5

%@test:6
try
    ts = dseries(1.02-rand(12, 1)*0.5, '2020M1');
    ds = dseries2Y(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:6

%@test:7
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2Y(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:7

%@test:8
try
    ts = dseries(randn(12, 1), '2020M1');
    ds = dseries2Y(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:8

%@test:9
try
    ts = dseries(randn(4, 1), '2020Q1');
    ds = dseries2Y(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:9

%@test:10
try
    ts = dseries(1.02-rand(4, 1)*0.5, '2020Q1');
    ds = dseries2Y(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:10

%@test:11
try
    ts = dseries(randn(4, 1), '2020Q1');
    ds = dseries2Y(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:11

%@test:12
try
    ts = dseries(randn(4, 1), '2020Q1');
    ds = dseries2Y(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==1;
    t(3) = ds.nobs==1;
end

T = all(t);
%@eof:12