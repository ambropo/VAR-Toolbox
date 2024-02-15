function b = isequal(o, p, tol)

% Overloads the isequal Matlab/Octave's function.
%
% INPUTS
% - o      [dseries]  T periods, N variables.
% - p      [dseries]  T periods, N variables.
% - tol    [double]   tolerance parameter.
%
% OUTPUTS
%  o b     [logical]

% Copyright (C) 2013-2017 Dynare Team
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

if nargin~=2
    error('dseries::isequal: I need exactly two input arguments!')
end

if ~isdseries(p)
    error('dseries::isequal: Both input arguments must be dseries objects!')
end

if ~isequal(nobs(o), nobs(p))
    b = 0;
    return
end

if ~isequal(vobs(o), vobs(p))
    b = 0;
    return
end

if ~isequal(frequency(o), frequency(p))
    b = 0;
    return
end

if ~isequal(o.dates, p.dates)
    b = 0;
    return
end

if ~isequal(o.name, p.name)
    warning off backtrace
    warning('dseries::isequal: Both input arguments do not have the same variables!')
    warning on backtrace
end

if ~isequal(o.tex, p.tex)
    warning off backtrace
    warning('dseries::isequal: Both input arguments do not have the same tex names!')
    warning on backtrace
end

if ~isequal(o.ops, p.ops)
    warning off backtrace
    warning('dseries::isequal: Both input arguments received different treatments!')
    warning on backtrace
end

if ~isequal(o.tags, p.tags)
    warning off backtrace
    warning('dseries::isequal: Both input arguments have different tags!')
    warning on backtrace
end


if nargin<3
    b = isequal(o.data, p.data);
else
    b = ~(max(abs(o.data(:)-p.data(:)))>tol);
end