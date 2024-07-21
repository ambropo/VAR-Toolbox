classdef page < handle
    % page Class
    %
    % Copyright (C) 2013-2022 Dynare Team
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
    properties (Access = private, Constant = true)
        titleFormatDefalut = {'\large\bfseries'}
    end
    properties (Access = private)
        sections = {}
    end
    properties (SetAccess = private)
        paper = ''                    % Paper size. Default: `a4'.
        title = {''}                  % With one entry (a STRING), the title of the page. With more than one entry (a CELL_ARRAY_STRINGS), the title and subtitle(s) of the page. Values passed must be valid LATEX code (e.g., % must be \%). Default: none.
        titleFormat = ''              % A string representing the valid LATEX markup to use on title. The number of cell array entries must be equal to that of the title option if you do not want to use the default value for the title (and subtitles). Default: \large\bfseries.
        titleTruncate = ''            % Useful when automatically generating page titles that may become too long, titleTruncate can be used to truncate a title (and subsequent subtitles) when they pass the specified number of characters. Default: .off.
        orientation = ''              % Paper orientation: Default: `portrait'.
        footnote = {}                 % A footnote to be included at the bottom of this page. Default: none.
        pageDirName = 'tmpRepDir'     % The name of the folder in which to store this page. Only used when the latex command is passed. Default: tmpRepDir.
        latex = ''                    % The valid LATEX code to be used for this page. Alows the user to create a page to be included in the report by passing LATEX code directly. Default: empty.
        setPageNumber = ''            % If true, reset the page number counter. Default: false.
        removeHeaderAndFooter = false % Removes the header and footer from this page. Default: false.
    end
    methods
        function o = page(varargin)
            %function o = page(varargin)
            % Page Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty page object
            %                   1 arg   : must be page object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [page]  page object
            %
            % SPECIAL REQUIREMENTS
            %   none
            o.titleFormat = o.titleFormatDefalut;
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'page'), ...
                    '@page.page: with one arg to Page constructor, you must pass a page object');
                o = varargin{1};
                return
            end

            if round(nargin/2) ~= nargin/2
                error('@page.page: options must be supplied in name/value pairs.');
            end

            % Octave 5.1.0 has not implemented `properties` and issues a warning when using `fieldnames`
            if isoctave
                warnstate = warning('off', 'Octave:classdef-to-struct');
            end
            optNames = fieldnames(o);
            if isoctave
                warning(warnstate);
            end

            % overwrite default values
            for pair = reshape(varargin, 2, [])
                ind = find(strcmpi(optNames, pair{1}));
                assert(isempty(ind) || length(ind) == 1);
                if ~isempty(ind)
                    o.(optNames{ind}) = pair{2};
                else
                    error('@page.page: %s is not a recognized option.', pair{1});
                end
            end

            % Check input
            if ischar(o.title)
                o.title = {o.title};
            end
            if ischar(o.titleFormat)
                o.titleFormat = {o.titleFormat};
            end
            if length(o.title) ~= length(o.titleFormat)
                o.titleFormat = repmat(o.titleFormatDefalut, 1, length(o.title));
            end
            assert(iscellstr(o.title), ...
                '@page.page: title must be a cell array of strings');
            assert(iscellstr(o.titleFormat), ...
                '@page.page: titleFormat must be a cell array of strings');
            assert((ischar(o.titleTruncate) && isempty(o.titleTruncate)) || ...
                isint(o.titleTruncate), ...
                '@page.page: titleTruncate must be empty or an integer.');
            assert(ischar(o.pageDirName), '@page.page: pageDirName must be a string');
            assert(ischar(o.latex), ...
                '@page.page: latex must be a string');
            valid_paper = {'a4', 'letter'};
            assert(any(strcmp(o.paper, valid_paper)), ...
                ['@page.page: paper must be one of ' addCommasToCellStr(valid_paper)]);
            valid_orientation = {'portrait', 'landscape'};
            assert(any(strcmp(o.orientation, valid_orientation)), ...
                ['@page.page: orientation must be one of ' addCommasToCellStr(valid_orientation)]);
            if ischar(o.footnote)
                o.footnote = {o.footnote};
            end
            assert(iscellstr(o.footnote), ...
                '@page.page: footnote must be a cell array of string(s)');
            assert(isempty(o.sections), ...
                '@page.page: sections is not a valid option');
            assert(isempty(o.setPageNumber) || isint(o.setPageNumber), ...
                '@page.page: setPageNumber must be an integer');
            assert(islogical(o.removeHeaderAndFooter), ...
                '@page.page: removeHeaderAndFooter must be boolean');
        end
    end
    methods (Hidden = true)
        o = addSection(o, varargin)
        o = addVspace(o, varargin)
        o = addTable(o, varargin)
        write(o, fid, pg, rep_dir)
        lastIndex = end(o, k, n)
        ns = numSections(p)
    end
end
