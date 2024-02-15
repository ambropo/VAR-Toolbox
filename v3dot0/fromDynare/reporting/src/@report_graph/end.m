function lastIndex = end(o, k, n)
% function lastIndex = end(o, k, n)
% End keyword
%
% INPUTS
%   o              [report_graph]   report_graph object
%   k              [integer] index where end appears
%   n              [integer] number of indices
%
% OUTPUTS
%   lastIndex      [integer] last graph index
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2013-2020 Dynare Team
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

assert(k==1 && n==1, '@report_graph/end: graph only has one dimension');
lastIndex = length(o.series);
end
