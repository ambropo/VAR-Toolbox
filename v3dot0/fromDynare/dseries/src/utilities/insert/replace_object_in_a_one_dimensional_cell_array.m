function one_dimensional_cell_array = replace_object_in_a_one_dimensional_cell_array(one_dimensional_cell_array, object, i)

% Replaces an object in a one dimensional cell array in a position specified by i.
%
% INPUTS
% - one_dimensional_cell_array [any]     cell array with n objects.
% - object                     [any]     scalar object.
% - i                          [integer] scalar between 1 and n.
%
% OUTPUTS
% - one_dimensional_cell_array [any]     cell array with n+1 elements.

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

if nargin<3
    error('replace_object_in_a_one_dimensional_cell_array: I need at least three input arguments!')
end

if ~iscell(one_dimensional_cell_array)
    error(['replace_column_vector_in_a_matrix: First input ''' inputname(1) ''' must be a cell array!'])
end

[nr, nc] = size(one_dimensional_cell_array);

if ~isequal(max([nr,nc]),numel(one_dimensional_cell_array))
    error(['replace_column_vector_in_a_matrix: First input ''' inputname(1) ''' must be a one dimensional cell array!'])
end

n = numel(one_dimensional_cell_array);

if ~isint(i) || i<1 || i>n
    error(['replace_column_vector_in_a_matrix: Last input ''' inputname(3) ''' must be a positive integer less than or equal to ' int2str(n) '!'])
end

one_dimensional_cell_array = one_dimensional_cell_array(:);

% Remove object i.
switch i
  case n
    one_dimensional_cell_array = one_dimensional_cell_array(1:n-1);
  case 1
    one_dimensional_cell_array = one_dimensional_cell_array(2:n);
  otherwise
    one_dimensional_cell_array = [one_dimensional_cell_array(1:i-1); one_dimensional_cell_array(i+1:n)];
end

% convert object to a cell array if needed.
if ~iscell(object)
    object = {object};
end

% Insert object at position i
one_dimensional_cell_array = insert_object_in_a_one_dimensional_cell_array(one_dimensional_cell_array, object(:), i);

% transpose cell array if needed.
if nc>nr
    one_dimensional_cell_array = transpose(one_dimensional_cell_array);
end


%@test:1
%$ A = {'A12'; 'A3'; 'A4'}; B = {'A1'; 'A2'};
%$
%$ try
%$   C = replace_object_in_a_one_dimensional_cell_array(A, B, 1);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(C,[B; A(2:3)]);
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ A = {'A1'; 'A3'; 'A4'}; B = 'B1';
%$
%$ try
%$   C = replace_object_in_a_one_dimensional_cell_array(A, B, 2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ D = {'A1';'B1';'A4'};
%$ if t(1)
%$   t(2) = dassert(C,D);
%$ end
%$ T = all(t);
%@eof:2