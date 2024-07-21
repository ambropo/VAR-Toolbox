function y = nanmean(x, dim)

% Returns the mean of a matrix with some NaNs.
%
% INPUTS
% - x      [double]    m*n matrix
% - dim    [integer]   scalar, dimension along which the mean has to be computed.
%
% OUTPUTS
% - y      [double]    1*n vector (if dim=1) or m*1 vector (if dim=2).
%
% REMARKS
% (1) Default value for dim is the first non singleton dimension.
% (2) Works with vector and matrices, not implemented for arrays with more
% than two dimensions.

% Copyright (C) 2011-2019 Dynare Team
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

if nargin<2
    % By default dim is the first non singleton dimension
    nonsingletondims = find(find(size(x)>1));
    if ~isempty(nonsingletondims)
        dim = nonsingletondims(1);
    else
        dim = NaN;
    end
end

switch ndims(x)
  case 1
    if isnan(dim)
        y = x;
    else
        y = mean(x(find(~isnan(x))), dim);
    end
  case 2
    if isnan(dim)
        y = x;
    else
        if isequal(dim, 1)
            y = NaN(1, size(x, 2));
            for i = 1:size(x, 2)
                y(i) = mean(x(find(~isnan(x(:,i))),i));
            end
        else
            y = NaN(size(x, 1), 1);
            for i = 1:size(x, 1)
                y(i) = mean(x(i, find(~isnan(x(i,:)))));
            end
        end
    end
  otherwise
    error('This function is not implemented for arrays with dimension greater than two!')
end