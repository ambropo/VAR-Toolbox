function [o, id] = pop(o, a) % --*-- Unitary tests --*--

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

o = copy(o);

if nargin<2
    [o, id] = pop_(o);
else
    [o, id] = pop_(o, a);
end

%@test:1
%$ % Define a datasets.
%$ A = rand(10,3);
%$
%$ % Define names
%$ A_name = {'A1';'A2';'A3'};
%$
%$ t = zeros(4,1);
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    ts2 = ts1.pop('A2');
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts2.vobs,2);
%$    t(3) = dassert(ts2.nobs,10);
%$    t(4) = dassert(ts2.data,[A(:,1), A(:,3)],1e-15);
%$    t(5) = dassert(ts1.vobs,3);
%$    if t(5)
%$      t(6) = dassert(ts1.data,A,1e-15);
%$    end
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a datasets.
%$ A = rand(10,3);
%$
%$ % Define names
%$ A_name = {'A1';'A2';'A3'};
%$
%$ t = zeros(2,1);
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],A_name,[]);
%$    [ts2,id] = pop(ts1,'A4');
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(id,0);
%$    t(2) = dassert(ts1,ts2);
%$ end
%$ T = all(t);
%@eof:2
