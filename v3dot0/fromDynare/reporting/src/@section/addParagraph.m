function o = addParagraph(o, varargin)
%function o = addParagraph(o, varargin)
% Add a paragraph
%
% INPUTS
%   o          [section] section object
%   varargin             arguments to paragraph()
%
% OUTPUTS
%   updated page object
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2014-2019 Dynare Team
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

assert(o.cols == 1, ...
       '@addParagraph: you can only add a paragraph to a Section that contains one column');
for i = 1:length(o.elements)
    assert(isa(o.elements{i}, 'paragraph'), ...
           '@addParagraph: you can only add a paragraph to a Section that contains only paragraphs');
end
o.elements{end+1} = paragraph(varargin{:});
end
