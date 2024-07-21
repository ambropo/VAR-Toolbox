function o = insert(o, p, id) % --*-- Unitary tests --*--

% Adds a variable in a dseries object.
%
% INPUTS
% - o    [dseries]
% - p    [dseries]
% - id   [integer]   vector of indices.
%
% OUTPUTS
% - o    [dseries]

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

[n, message] = common_strings_in_cell_arrays(o.name, p.name);

if n
    if isempty(inputname(1))
        error(['dseries::insert: Variable(s) ' message ' already exist in dseries object!'])
    else
        error(['dseries::insert: Variable(s) ' message ' already exist in ''' inputname(1) '''!'])
    end
end

if ~isequal(frequency(o),frequency(p))
    if isempty(inputname(1))
        error(['dseries::insert: dseries objects must have common frequencies!'])
    else
        error(['dseries::insert: ''' inputname(1) ''' and ''' inputname(2) ''' dseries objects must have common frequencies!'])
    end
end

% Keep the second input argument constant.
p = copy(p);

% Add NaNs if necessary.
[o, p] = align(o, p);

n = length(id);

% Get tag names in p
ptagnames = fieldnames(p.tags);

if n>1
    [id, jd] = sort(id);
    p.data = p.data(:,jd);
    p.name = p.name(jd);
    p.tex = p.tex(jd);
    p.ops = p.ops(jd);
    if ~isempty(ptagnames)
        for i = 1:length(ptagnames)
            p.tags.(ptagnames{i}) = p.tags.(ptagnames{i})(jd);
        end
    end
end

% Get tag names in o
otagnames = fieldnames(o.tags);

% Merge tag names
if isempty(otagnames) && isempty(ptagnames)
    notags = true;
else
    notags = false;
    dtagnames_o = setdiff(ptagnames, otagnames);
    dtagnames_p = setdiff(otagnames, ptagnames);
    if ~isempty(dtagnames_o)
        % If p has tags that are not in o...
        for i=1:length(dtagnames_o)
            o.tags.(dtagnames_o{i}) = cell(vobs(o), 1);
        end
    end
    if ~isempty(dtagnames_p)
        % If o has tags that are not in p...
        for i=1:length(dtagnames_p)
            p.tags.(dtagnames_p{i}) = cell(vobs(p), 1);
        end
    end
end

% Update list of tag names in o.
otagnames = fieldnames(o.tags);

for i=1:n
    o.data = insert_column_vector_in_a_matrix(o.data, p.data(:,i),id(i));
    o.name = insert_object_in_a_one_dimensional_cell_array(o.name, p.name{i}, id(i));
    o.tex = insert_object_in_a_one_dimensional_cell_array(o.tex, p.tex{i}, id(i));
    o.ops = insert_object_in_a_one_dimensional_cell_array(o.ops, p.ops{i}, id(i));
    if ~notags
        for j=1:length(otagnames)
            o.tags.(otagnames{j}) = insert_object_in_a_one_dimensional_cell_array(o.tags.(otagnames{j}), p.tags.(otagnames{j}){i}, id(i));
        end
    end
    id = id+1;
end

%@test:1
%$ % Define a datasets.
%$ A = rand(10,3); B = rand(5,2);
%$
%$ % Define names.
%$ A_name = {'A1'; 'A2';'A3'};
%$ B_name = {'B1'; 'B2'};
%$
%$ % Define initial dates.
%$ A_init = '1950Q1';
%$ B_init = '1950Q3';
%$
%$ % Instantiate two dseries objects.
%$ ts1 = dseries(A, A_init, A_name,[]);
%$ ts2 = dseries(B, B_init, B_name,[]);
%$ ts1.tag('t1');
%$ ts1.tag('t1','A1',1);
%$ ts1.tag('t1','A2',1);
%$ ts1.tag('t1','A3',0);
%$ ts2.tag('t1');
%$ ts2.tag('t1','B1',1);
%$ ts2.tag('t1','B2',1);
%$ ts2.tag('t2');
%$ ts2.tag('t2','B1','toto');
%$ ts2.tag('t2','B2','titi');
%$
%$ try
%$    ts1 = insert(ts1,ts2,[1,2]);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$
%$ if t(1)
%$    t(2) = dassert(ts1.name,{'B1';'A1';'B2';'A2';'A3'});
%$    t(3) = dassert(ts1.nobs,10);
%$    eB = [NaN(2,2); B; NaN(3,2)];
%$    t(4) = dassert(ts1.data,[eB(:,1), A(:,1), eB(:,2), A(:,2:3)], 1e-15);
%$    t(5) = dassert(ts1.tags.t1,{1; 1; 1; 1; 0});
%$    t(6) = dassert(ts1.tags.t2,{'toto'; []; 'titi'; []; []});
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a datasets.
%$ A = rand(10,3); B = rand(5,2);
%$
%$ % Define names.
%$ A_name = {'A1'; 'A2';'A3'};
%$ B_name = {'B1'; 'B2'};
%$
%$ % Define initial dates.
%$ A_init = '1950Q1';
%$ B_init = '1950Q3';
%$
%$ % Instantiate two dseries objects.
%$ ts1 = dseries(A, A_init, A_name,[]);
%$ ts2 = dseries(B, B_init, B_name,[]);
%$
%$ try
%$    ts1.insert(ts2,[1,2]);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts1.vobs,{'B1';'A1';'B2';'A3'});
%$    t(3) = dassert(ts1.nobs,10);
%$    eB = [NaN(2,2); B; NaN(3,2)];
%$    t(4) = dassert(ts1.data,[eB(:,1), A(:,1), eB(:,2), A(:,2:3)], 1e-15);
%$    t(5) = dassert(ts2.data, B);
%$ end
%$ T = all(t);
%@eof:2