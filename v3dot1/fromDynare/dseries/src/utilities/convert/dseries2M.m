function ts = dseries2M(ds, method) % --*-- Unitary tests --*--

% INPUTS
% - ds       [dseries]    daily frequency object with n elements.
% - method   [char]       1×m array, method used for the time aggregation, possible values are:
%                            - 'arithmetic-average' (for rates),
%                            - 'geometric-average' (for factors),
%                            - 'sum' (for flow variables), and
%                            - 'end-of-period' (for stock variables).
%
% OUTPUTS
% - ts       [dseries]    monthly frequency object with m<n elements.

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

if ds.freq<12
    error('Cannot convert to higher frequency.')
end

if ds.freq==12
    ts = ds;
    return
end

dm = dates2M(ds.dates);
dM = unique(dm); % dM.ndat will be the maximum number of periods in ts

tdata = NaN(dM.ndat, ds.vobs);

switch method
  case 'arithmetic-average'
    for i=1:dM.ndat
        idm = find(dm==dM(i));
        tdata(i,:) = mean(ds.data(idm,:));
        if ~isalldays(dM(i), idm)
            warning('Not all days are available in month %s.', date2string(dM(i)))
        end
    end
  case 'geometric-average'
    for i=1:dM.ndat
        idm = find(dm==dM(i));
        tdata(i,:) = prod(ds.data(idm,:), 1).^(1/length(idm));
        if ~isalldays(dM(i), idm)
            warning('Not all days are available in month %s.', date2string(dM(i)))
        end
    end
  case 'sum'
    for i=1:dM.ndat
        idm = find(dm==dM(i));
        tdata(i,:) = sum(ds.data(idm,:), 1);
        if ~isalldays(dM(i), idm)
            warning('Not all days are available in month %s.', date2string(dM(i)))
        end
    end
  case 'end-of-period'
    for i=1:dM.ndat
        idm = find(dm==dM(i));
        lastday = datevec(ds.dates.time(idm(end)));
        tdata(i,:) = ds.data(idm(end),:);
        if lastday(3)<expectedlastday(dM(i))
            warning('The last available day is not the last day of %s.', date2string(dM(i)))
        end
    end
  otherwise
    error('Unknow method.')
end

ts = dseries(tdata, dM, ds.name, ds.tex);

return

%@test:1
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2M(ts, 'arithmetic-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==12;
    t(3) = ds.nobs==12;
end

T = all(t);
%@eof:1

%@test:2
try
    ts = dseries(1.02-rand(366, 1)*0.05, '2020-01-01');
    ds = dseries2M(ts, 'geometric-average');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==12;
    t(3) = ds.nobs==12;
end

T = all(t);
%@eof:2

%@test:3
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2M(ts, 'sum');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==12;
    t(3) = ds.nobs==12;
end

T = all(t);
%@eof:3

%@test:4
try
    ts = dseries(randn(366, 1), '2020-01-01');
    ds = dseries2M(ts, 'end-of-period');
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = ds.freq==12;
    t(3) = ds.nobs==12;
end

T = all(t);
%@eof:4
