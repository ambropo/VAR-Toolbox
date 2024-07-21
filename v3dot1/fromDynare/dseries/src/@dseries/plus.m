function q = plus(o, p) % --*-- Unitary tests --*--

% Overloads the plus (+) operator for dseries objects.
%
% INPUTS
% - o [dseries, real]
% - p [dseries, real]
%
% OUTPUTS
% - q [dseries]

% Copyright (C) 2011-2017 Dynare Team
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
        error('dseries::plus: Second input argument must be a dseries object!')
    end
    q = copy(p);
    q.data = bsxfun(@plus, o, p.data);
    for i=1:vobs(q)
        if isscalar(o)
            if isempty(p.ops{i})
                q.ops(i) = {sprintf('plus(%s, %s)', num2str(o), p.name{i})};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', num2str(o), p.ops{i})};
            end
        elseif isrow(o)
            if isempty(p.ops{i})
                q.ops(i) = {sprintf('plus(%s, %s)', num2str(o(i)), p.name{i})};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', num2str(o(i)), p.ops{i})};
            end
        else
            if isempty(p.ops{i})
                q.ops(i) = {sprintf('plus(%s, %s)', matrix2string(o), p.name{i})};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', matrix2string(o), p.ops{i})};
            end
        end
    end
    return
end

if isnumeric(p) && (isscalar(p) || isvector(p))
    if ~isdseries(o)
        error('dseries::plus: First input argument must be a dseries object!')
    end
    q = copy(o);
    q.data = bsxfun(@plus,o.data,p);
    for i=1:vobs(q)
        if isscalar(p)
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('plus(%s, %s)', q.name{i}, num2str(p))};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', q.ops{i}, num2str(p))};
            end
        elseif isrow(p)
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('plus(%s, %s)', q.name{i}, num2str(p(i)))};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', q.ops{i}, num2str(p(i)))};
            end
        else
            if isempty(q.ops{i})
                q.ops(i) = {sprintf('plus(%s, %s)', q.name{i}, matrix2string(p))};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', q.ops{i}, matrix2string(p))};
            end
        end
    end
    return
end

if isdseries(o) && isdseries(p)
    if isempty(o)
        q = copy(p);
        return
    end
    if isempty(p)
        q = copy(o);
        return
    end
    if ~isequal(vobs(o), vobs(p)) && ~(isequal(vobs(o), 1) || isequal(vobs(p), 1))
        error(['dseries::plus: Cannot add ' inputname(1) ' and ' inputname(2) ' (wrong number of variables)!'])
    else
        if vobs(o)>vobs(p)
            ido = 1:vobs(o);
            idp = ones(1,vobs(o));
        elseif vobs(o)<vobs(p)
            ido = ones(1,vobs(p));
            idp = 1:vobs(p);
        else
            ido = 1:vobs(o);
            idp = ido;
        end
    end
    
    if ~isequal(frequency(o),frequency(p))
        error(['dseries::plus: Cannot add ' inputname(1) ' and ' inputname(2) ' (frequencies are different)!'])
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
        if isempty(o.ops{ido(i)})
            if isempty(p.ops{idp(i)})
                q.ops(i) = {sprintf('plus(%s, %s)', o.name{ido(i)}, p.name{idp(i)})};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', o.name{ido(i)}, p.ops{idp(i)})};
            end
        else
            if isempty(p.ops{idp(i)})
                q.ops(i) = {sprintf('plus(%s, %s)', o.ops{ido(i)}, p.name{idp(i)})};
            else
                q.ops(i) = {sprintf('plus(%s, %s)', o.ops{ido(i)}, p.ops{idp(i)})};
            end
        end
    end
    q.data = bsxfun(@plus,o.data,p.data);
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
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts3 = ts1+ts2;
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts3.vobs,2);
%$    t(3) = dassert(ts3.nobs,10);
%$    t(4) = dassert(ts3.data,[A(:,1)+B, A(:,2)+B],1e-15);
%$    t(5) = dassert(ts3.name,{'A1';'A2'});
%$    t(6) = dassert(ts3.name,{'plus(A1, B1)';'plus(A2, B1)'});
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a datasets.
%$ A = rand(10,2); B = randn(10,1);
%$
%$ % Define names
%$ A_name = {'A1';'A2'}; B_name = {'B1'};
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts3 = ts1+ts2;
%$    ts4 = ts3+ts1;
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts4.vobs,2);
%$    t(3) = dassert(ts4.nobs,10);
%$    t(4) = dassert(ts4.data,[A(:,1)+B, A(:,2)+B]+A,1e-15);
%$    t(5) = dassert(ts4.name,{'A1';'A2'});
%$    t(6) = dassert(ts4.name,{'plus(plus(A1, B1), A1)';'plus(plus(A2, B1), A2)'});
%$ end
%$ T = all(t);
%@eof:2


%@test:3
%$ % Define a datasets.
%$ A = rand(10,2); B = randn(5,1);
%$
%$ % Define names
%$ A_name = {'A1';'A2'}; B_name = {'B1'};
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts3 = ts1+ts2;
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts3.vobs,2);
%$    t(3) = dassert(ts3.nobs,10);
%$    t(4) = dassert(ts3.data,[A(1:5,1)+B(1:5), A(1:5,2)+B(1:5) ; NaN(5,2)],1e-15);
%$ end
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$     ts = dseries(transpose(1:5),'1950q1',{'Output'}, {'Y_t'});
%$     us = dseries(transpose(1:5),'1949q4',{'Consumption'}, {'C_t'});
%$     vs = ts+us;
%$     t(1) = true;
%$ catch
%$     t = false;
%$ end
%$
%$ if length(t)>1
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(us.freq,4);
%$     t(4) = dassert(ts.init.time,[1950, 1]);
%$     t(5) = dassert(us.init.time,[1949, 4]);
%$     t(6) = dassert(vs.init.time,[1949, 4]);
%$     t(7) = dassert(vs.nobs,6);
%$ end
%$
%$ T = all(t);
%@eof:4

%@test:5
%$ try
%$     ts = dseries(transpose(1:5),'1950q1',{'Output'}, {'Y_t'});
%$     us = dseries(transpose(1:7),'1950q1',{'Consumption'}, {'C_t'});
%$     vs = ts+us;
%$     t(1) = true;
%$ catch
%$     t = false;
%$ end
%$
%$ if length(t)>1
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(us.freq,4);
%$     t(4) = dassert(ts.init.time,[1950, 1]);
%$     t(5) = dassert(us.init.time,[1950, 1]);
%$     t(6) = dassert(vs.init.time,[1950, 1]);
%$     t(7) = dassert(vs.nobs,7);
%$ end
%$
%$ T = all(t);
%@eof:5

%@test:6
%$ try
%$     ts = dseries(transpose(1:5),'1950q1',{'Output'}, {'Y_t'});
%$     us = dseries(transpose(1:7),'1950q1',{'Consumption'}, {'C_t'});
%$     vs = ts+us('1950q1').data;
%$     t(1) = true;
%$ catch
%$     t = false;
%$ end
%$
%$ if length(t)>1
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(us.freq,4);
%$     t(4) = dassert(ts.init.time,[1950, 1]);
%$     t(5) = dassert(us.init.time,[1950, 1]);
%$     t(6) = dassert(vs.init.time,[1950, 1]);
%$     t(7) = dassert(vs.nobs,5);
%$     t(8) = dassert(vs.data,ts.data+1);
%$ end
%$
%$ T = all(t);
%@eof:6

%@test:7
%$ try
%$     ts = dseries([transpose(1:5), transpose(1:5)],'1950q1');
%$     us = dseries([transpose(1:7),2*transpose(1:7)],'1950q1');
%$     vs = ts+us('1950q1').data;
%$     t(1) = true;
%$ catch
%$     t = false;
%$ end
%$
%$ if length(t)>1
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(us.freq,4);
%$     t(4) = dassert(ts.init.time,[1950, 1]);
%$     t(5) = dassert(us.init.time,[1950, 1]);
%$     t(6) = dassert(vs.init.time,[1950, 1]);
%$     t(7) = dassert(vs.nobs,5);
%$     t(8) = dassert(vs.data,bsxfun(@plus,ts.data,[1, 2]));
%$ end
%$
%$ T = all(t);
%@eof:7

%@test:8
%$ ts1 = dseries(ones(3,1));
%$ ts2 = ts1+1;
%$ ts3 = 1+ts1;
%$ t(1) = isequal(ts2.data, 2*ones(3,1));
%$ t(2) = isequal(ts3.data, 2*ones(3,1));
%$ T = all(t);
%@eof:8

%@test:9
%$ ts1 = dseries(ones(3,2));
%$ ts2 = ts1+1;
%$ ts3 = 1+ts1;
%$ t(1) = isequal(ts2.data, 2*ones(3,2));
%$ t(2) = isequal(ts3.data, 2*ones(3,2));
%$ T = all(t);
%@eof:9

%@test:10
%$ ts1 = dseries(ones(3,2));
%$ ts2 = ts1+ones(3,1);
%$ ts3 = ones(3,1)+ts1;
%$ t(1) = isequal(ts2.data, 2*ones(3,2));
%$ t(2) = isequal(ts3.data, 2*ones(3,2));
%$ T = all(t);
%@eof:10

%@test:11
%$ ts1 = dseries(ones(3,2));
%$ ts2 = ts1+ones(1,2);
%$ ts3 = ones(1,2)+ts1;
%$ t(1) = isequal(ts2.data, 2*ones(3,2));
%$ t(2) = isequal(ts3.data, 2*ones(3,2));
%$ T = all(t);
%@eof:11
