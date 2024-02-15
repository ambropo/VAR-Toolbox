function o = tag(o, a, b, c) % --*-- Unitary tests --*--

% Add tag to a dseries oject (in place modification).

% INPUTS
% - o        [dseries]
% - a        [string]     Name of the tag.
% - b        [string]     Name of the variable.
% - c        [any]        Value of the variable tag.
%
% OUTPUT
% - o        [dseries]    Updated with tag
    
% Copyright (C) 2017 Dynare Team
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

if nargin<3
    % Initialize a new tag name
    if ~ismember(a, fieldnames(o.tags))
        o.tags.(a) = cell(vobs(o), 1);
    end
else
    % Test if tag name (a) exists
    if ~ismember(a, fieldnames(o.tags))
        error('dseries::tag: Tag name %s is unknown!', a)
    end
    % Test if variable (b) exists
    if ~ismember(b, o.name)
        error('dseries::tag: Variable %s is unknown!', b)
    else
        id = strmatch(b, o.name, 'exact');
    end
    o.tags.(a)(id) = {c};
end

%@test:1
%$ ts = dseries(randn(10, 3));
%$ try
%$     tag(ts, 'name');
%$     tag(ts, 'name', 'Variable_1', 'Flow');
%$     tag(ts, 'name', 'Variable_2', 'Stock');
%$     tag(ts, 'name', 'Variable_3', 'Flow');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.tags.name, {'Flow'; 'Stock'; 'Flow'});
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ ts = dseries(randn(10, 3));
%$ try
%$     tag(ts, 'name');
%$     tag(ts, 'name', 'Variable_1', 'Flow');
%$     tag(ts, 'name', 'Variable_3', 'Flow');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.tags.name, {'Flow'; []; 'Flow'});
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ ts = dseries(randn(10, 3));
%$ try
%$     tag(ts, 'name');
%$     tag(ts, 'name', 'Variable_1', 'Flow');
%$     tag(ts, 'noname', 'Variable_3', 1);
%$     t(1) = 0;
%$ catch
%$     t(1) = 1;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.tags.name, {'Flow'; []; []});
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ ts = dseries(randn(10, 3));
%$ try
%$     ts.tag('name');
%$     ts.tag('name', 'Variable_1', 'Flow');
%$     ts.tag('name', 'Variable_2', 'Stock');
%$     ts.tag('name', 'Variable_3', 'Flow');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.tags.name, {'Flow'; 'Stock'; 'Flow'});
%$ end
%$
%$ T = all(t);
%@eof:4


