function o = abs(o) % --*-- Unitary tests --*--

% Apply the absolute value to all the variables in a dseries object (without in place modification).
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
o.abs_;

%@test:1
%$ % Define a dates object
%$ data = -ones(10,2);
%$ o = dseries(data);
%$ q = dseries(data);
%$
%$ % Call the tested routine.
%$ try
%$     p = o.abs();
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
%$ data = -ones(10,2);
%$ o = dseries(data);
%$ q = dseries(data);
%$
%$ % Call the tested routine.
%$ try
%$     p = o.abs();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$      t(2) = dassert(length(p.name), 2);
%$      t(3) = dassert(p.ops{1},'abs(Variable_1)');
%$      t(4) = dassert(p.ops{2},'abs(Variable_2)');
%$      t(5) = dassert(p.name{1},'Variable_1');
%$      t(6) = dassert(p.name{2},'Variable_2');
%$      t(7) = dassert(o.name{1},'Variable_1');
%$      t(8) = dassert(o.name{2},'Variable_2');
%$      t(9) = isempty(o.ops{1});
%$      t(10) = isempty(o.ops{2});
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define a datasets.
%$ A = randn(10,2);
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ A_tex = {'A_1';'A_2'};
%$
%$ % Instantiate a time series object and compute the absolute value.
%$ try
%$    ts1 = dseries(A,[],A_name,A_tex);
%$    ts2 = abs(ts1);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts2.vobs,2);
%$    t(3) = dassert(ts2.nobs,10);
%$    t(4) = dassert(ts2.data,abs(A),1e-15);
%$    t(5) = dassert(ts2.name,{'A1';'A2'});
%$    t(6) = dassert(ts2.ops,{'abs(A1)';'abs(A2)'});
%$    t(7) = dassert(ts2.tex,{'A_1';'A_2'});
%$    t(8) = dassert(ts1.vobs, 2);
%$    t(9) = dassert(ts1.nobs, 10);
%$    t(10) = dassert(ts1.data, A, 1e-15);
%$    t(11) = dassert(ts1.name, {'A1';'A2'});
%$    t(12) = dassert(ts1.tex, {'A_1';'A_2'});
%$    t(13) = isempty(ts1.ops{1});
%$    t(14) = isempty(ts1.ops{2});
%$ end
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define a datasets.
%$ A = randn(10,2);
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ A_tex = {'A_1';'A_2'};
%$
%$ % Instantiate a time series object and compute the absolute value.
%$ try
%$    ts1 = dseries(A,[],A_name,A_tex);
%$    ts2 = ts1.abs();
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts2.vobs,2);
%$    t(3) = dassert(ts2.nobs,10);
%$    t(4) = dassert(ts2.data,abs(A),1e-15);
%$    t(5) = dassert(ts2.name,{'A1';'A2'});
%$    t(6) = dassert(ts2.tex,{'A_1';'A_2'});
%$    t(7) = dassert(ts2.ops,{'abs(A1)';'abs(A2)'});
%$    t(8) = dassert(ts1.vobs, 2);
%$    t(9) = dassert(ts1.nobs, 10);
%$    t(10) = dassert(ts1.data, A, 1e-15);
%$    t(11) = dassert(ts1.name, {'A1';'A2'});
%$    t(12) = dassert(ts1.tex, {'A_1';'A_2'});
%$    t(13) = isempty(ts1.ops{1});
%$    t(14) = isempty(ts1.ops{2});
%$ end
%$ T = all(t);
%@eof:4
