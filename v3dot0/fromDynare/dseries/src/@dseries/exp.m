function o = exp(o) % --*-- Unitary tests --*--

% Apply the exponential to all the variables in a dseries object (without in place modification).
%
% INPUTS
% - o [dseries]
%
% OUTPUTS
% - o [dseries]

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

o = copy(o);
o.exp_();

%@test:1
%$ % Define a dates object
%$ data = zeros(10,2);
%$ o = dseries(data);
%$ q = dseries(data);
%$
%$ % Call the tested routine.
%$ try
%$     p = o.exp();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$      t(2) = dassert(o, q);
%$      t(3) = dassert(p.data, ones(10, 2));
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a dates object
%$ data = zeros(10,2);
%$ o = dseries(data);
%$ q = dseries(data);
%$
%$ % Call the tested routine.
%$ try
%$     p = o.exp();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$      t(2) = dassert(length(p.name), 2);
%$      t(3) = dassert(p.name{1},'Variable_1');
%$      t(4) = dassert(p.name{2},'Variable_2');
%$      t(5) = dassert(o.name{1},'Variable_1');
%$      t(6) = dassert(o.name{2},'Variable_2');
%$      t(7) = dassert(p.ops{1},'exp(Variable_1)');
%$      t(8) = dassert(p.ops{2},'exp(Variable_2)');
%$      t(9) = isempty(o.ops{1});
%$      t(10) = isempty(o.ops{2});
%$ end
%$
%$ T = all(t);
%@eof:2