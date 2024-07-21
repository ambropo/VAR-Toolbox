function q = merge(o, p, legacy) % --*-- Unitary tests --*--

% Merge method for dseries objects.
%
% INPUTS
% - o                [dseries]
% - p                [dseries]
% - legacy           [logical]      revert to legacy behaviour if `true` (default is `false`), 
%
% OUTPUTS
% - q                [dseries]
%
% REMARKS
% If dseries objects o and p have common variables, the variables
% in p take precedence except if p has NaNs (the exception can be
% removed by setting the third argument, legacy, equal to true).

% Copyright © 2013-2020 Dynare Team
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

if ~isdseries(p) || ~isdseries(o)
    error('dseries::merge: Both inputs must be dseries objects!')
end

if isempty(o) && ~isempty(p)
    q = p;
    return
elseif ~isempty(o) && isempty(p)
    q = o;
    return
elseif isempty(o) && isempty(p)
    q = p;
    return
end

if nargin<3
    legacy = false;
end

if ~isequal(frequency(o), frequency(p))
    if isempty(inputname(1))
        error('dseries::merge: Cannot merge dseries objects (frequencies are different)!')
    else
        error(['dseries::merge: Cannot merge ' inputname(1) ' and ' inputname(2) ' (frequencies are different)!'])
    end
end

q = dseries();

[q.name, IBC, ~] = unique([o.name; p.name], 'last');

if ~legacy
    [list_of_common_variables, iO, iP] = intersect(o.name, p.name);
end

tex = [o.tex; p.tex];
q.tex = tex(IBC);

ops = [o.ops; p.ops];
q.ops = ops(IBC);

otagnames = fieldnames(o.tags);
ptagnames = fieldnames(p.tags);
qtagnames = union(otagnames, ptagnames);
if isempty(qtagnames)
    q.tags = struct();
else
    for i=1:length(qtagnames)
        if ismember(qtagnames{i}, otagnames) && ismember(qtagnames{i}, ptagnames)
            q.tags.(qtagnames{i}) = vertcat(o.tags.(otagnames{i}), p.tags.(ptagnames{i}));
        elseif ismember(qtagnames{i}, otagnames)
            q.tags.(qtagnames{i}) = vertcat(o.tags.(qtagnames{i}), cell(vobs(p), 1));
        elseif ismember(qtagnames{i}, ptagnames)
            q.tags.(qtagnames{i}) = vertcat(cell(vobs(o), 1), p.tags.(qtagnames{i}));
        else
            error('dseries::horzcat: This is a bug!')
        end
        q.tags.(qtagnames{i}) = q.tags.(qtagnames{i})(IBC);
    end
end

if nobs(o) == 0
    q = copy(p);
elseif nobs(p) == 0
    q = copy(o);
elseif firstdate(o) >= firstdate(p)
    diff = firstdate(o) - firstdate(p);
    q_nobs = max(nobs(o) + diff, nobs(p));
    q.data = NaN(q_nobs, vobs(q));
    Z1 = [NaN(diff, vobs(o)); o.data];
    if nobs(q) > nobs(o) + diff
        Z1 = [Z1; NaN(nobs(q)-(nobs(o) + diff), vobs(o))];
    end
    Z2 = p.data;
    if nobs(q) > nobs(p)
        Z2 = [Z2; NaN(nobs(q) - nobs(p), vobs(p))];
    end
    Z = [Z1 Z2];
    q.data = Z(:,IBC);
    if ~legacy
        if ~isempty(list_of_common_variables)
            for i=1:length(iP)
                jO = iO(i);
                jP = iP(i);
                jQ = find(strcmp(o.name{jO}, q.name));
                id = isnan(q.data(:,jQ)) & ~isnan(Z1(:,jO)) & isnan(Z2(:,jP));
                q.data(id, jQ) = Z1(id,jO);
            end
        end
    end
    q_init = firstdate(p);
else
    diff = firstdate(p) - firstdate(o);
    q_nobs = max(nobs(p) + diff, nobs(o));
    q.data = NaN(q_nobs, vobs(q));
    Z1 = [NaN(diff, vobs(p)); p.data];
    if nobs(q) > nobs(p) + diff
        Z1 = [Z1; NaN(nobs(q)-(nobs(p) + diff), vobs(p))];
    end
    Z2 = o.data;
    if nobs(q) > nobs(o)
        Z2 = [Z2; NaN(nobs(q) - nobs(o), vobs(o))];
    end
    Z = [Z2 Z1];
    q.data = Z(:,IBC);
    if ~legacy
        if ~isempty(list_of_common_variables)
            for i=1:length(iP)
                jO = iO(i);
                jP = iP(i);
                jQ = find(strcmp(o.name{jO}, q.name));
                id = isnan(q.data(:,jQ)) & isnan(Z1(:,jP)) & ~isnan(Z2(:,jO));
                q.data(id, jQ) = Z2(id,jO);
            end
        end
    end
    q_init = firstdate(o);
end

q.dates = q_init:q_init+(nobs(q)-1);

%@test:1
%$ % Define a datasets.
%$ A = rand(10,2); B = randn(10,1);
%$
%$ % Define names
%$ A_name = {'A1';'A2'}; B_name = {'A1'};
%$
%$ % Instantiate two time series objects and merge.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts1.tag('type');
%$    ts1.tag('type', 'A1', 'Stock');
%$    ts1.tag('type', 'A2', 'Flow');
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts2.tag('type');
%$    ts2.tag('type', 'A1', 'Flow');
%$    ts3 = merge(ts1,ts2);
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts3.vobs,2);
%$    t(3) = dassert(ts3.nobs,10);
%$    t(4) = dassert(ts3.data,[B, A(:,2)],1e-15);
%$    t(5) = dassert(ts3.tags.type, {'Flow';'Flow'});
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
%$ % Instantiate two time series objects and merge them.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts1.tag('t1');
%$    ts1.tag('t1', 'A1', 'Stock');
%$    ts1.tag('t1', 'A2', 'Flow');
%$    ts2 = dseries(B,[],B_name,[]);
%$    ts2.tag('t2');
%$    ts2.tag('t2', 'B1', 1);
%$    ts3 = merge(ts1,ts2);
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts3.vobs,3);
%$    t(3) = dassert(ts3.nobs,10);
%$    t(4) = dassert(ts3.data,[A, B],1e-15);
%$    t(5) = dassert(ts3.tags.t1, {'Flow';'Flow';[]});
%$    t(6) = dassert(ts3.tags.t2, {[];[];1});
%$ end
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define two dseries objects.
%$ y = dseries(ones(4,1),'1989Q1', 'u');
%$ z = dseries(2*ones(4,1),'1990Q1', 'u');
%$
%$ % Merge the two objects.
%$ try
%$    x = merge(y, z);
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(x.vobs,1);
%$    t(3) = dassert(x.name{1},'u');
%$    t(4) = all(x.data(5:end)==2) && all(x.data(1:4)==1);
%$    t(5) = all(x.dates==dates('1989Q1'):dates('1990Q4'));
%$ end
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define two dseries objects.
%$ y = dseries(ones(4,1),'1989Q1', 'u');
%$ z = dseries([NaN(4,1); 2*ones(4,1)],'1989Q1', 'u');
%$
%$ % Merge the two objects.
%$ try
%$    x = merge(y, z);
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(x.vobs,1);
%$    t(3) = dassert(x.name{1},'u');
%$    t(4) = all(x.data(5:end)==2) && all(x.data(1:4)==1);
%$    t(5) = all(x.dates==dates('1989Q1'):dates('1990Q4'));
%$ end
%$ T = all(t);
%@eof:4

%@test:5
%$ % Define two dseries objects.
%$ y = dseries(ones(8,1),'1938Q4', 'u');
%$ z = dseries(NaN(8,1),'1938Q4', 'u');
%$
%$ % Inderectly call merge method via subsasgn.
%$ try
%$    y.u = z.u;
%$    t(1) = true;
%$ catch
%$    t = false;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(y.vobs, 1);
%$    t(3) = dassert(y.name{1}, 'u');
%$    t(4) = all(isnan(y.data));
%$    t(5) = dassert(y.nobs, z.nobs);
%$    t(6) = dassert(y.dates(1), z.dates(1));
%$ end
%$ T = all(t);
%@eof:5