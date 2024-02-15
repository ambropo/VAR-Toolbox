function o = chain_(o, p)  % --*-- Unitary tests --*--

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

noinputname = false;

if isempty(inputname(1))
    % If method is called with dot notation (eg o.chain_(p) insteady of chain(o, p)), input names
    % are not defined.
    noinputname = true;
end

if vobs(o)-vobs(p)
    if noinputname
        error(['dseries::chain: dseries objects must have the same number of variables!'])
    else
        error(['dseries::chain: dseries objects ' inputname(1) ' and ' inputname(2) ' must have the same number of variables!'])
    end
end

if frequency(o)-frequency(p)
    if noinputname
        error(['dseries::chain: dseries objects must have common frequencies!'])
    else
        error(['dseries::chain: dseries objects ' inputname(1) ' and ' inputname(2) ' must have common frequencies!'])
    end
end

if lastdate(o)<firstdate(p)
    if noinputname
        error(['dseries::chain: The last date in first dseries object (' date2string(o.dates(end)) ') must not preceed the first date in the second dseries object (' date2string(p.dates(1)) ')!'])
    else
        error(['dseries::chain: The last date in ' inputname(1) ' (' date2string(o.dates(end)) ') must not preceed the first date in ' inputname(2) ' (' date2string(p.dates(1)) ')!'])
    end
end

tdx = find(sum(bsxfun(@eq, p.dates.time, o.dates.time(end)),2)==1);
GrowthFactor = p.data(tdx+1:end,:)./p.data(tdx:end-1,:);
CumulatedGrowthFactors = cumprod(GrowthFactor);

isallzeros = all(~p.data) & all(~o.data);

o.data = [o.data; bsxfun(@times,CumulatedGrowthFactors, o.data(end,:))];

o.dates = firstdate(o):firstdate(o)+nobs(o)-1;

o.data(:,isallzeros) = 0;

for i=1:o.vobs
    if isempty(o.ops{i})
        if noinputname
            o.ops(i) = {sprintf('chain(%s, %s)', o.name{i}, p.name{i})};
        else
            o.ops(i) = {sprintf('chain(%s, %s.%s)', o.name{i}, inputname(2), p.name{i})};
        end
    else
        if noinputname
            o.ops(i) = {sprintf('chain(%s, %s)', o.ops{i}, p.name{i})};
        else
            o.ops(i) = {sprintf('chain(%s, %s.%s)', o.ops{i}, inputname(2), p.name{i})};
        end
    end
end

%@test:1
%$ try
%$     ts = dseries([1; 2; 3; 4],dates('1950Q1')) ;
%$     us = dseries([3; 4; 5; 6],dates('1950Q3')) ;
%$     ts.chain_(us);
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(ts.init.freq,4);
%$     t(4) = dassert(ts.init.time, 1950*4+1);
%$     t(5) = dassert(ts.vobs,1);
%$     t(6) = dassert(ts.nobs,6);
%$     t(7) = isequal(ts.data,transpose(1:6));
%$     t(8) = isequal(ts.dates(end), dates('1951Q2'));
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     ts = dseries([0 1; 0 2; 0 3; 0 4],dates('1950Q1')) ;
%$     us = dseries([0 3; 0 4; 0 5; 0 6],dates('1950Q3')) ;
%$     ts.chain_(us);
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(ts.init.freq,4);
%$     t(4) = dassert(ts.init.time,1950*4+1);
%$     t(5) = dassert(ts.vobs,2);
%$     t(6) = dassert(ts.nobs,6);
%$     t(7) = isequal(ts.data(:,2), transpose(1:6));
%$     t(8) = isequal(ts.data(:,1), zeros(6, 1));
%$     t(9) = isequal(ts.dates(end), dates('1951Q2'));
%$ end
%$
%$ T = all(t);
%@eof:2