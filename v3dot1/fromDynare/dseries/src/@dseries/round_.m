function o = round_(o, n) % --*-- Unitary tests --*--

% Rounds to nearest decimal or integer.
%
% INPUTS
% - o [dseries]
% - n [integer]    scalar, number of decimals. Default is 0.
%
% OUTPUTS
% - o [dseries]

% Copyright (C) 2020 Dynare Team
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

if nargin<2 || isempty(n)
    n = 0;
end

for i=1:vobs(o)
    if isempty(o.ops{i})
        o.ops(i) = {['round(' o.name{i} ', ' int2str(n) ')']};
    else
        o.ops(i) = {['round(' o.ops{i} ', ' int2str(n) ')']};
    end
end

if isoctave || matlab_ver_less_than('8.4')
    o.data = round(o.data*10^n)/10^n;
else
    o.data = round(o.data, n);
end

%@test:1
%$ % Define a dates object
%$ data = 1.23;
%$ o = dseries(data);
%$
%$ % Call the tested routine.
%$ try
%$     o.round_(1);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$      t(2) = dassert(o.data, 1.2);
%$ end
%$
%$ T = all(t);
%@eof:1