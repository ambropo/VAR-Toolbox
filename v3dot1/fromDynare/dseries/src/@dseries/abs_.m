function o = abs_(o) % --*-- Unitary tests --*--

% Apply the absolute value to all the variables in a dseries object (in place modification).
%
% INPUTS
% - o [dseries]
%
% OUTPUTS
% - o [dseries]

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

for i=1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {['abs(' o.name{i} ')']};
    else
        o.ops(i) = {['abs(' o.ops{i} ')']};
    end
end

o.data = abs(o.data);

%@test:1
%$ % Define a dates object
%$ data = -ones(10,2);
%$ o = dseries(data);
%$ q = o;
%$ r = copy(o);
%$
%$ % Call the tested routine.
%$ try
%$     o.abs_();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$      t(2) = dassert(o.data, ones(10,2));
%$      t(3) = dassert(q.data, ones(10,2));
%$      t(4) = dassert(r.data, -ones(10, 2));
%$      t(5) = dassert(o.name{1}, 'Variable_1');
%$      t(6) = dassert(q.name{1}, 'Variable_1');
%$      t(7) = dassert(r.name{1}, 'Variable_1');
%$      t(8) = dassert(o.ops{1}, 'abs(Variable_1)');
%$      t(9) = dassert(q.ops{1}, 'abs(Variable_1)');
%$      t(10) = dassert(r.name{1}, 'Variable_1');
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a dates object
%$ data = [ones(10,1), -ones(10,1)];
%$ o = dseries(data);
%$ q = o;
%$ r = copy(o);
%$
%$ % Call the tested routine.
%$ try
%$     o.abs_();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$      t(2) = dassert(length(o.name), 2);
%$      t(3) = dassert(o.name{1},'Variable_1');
%$      t(4) = dassert(o.name{2},'Variable_2');
%$      t(5) = dassert(q.name{1},'Variable_1');
%$      t(6) = dassert(q.name{2},'Variable_2');
%$      t(7) = dassert(r.name{1},'Variable_1');
%$      t(8) = dassert(r.name{2},'Variable_2');
%$      t(9) = dassert(o.ops{1},'abs(Variable_1)');
%$      t(10) = dassert(o.ops{2},'abs(Variable_2)');
%$      t(11) = dassert(q.ops{1},'abs(Variable_1)');
%$      t(12) = dassert(q.ops{2},'abs(Variable_2)');
%$      t(13) = isempty(r.ops{1});
%$      t(14) = isempty(r.ops{2});
%$ end
%$
%$ T = all(t);
%@eof:2