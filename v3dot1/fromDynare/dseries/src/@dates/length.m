function n = length(o) % --*-- Unitary tests --*--

% Returns the number of elements in a dates object.
%
% INPUTS
% - o [dates]
%
% OUTPUTS
% - n [integer] Number of elements in o.

% Copyright (C) 2013-2017 Dynare Team
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

n = o.ndat();

%@test:1
%$ d = dates('1938Q1');
%$ % Test if this object is empty
%$ t(1) = isequal(d.length(),1);
%$ T = all(t);
%@eof:1

%@test:2
%$ d = dates();
%$ % Test if this object is empty
%$ t(1) = isequal(d.length(),0);
%$ T = all(t);
%@eof:2

%@test:3
%$ d = dates('1938Q1')+dates('1938Q2')+dates('1938Q3');
%$ % Test if this object is empty
%$ t(1) = isequal(d.length(),3);
%$ T = all(t);
%@eof:3
