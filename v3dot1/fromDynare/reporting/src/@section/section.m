classdef section < handle
    % section Class
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
    properties (Access = private)
        elements = {}
    end
    properties (SetAccess = private)
        cols = 1    % The number of columns in the section. Default: 1.
        height = '' % A string to be used with the \sectionheight LATEX command. Default: '!'
    end
    methods
        function o = section(varargin)
            %function o = section(varargin)
            % Section Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty section object
            %                   1 arg   : must be section object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [section]  section object
            %
            % SPECIAL REQUIREMENTS
            %   none
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'section'), ...
                    'With one arg to Section constructor, you must pass a section object');
                o = varargin{1};
                return
            end

            if round(nargin/2) ~= nargin/2
                error('@section.section: options must be supplied in name/value pairs.');
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
                    error('@section.section: %s is not a recognized option.', pair{1});
                end
            end

            % Check options provided by user
            assert(isint(o.cols), '@section.section: cols must be an integer');
            assert(isempty(o.height) || ischar(o.height), ...
                '@section.section: cols must be a string');
        end
    end
    methods (Hidden = true)
         o = addGraph(o, varargin)
         o = addParagraph(o, varargin)
         o = addTable(o, varargin)
         o = addVspace(o, varargin)
         lastIndex = end(o, k, n)
         n = numElements(o)
         write(o, fid, pg, sec, rep_dir)
    end
end
