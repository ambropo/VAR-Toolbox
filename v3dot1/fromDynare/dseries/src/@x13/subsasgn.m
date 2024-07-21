function val = subsasgn(val, idx, rhs) % --*-- Unitary tests --*--

% Copyright (C) 2017 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dseries submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

error('Members of x13 class are private')

%@test:1
%$ t = zeros(3,1);
%$
%$ y = dseries(rand(100,1),'1999M1');
%$ o = x13(y);
%$
%$ try
%$     o.commands = {'yes','no','maybe'};
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ try
%$     o.results = 'Perverse string';
%$     t(2) = false;
%$ catch
%$     t(2) = true;
%$ end
%$
%$ try
%$     o.y = dseries(rand(100,1));
%$     t(3) = false;
%$ catch
%$     t(3) = true;
%$ end
%$
%$ T = all(t);
%@eof:1