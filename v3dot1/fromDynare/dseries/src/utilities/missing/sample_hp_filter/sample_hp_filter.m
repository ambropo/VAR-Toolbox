function [hptrend,hpcycle] = sample_hp_filter(y,s)

% HP filters a collection of time series.
%
% INPUTS
%   y                        [double]   T*n matrix of data (n is the number of variables)
%   s                        [double]   scalar, smoothing parameter.
%
% OUTPUTS
%   hptrend                  [double]   T*n matrix, trend component of y.
%   hpcycle                  [double]   T*n matrix, cycle component of y.

% Copyright (C) 2010-2017 Dynare Team
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

[T,n] = size(y);

if nargin<2 || isempty(s)
    s = 1600;
end

D = spdiags(repmat([s, -4.0*s, (1 + 6.0*s), -4.0*s, s], T, 1), -2:2, T, T);% Sparse matrix.
D(1,1) = 1.0+s; D(T,T) = D(1,1);
D(1,2) = -2.0*s; D(2,1) = D(1,2); D(T-1,T) = D(1,2); D(T,T-1) = D(1,2);
D(2,2) = 1.0+5.0*s; D(T-1,T-1) = D(2,2);

hptrend = D\y;

if nargout>1
    hpcycle = y-hptrend;
end