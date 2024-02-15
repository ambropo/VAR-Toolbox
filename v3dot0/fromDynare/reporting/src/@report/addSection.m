function o = addSection(o, varargin)
%function o = addSection(o, varargin)
% Add a section
%
% INPUTS
%   o          [report]  report object
%   varargin             arguments to section()
%
% OUTPUTS
%   o          [report]  updated report object
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2013-2019 Dynare Team
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

assert(~isempty(o.pages) > 0, ...
       '@report.addSection: Before adding a section, you must add a page.');
o.pages{end}.addSection(varargin{:});
end
