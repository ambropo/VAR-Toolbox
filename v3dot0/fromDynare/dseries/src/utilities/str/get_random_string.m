function s = get_random_string(n);

% Builds a random string (starting with a letter).
%
% INPUTS
% - n [integer] scalar, length of the generated string.
%
% OUTPUTS
% - s [string] random string of length n.

% Copyright (C) 2012-2017 Dynare Team
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

s0 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

m0 = 2*26;
m1 = m0+10;

s = s0(ceil(rand*m0)); % First character has to be a letter!
s = [s, s0(ceil(rand(1,n-1)*m1))];