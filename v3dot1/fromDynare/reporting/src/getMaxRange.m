function dd = getMaxRange(cellser)
% function dd = getMaxRange(cellser)

% Copyright (C) 2013-2015 Dynare Team
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

ddmin = dates();
ddmax = dates();
ne = length(cellser);
for i=1:ne
    ddt = cellser{i}.getRange();
    if ~isempty(ddt)
        if isempty(ddmin)
            ddmin = ddt(1);
            ddmax = ddt(end);
        else
            ddmin = min(ddt(1), ddmin);
            ddmax = max(ddt(end), ddmax);
        end
    end
end
dd = ddmin:ddmax;