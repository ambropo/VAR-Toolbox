function c = demean(x)

% Removes the mean of each column of a matrix.
%
% INPUTS
% - x  [float] T*n matrix.
%
% OUTPUTS
% - c  [float] T*n matrix, the demeaned matrix x.

% Copyright (C) 2011-2017 Dynare Team
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

if ndim(x)==1
    c = x-mean(x);
elseif ndim(x)==2
    c = bsxfun(@minus,x,mean(x));
else
    error('descriptive_statistics::demean:: This function is not implemented for arrays with dimension greater than two!')
end