function l = isempty(o) % --*-- Unitary tests --*--

% Returns true (1) if and only if o dates object is empty.
%
% INPUTS
% - o [dates]
%
% OUTPUTS
% - l [logical]

% Copyright (C) 2013-2021 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

l = isequal(o.ndat(), 0);

%@test:1
%$ % Instantiate an empty dates object
%$ d = dates();
%$ % Test if this object is empty
%$ t(1) = isempty(d);
%$ T = all(t);
%@eof:1

%@test:2
%$ % Instantiate an empty dates object
%$ d = dates('1938Q4');
%$ % Test if this object is empty
%$ t(1) = ~isempty(d);
%$ T = all(t);
%@eof:2
