function o = addPage(o, varargin)
%function o = addPage(o, varargin)
% Add a page
%
% INPUTS
%   o          [report]  report object
%   varargin             arguments to @section/addGraph.m
%
% OUTPUTS
%   o          [report]  updated report object
%
% SPECIAL REQUIREMENTS
%   none

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

np = length(o.pages) + 1;
if o.showOutput
    fprintf(1, 'Adding Page: %d\n', np);
end
o.pages{np} = page('orientation', o.orientation, 'paper', o.paper, varargin{:});
end
