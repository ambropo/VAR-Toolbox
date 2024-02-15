function p = subsample(o, d1, d2)  % --*-- Unitary tests --*--

% function p = subsample(o, d1, d2)

% Returns the subsample of a series
%
% INPUTS
% - o  [dseries]
% - d1 [date]    beginning date of subsample
% - d2 [date]    last date of subsample
%
% OUTPUTS
% - o  [dseries]
%
% EXAMPLE
% Define a dseries object as follows:
%
% >> o = dseries(transpose(1:5))
%
% then o.subsample(dates('2y'), dates('4y')) returns
%
%    | Variable_1
% 2Y | 2
% 3Y | 3
% 4Y | 4

% Copyright (C) 2019 Dynare Team
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

if nargin < 1 || nargin > 3
    error('function takes 1 to 3 arguments')
end

if nargin == 1
    p = copy(o);
    return
end

if ~isa(d1, 'dates')
    if isstringdate(d1)
        d1 = dates(d1);
    else
        error('the arguments to subsample must be dates')
    end
end

if nargin == 2
    d2 = d1;
end

if nargin == 3
    if ~isa(d2, 'dates')
        if isstringdate(d2)
            d2 = dates(d2);
        else
            error('the arguments to subsample must be dates')
        end
    end
    if d2 < d1
        error('the second date must be greater than or equal to the first date')
    end
end

if d1 < min(o.dates)
    error(['the first argument must be greater than or equal to ' date2string(min(o.dates))])
end

if d2 > max(o.dates)
    error(['the second argument must be less than or equal to ' date2string(max(o.dates))])
end

idx = find(o.dates == d1):find(o.dates == d2);

p = dseries();
p.data  = o.data(idx, :);
p.name  = o.name;
p.tex   = o.tex;
p.dates = o.dates(idx);
p.ops   = o.ops;
p.tags  = o.tags;

end

%@test:1
%$ try
%$     data = transpose(0:50);
%$     ts = dseries(data,'1950Q1');
%$     d1 = dates('1951q3');
%$     ts1 = ts.subsample(d1);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = ts1 == dseries(6, '1951q3');
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     data = transpose(0:50);
%$     ts = dseries(data,'1950Q1');
%$     d1 = dates('1951q3');
%$     d2 = dates('1952q3');
%$     ts1 = ts.subsample(d1, d2);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = all(ts1 == dseries((6:10)', '1951q3'));
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ try
%$     data = transpose(0:50);
%$     ts = dseries(data,'1950Q1');
%$     d1 = '1951q3';
%$     ts1 = ts.subsample(d1);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = ts1 == dseries(6, '1951q3');
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$     data = transpose(0:50);
%$     ts = dseries(data,'1950Q1');
%$     d1 = '1951q3';
%$     d2 = '1952q3';
%$     ts1 = ts.subsample(d1, d2);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = all(ts1 == dseries((6:10)', '1951q3'));
%$ end
%$
%$ T = all(t);
%@eof:4
