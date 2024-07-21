function a = iscellofchar(b)

% Returns true iff ```b``` is a cell of char.
%
% INPUTS
% - b [any]
%
% OUTPUTS
% - a [bool]

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

a = true;

if ndims(b)>2
    error(['iscellofchar: Input argument ''' inputname(1) ''' has to be a two dimensional cell array!'])
end

[n,m] = size(b);
p = numel(b);
q = 0;

for i=1:m
    for j=1:n
        if ischar(b{j,i})
            q = q + 1;
        end
    end
end

if ~isequal(q,p)
    a = false;
end