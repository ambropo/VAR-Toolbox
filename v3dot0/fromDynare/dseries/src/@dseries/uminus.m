function o = uminus(o) % --*-- Unitary tests --*--

% Overloads the uminus method for dseries objects.
%
% INPUTS
% - o   [dseries]
%
% OUTPUTS
% - o   [dseries]

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

o = copy(o);

o.data = -(o.data);

for i = 1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {sprintf('uminus(%s)', o.name{i})};
    else
        o.ops(i) = {sprintf('uminus(%s)', o.ops{i})};
    end
end

%@test:1
%$ % Define a datasets.
%$ A = rand(10,2);
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ A_tex = {'A_1';'A_2'};
%$ t = zeros(6,1);
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,A_tex);
%$    ts2 = -ts1;
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts2.vobs,2);
%$    t(3) = dassert(ts2.nobs,10);
%$    t(4) = dassert(ts2.data,-A,1e-15);
%$    t(5) = dassert(ts2.name,{'A1';'A2'});
%$    t(6) = dassert(ts2.tex,{'A_1';'A_2'});
%$    t(7) = dassert(ts2.ops,{'uminus(A1)';'uminus(A2)'});
%$ end
%$ T = all(t);
%@eof:1
