function s = getNameForLegend(o)
%function s = getNameForLegend(o)

% Copyright (C) 2014-2015 Dynare Team
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

if isempty(o.data) || ~o.graphShowInLegend
    % for the case when there is no data in the series
    % e.g. graphVline was passed
    % or when the user does not want this series shown in
    % the legend
    s = '';
else
    assert(size(o.data,2) == 1);
    s = o.data.tex{:};
end
end