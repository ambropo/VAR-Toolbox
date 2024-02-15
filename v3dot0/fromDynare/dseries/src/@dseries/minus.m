function q = minus(o, p) % --*-- Unitary tests --*--

% Overloads the minus operator for dseries objects.
%
% INPUTS
% - o [dseries]
% - p [dseries]
%
% OUTPUTS
% - q [dseries]
%
% EXAMPLE
% Define a dseries object:
%
% >> a = dseries(transpose(1:5));
%
% Then we have
%
%  >> a-a
%
%  ans is a dseries object:
%
%     | minus(Variable_1;Variable_1)
%  1Y | 0
%  2Y | 0
%  3Y | 0
%  4Y | 0
%  5Y | 0

% Copyright (C) 2012-2017 Dynare Team
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

if isnumeric(o) && (isscalar(o) ||  isvector(o))
    if ~isdseries(p)
        error('dseries:WrongInputArguments', 'Second input argument must be a dseries object!')
    end
    q = copy(p);
    q.data = bsxfun(@minus, o, p.data);
    if isscalar(o)
        for i=1:vobs(q)
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('minus(%s, %s)', matrix2string(o), p.name{i})};
            else
                q.ops(i) = {sprintf('minus(%s, %s)', matrix2string(o), p.ops{i})};
            end
        end
        return
    end
    if isvector(o)
        for i=1:vobs(q)
            if isrow(o)
                oo = o(i);
            else
                oo = o;
            end
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('minus(%s, %s)', matrix2string(oo), p.name{i})};
            else
                q.ops(i) = {sprintf('minus(%s, %s)', matrix2string(oo), p.ops{i})};
            end
        end
        return
    end
end

if isnumeric(p) && (isscalar(p) || isvector(p))
    if ~isdseries(o)
        error('dseries::minus: First input argument must be a dseries object!')
    end
    q = copy(o);
    q.data = bsxfun(@minus, o.data, p);
    if isscalar(p)
        for i=1:vobs(q)
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('minus(%s, %s)', o.name{i}, matrix2string(p))};
            else
                q.ops(i) = {sprintf('minus(%s, %s)', o.ops{i}, matrix2string(p))};
            end
        end
        return
    end
    if isvector(p)
        for i=1:vobs(q)
            if isrow(p)
                pp = p(i);
            else
                pp = p;
            end
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('minus(%s, %s)', o.name{i}, matrix2string(pp))};
            else
                q.ops(i) = {sprintf('minus(%s, %s)', o.ops{i}, matrix2string(pp))};
            end
        end
        return
    end
end

if isdseries(o) && isempty(o)
    q = -copy(p);
    for i=1:vobs(q)
        q.ops(i) = {sprintf('minus(dseries(), %s)', q.ops{i}(8:end-1))};
    end
    return
end

if isdseries(p) && isempty(p)
    q = copy(o);
    return
end

if ~isequal(vobs(o), vobs(p)) && ~(isequal(vobs(o),1) || isequal(vobs(p),1))
    if isempty(inputname(1))
        error('dseries:WrongInputArguments', 'Cannot substract the two dseries objects (wrong number of variables)!')
    else
        error('dseries:WrongInputArguments', 'Cannot substract %s and %s (wrong number of variables)!', inputname(1), inputname(2))
    end
else
    if vobs(o)>vobs(p)
        ido = 1:vobs(o);
        idp = ones(1:vobs(o));
    elseif vobs(o)<vobs(p)
        ido = ones(1,vobs(p));
        idp = 1:vobs(p);
    else
        ido = 1:vobs(o);
        idp = ido;
    end
end

if ~isequal(frequency(o),frequency(p))
    if isempty(inputname(1))
        error('dseries:WrongInputArguments', 'Cannot substract the two dseries objects (frequencies are different)!')
    else
        error('dseries:WrongInputArguments', 'Cannot substract %s and %s (frequencies are different)!', inputname(1), inputname(2))
    end
end

if ~isequal(nobs(o), nobs(p)) || ~isequal(firstdate(o),firstdate(p))
    [o, p] = align(o, p);
end

q = dseries();

q.dates = o.dates;
q_vobs = max(vobs(o), vobs(p));
q.name = cell(q_vobs,1);
q.tex = cell(q_vobs,1);
q.ops = cell(q_vobs,1);
for i=1:q_vobs
    q.name(i) = {o.name{ido(i)}};
    q.tex(i) = {o.tex{ido(i)}};
    q.ops(i) = {sprintf('minus(%s, %s)', o.name{ido(i)}, p.name{idp(i)})};
end

q.data = bsxfun(@minus, o.data, p.data);

%@test:1
%$ % Define a datasets.
%$ A = rand(10,2); B = randn(10,1);
%$
%$ % Define names
%$ A_name = {'A1';'A2'}; B_name = {'B1'};
%$
%$ t = zeros(5,1);
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts3 = ts1-ts2;
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts3.vobs,2);
%$    t(3) = dassert(ts3.nobs,10);
%$    t(4) = dassert(ts3.data,[A(:,1)-B, A(:,2)-B],1e-15);
%$    t(5) = dassert(ts3.name,{'A1'; 'A2'});
%$    t(6) = dassert(ts1.data, A, 1e-15);
%$    t(7) = dassert(ts3.ops,{'minus(A1, B1)';'minus(A2, B1)'});
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a datasets.
%$ A = rand(10,2); B = randn(5,1);
%$
%$ % Define names
%$ A_name = {'A1';'A2'}; B_name = {'B1'};
%$
%$ t = zeros(5,1);
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts3 = ts1-ts2;
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts3.vobs,2);
%$    t(3) = dassert(ts3.nobs,10);
%$    t(4) = dassert(ts3.data,[A(1:5,1)-B(1:5), A(1:5,2)-B(1:5) ; NaN(5,2)],1e-15);
%$    t(5) = dassert(ts3.name,{'A1';'A2'});
%$    t(6) = dassert(ts3.ops,{'minus(A1, B1)';'minus(A2, B1)'});
%$ end
%$ T = all(t);
%@eof:2

%@test:3
%$ ts1 = dseries(ones(3,1));
%$ ts2 = ts1-1;
%$ ts3 = 2-ts1;
%$ t(1) = isequal(ts2.data, zeros(3,1));
%$ t(2) = isequal(ts3.data, ts1.data);
%$ T = all(t);
%@eof:3

%@test:4
%$ ts1 = dseries(ones(3,2));
%$ ts2 = ts1-1;
%$ ts3 = 2-ts1;
%$ t(1) = isequal(ts2.data, zeros(3,2));
%$ t(2) = isequal(ts3.data, ts1.data);
%$ T = all(t);
%@eof:4

%@test:5
%$ ts1 = dseries(ones(3,2));
%$ ts2 = ts1-ones(3,1);
%$ ts3 = 2*ones(3,1)-ts1;
%$ t(1) = isequal(ts2.data, zeros(3,2));
%$ t(2) = isequal(ts3.data, ts1.data);
%$ T = all(t);
%@eof:5

%@test:6
%$ ts1 = dseries(ones(3,2));
%$ ts2 = ts1-ones(1,2);
%$ ts3 = 2*ones(1,2)-ts1;
%$ t(1) = isequal(ts2.data, zeros(3,2));
%$ t(2) = isequal(ts3.data, ts1.data);
%$ T = all(t);
%@eof:6
