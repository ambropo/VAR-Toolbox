function o = addSeries(o, varargin)
%function o = addSeries(o, varargin)
% Add a series
%
% INPUTS
%   o          [section] section object
%   varargin             arguments to report_series()
%
% OUTPUTS
%   updated section object
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

assert(~isempty(o.elements), ...
    '@section.addSeries: Before adding a series, you must add either a graph or a table');
assert(~isa(o.elements{1}, 'paragraph'), ...
    '@section.addSeries: A section that contains a paragraph cannot contain a graph or a table');
assert(isa(o.elements{end}, 'report_graph') || isa(o.elements{end}, 'report_table'), ...
    '@report.addSeries: you can only add a series to a report_table or report_graph object');
o.elements{end}.addSeries(varargin{:});
end
