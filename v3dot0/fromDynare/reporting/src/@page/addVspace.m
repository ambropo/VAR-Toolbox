function o = addVspace(o, varargin)
%function o = addVspace(o, varargin)
% Add a vspace
%
% INPUTS
%   o          [page]    page object
%   varargin             arguments to vspace()
%
% OUTPUTS
%   updated section object
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2019 Dynare Team
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

assert(~isempty(o.sections), ...
       '@page.addVspace: Before adding a vspace, you must add a section.');
o.sections{end}.addVspace(varargin{:});
end
