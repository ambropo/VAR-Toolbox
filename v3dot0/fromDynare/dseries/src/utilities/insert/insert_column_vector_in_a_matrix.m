function matrix = insert_column_vector_in_a_matrix(matrix, vector, i)  % --*-- Unitary tests --*--

% Inserts a vector in a matrix in a column specified by i.
%
% INPUTS
% - matrix [float]   n*m matrix.
% - vector [float]   n*1 vector.
% - i      [integer] scalar between 1 and m+1. Default value is m+1.
%
% OUTPUTS
% - matrix [float]   n*(m+1) matrix.

% Copyright (C) 2013-2017 Dynare Team
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

if nargin<2
    error('insert_column_vector_in_a_matrix: I need at least two input arguments!')
end

if ~isequal(ndims(matrix),2)
    error(['insert_column_vector_in_a_matrix: First input ''' inputname(1) ''' must be a matrix!'])
end

[n,m] = size(matrix);

if nargin<3
    i = m+1;
end

if ~isvector(vector) || ~isequal(numel(vector),size(vector,1)) || ~isequal(numel(vector),n)
    error(['insert_column_vector_in_a_matrix: Second input argument ''' inputname(2) ''' must be a ' int2str(n) ' by 1 vector!'])
end

switch i
  case m+1
    matrix = [matrix, vector];
  case 1
    matrix = [vector, matrix];
  otherwise
    matrix = [matrix(:,1:i-1), vector, matrix(:,i:m)];
end

%@test:1
%$ % Define a datasets.
%$ A = rand(8,3); b = rand(8,1);
%$
%$ try
%$   A4 = insert_column_vector_in_a_matrix(A, b);
%$   A1 = insert_column_vector_in_a_matrix(A, b, 1);
%$   A2 = insert_column_vector_in_a_matrix(A, b, 2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(A4,[A,b],1e-15);
%$   t(3) = dassert(A1,[b,A],1e-15);
%$   t(4) = dassert(A2,[A(:,1), b, A(:,2:end)],1e-15);
%$ end
%$ T = all(t);
%@eof:1