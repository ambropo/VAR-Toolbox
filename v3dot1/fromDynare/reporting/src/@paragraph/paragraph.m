classdef paragraph < handle
    % paragraph Class
    %
    % Copyright (C) 2014-2022 Dynare Team
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
    properties (SetAccess = private)
        balancedCols = true % Determines whether the text is spread out evenly across the columns when the Paragraph has more than one column. Default: true.
        cols = 1            % The number of columns for the Paragraph. Default: 1.
        heading = ''        % The heading for the Paragraph (like a section heading). The string must be valid LATEX code. Default: empty.
        indent = true       % Whether or not to indent the paragraph. Default: true.
        text = ''           % The paragraph itself. The string must be valid LATEX code. Default: empty.
    end
    methods
        function o = paragraph(varargin)
            %function o = paragraph(varargin)
            % Paragraph Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty paragraph object
            %                   1 arg   : must be paragraph object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [paragraph]  paragraph object
            %
            % SPECIAL REQUIREMENTS
            %   none
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'paragraph'), ...
                    'With one arg to Paragraph constructor, you must pass a paragraph object');
                o = varargin{1};
                return
            end

            if round(nargin/2) ~= nargin/2
                error(['@paragraph.paragraph: options must be ' ...
                    'supplied in name/value pairs.']);
            end

            % Octave 5.1.0 has not implemented `properties` and issues a warning when using `fieldnames`
            if isoctave
                warnstate = warning('off', 'Octave:classdef-to-struct');
            end
            optNames = fieldnames(o);
            if isoctave
                warning(warnstate);
            end

            for pair = reshape(varargin, 2, [])
                ind = find(strcmpi(optNames, pair{1}));
                assert(isempty(ind) || length(ind) == 1);
                if ~isempty(ind)
                    o.(optNames{ind}) = pair{2};
                else
                    error('@paragraph.paragraph: %s is not a recognized option.', pair{1});
                end
            end
            % Check input
            assert(islogical(o.indent), '@paragraph.paragraph: indent must be either true or false');
            assert(islogical(o.balancedCols), '@paragraph.paragraph: balancedCols must be either true or false');
            assert(isint(o.cols), '@paragraph.paragraph: cols must be an integer');
            assert(ischar(o.text), '@paragraph.paragraph: text must be a string');
            assert(ischar(o.heading), '@paragraph.paragraph: heading must be a string');
        end
    end
    methods (Hidden = true)
        % Methods defined in separate files
        write(o, fid);
    end
end
