function [error_flag, message] = check(o)

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

error_flag = 0;

[n,m] = size(o.data);

if ~isequal(m, vobs(o));
    error_flag = 1;
    if nargout>1
        message = ['dseries: Wrong number of variables in dseries object ''' inputname(1) '''!'];
    end
    return
end

if ~isequal(n,nobs(o));
    error_flag = 1;
    if nargout>1
        message = ['dseries: Wrong number of observations in dseries object ''' inputname(1) '''!'];
    end
    return
end

if ~isequal(m,numel(o.name));
    error_flag = 1;
    if nargout>1
        message = ['dseries: Wrong number of variable names in dseries object ''' inputname(1) '''!'];
    end
    return
end

if ~isequal(m,numel(o.tex));
    error_flag = 1;
    if nargout>1
        message = ['dseries: Wrong number of variable tex names in dseries object ''' inputname(1) '''!'];
    end
    return
end

if ~isequal(numel(o.name), numel(o.tex));
    error_flag = 1;
    if nargout>1
        message = ['dseries: The number of variable tex names has to be equal to the number of variable names in dseries object ''' inputname(1) '''!'];
    end
    return
end

if ~isequal(numel(unique(o.name)), numel(o.name));
    error_flag = 1;
    if nargout>1
        message = ['dseries: The variable names in dseries object ''' inputname(1) ''' are not unique!'];
    end
    return
end

if ~isequal(numel(unique(o.tex)), numel(o.tex));
    error_flag = 1;
    if nargout>1
        message = ['dseries: The variable tex names in dseries object ''' inputname(1) ''' are not unique!'];
    end
    return
end

if ~isequal(o.dates, firstdate(o):firstdate(o)+nobs(o))
    error_flag = 1;
    if nargout>1
        message = ['dseries: Wrong definition of the dates member in dseries object ''' inputname(1) '''!'];
    end
    return
end