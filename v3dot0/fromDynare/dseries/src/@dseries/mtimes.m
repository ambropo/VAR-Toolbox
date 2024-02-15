function q = mtimes(o, p) % --*-- Unitary tests --*--

% Overloads the mtimes (*) operator for dseries objects.
%
% INPUTS
% - o [dseries]           T observations and N variables.
% - p [dseries,double]    scalar, vector or dseries object.
%
% OUTPUTS
% - q [dseries]           T observations and N variables.

% Copyright (C) 2013-2017 Dynare Team
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
        error('dseries::mtimes: Second input argument must be a dseries object!')
    end
    q = copy(p);
    q.data = bsxfun(@times, o, p.data);
    for i=1:vobs(q)
        if isscalar(o)
            if isempty(p.ops{i})
                q.ops(i) = {sprintf('mtimes(%s, %s)', num2str(o), p.name{i})};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', num2str(o), p.ops{i})};
            end
        elseif isrow(o)
            if isempty(p.ops{i})
                q.ops(i) = {sprintf('mtimes(%s, %s)', num2str(o(i)), p.name{i})};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', num2str(o(i)), p.ops{i})};
            end
        else
            if isempty(p.ops{i})
                q.ops(i) = {sprintf('mtimes(%s, %s)', matrix2string(o), p.name{i})};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', matrix2string(o), p.ops{i})};
            end
        end
    end
    return
end

if isnumeric(p) && (isscalar(p) || isvector(p))
    if ~isdseries(o)
        error('dseries::mtimes: First input argument must be a dseries object!')
    end
    q = copy(o);
    q.data = bsxfun(@times, o.data, p);
    for i=1:vobs(q)
        if isscalar(p)
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('mtimes(%s, %s)', q.name{i}, num2str(p))};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', q.ops{i}, num2str(p))};
            end
        elseif isrow(p)
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('mtimes(%s, %s)', q.name{i}, num2str(p(i)))};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', q.ops{i}, num2str(p(i)))};
            end
        else
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('mtimes(%s, %s)', q.name{i}, matrix2string(p))};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', q.ops{i}, matrix2string(p))};
            end
        end
    end
    return
end

if isdseries(o) && isdseries(p)
    % Element by element multiplication of two dseries object
    if ~isequal(vobs(o), vobs(p)) && ~(isequal(vobs(o),1) || isequal(vobs(p),1))
        error(['dseries::times: Cannot multiply ' inputname(1) ' and ' inputname(2) ' (wrong number of variables)!'])
    else
        if vobs(o)>vobs(p)
            idB = 1:vobs(o);
            idC = ones(1:vobs(o));
        elseif vobs(o)<vobs(p)
            idB = ones(1,vobs(p));
            idC = 1:vobs(p);
        else
            idB = 1:vobs(o);
            idC = 1:vobs(p);
        end
    end
    if ~isequal(frequency(o),frequency(p))
        error(['dseries::times: Cannot multiply ' inputname(1) ' and ' inputname(2) ' (frequencies are different)!'])
    end
    if ~isequal(nobs(o), nobs(p)) || ~isequal(firstdate(o),firstdate(p))
        [o, p] = align(o, p);
    end
    if vobs(o)>=vobs(p)
        q = copy(o);
    else
        q = dseries(zeros(size(p.data)), p.firstdate);
    end
    for i=1:vobs(q)
        if isempty(o.ops{idB(i)})
            if isempty(p.ops{idC(i)})
                q.ops(i) = {sprintf('mtimes(%s, %s)', o.name{idB(i)}, p.name{idC(i)})};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', o.name{idB(i)}, p.ops{idC(i)})};
            end
        else
            if isempty(p.ops{idC(i)})
                q.ops(i) = {sprintf('mtimes(%s, %s)', o.ops{idB(i)}, p.name{idC(i)})};
            else
                q.ops(i) = {sprintf('mtimes(%s, %s)', o.ops{idB(i)}, p.ops{idC(i)})};
            end
        end
    end
    q.data = bsxfun(@times, o.data, p.data);
else
    error()
end

%@test:1
%$ % Define a datasets.
%$ A = rand(10,2); B = randn(10,1);
%$
%$ % Define names
%$ A_name = {'A1';'A2'}; B_name = {'B1'};
%$
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts3 = ts1*ts2;
%$    t = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts3.vobs,2);
%$    t(3) = dassert(ts3.nobs,10);
%$    t(4) = dassert(ts3.data,[A(:,1).*B, A(:,2).*B],1e-15);
%$    t(5) = dassert(ts3.name,{'A1';'A2'});
%$    t(6) = dassert(ts3.ops,{'mtimes(A1, B1)';'mtimes(A2, B1)'});
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a datasets.
%$ A = rand(10,2); B = pi;
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = ts1*B;
%$    t = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts2.vobs,2);
%$    t(3) = dassert(ts2.nobs,10);
%$    t(4) = dassert(ts2.data,A*B,1e-15);
%$ end
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define a datasets.
%$ A = rand(10,2); B = pi;
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = B*ts1;
%$    t = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts2.vobs,2);
%$    t(3) = dassert(ts2.nobs,10);
%$    t(4) = dassert(ts2.data,A*B,1e-15);
%$ end
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define a datasets.
%$ A = rand(10,2); B = A(1,:);
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = B*ts1;
%$    t = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts2.vobs,2);
%$    t(3) = dassert(ts2.nobs,10);
%$    t(4) = dassert(ts2.data,bsxfun(@times,A,B),1e-15);
%$ end
%$ T = all(t);
%@eof:4
