function [o, id] = pop_(o, a) % --*-- Unitary tests --*--

% Removes a variable from a dseries object.
%
% INPUTS
% - o   [dseries]  T observations and N variables.
% - a   [string]   Name of the variable to be removed.
%
% OUTPUTS
% - o   [dseries]  T observations and N-1 variables.

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

if nargin<2
    % Removes the last variable
    id = vobs(o);
else
    id = find(strcmp(a, o.name));
end

if isempty(id)
    id = 0;
    return
end

o.data(:,id) = [];
o.name(id) = [];
o.tex(id) = [];
o.ops(id) = [];
otagnames = fieldnames(o.tags);
for i=1:length(otagnames)
    o.tags.(otagnames{i})(id) = []; 
end

%@test:1
%$ % Define a datasets.
%$ A = rand(10,3);
%$
%$ % Define names
%$ A_name = {'A1';'A2';'A3'};
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts1.tag('type');
%$    ts1.tag('type', 'A1', 1);
%$    ts1.tag('type', 'A2', 2);
%$    ts1.tag('type', 'A3', 3);
%$    ts1.pop_('A2');
%$    t(1) = 1;
%$ catch
%$    t(1) = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts1.vobs,2);
%$    t(3) = dassert(ts1.nobs,10);
%$    t(4) = dassert(ts1.data,[A(:,1), A(:,3)],1e-15);
%$    t(5) = dassert(ts1.tags.type, {1;3});
%$ end
%$ T = all(t);
%@eof:1