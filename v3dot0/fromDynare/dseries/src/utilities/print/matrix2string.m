function String = matrix2string(Matrix, withsquarebrackets)
    
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

[n, m] = size(Matrix);

if nargin<2
    withsquarebrackets = true;
end

if n==1 && m>1
    if withsquarebrackets
        String = sprintf('[%s]', num2str(Matrix, 12));
    else
        String = sprintf('%s', num2str(Matrix, 12));
    end
    return
end

if n>1 && m==1
    if withsquarebrackets
        String = sprintf('[%s]''', num2str(Matrix', 12));
    else
        String = sprintf('%s', num2str(Matrix', 12));
    end
    return
end

if n>1 && m>1
    String = sprintf('[%s;', matrix2string(Matrix(1,:), false));
    for i=2:n-1
        String = sprintf('%s %s;', String, matrix2string(Matrix(i,:), false));
    end
    String = sprintf('%s %s]', String, matrix2string(Matrix(end,:), false));
    return
end

% Input is a scalar
String = num2str(Matrix, 12);