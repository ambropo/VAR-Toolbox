classdef report < handle
    % report Class
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
        pages = {}
    end
    properties (SetAccess = private)
        directory = '.'             % Directory in which to write/compile the report. Default: '.'
        title = ''                  % Report Title. Default: none.
        orientation = 'portrait'    % Paper orientation: Default: `portrait'.
        paper = 'a4'                % Paper size. Default: `a4'.
        margin = 2.5                % The margin size. Default: 2.5.
        marginUnit = 'cm'           % Units associated with the margin. Default: `cm'.
        fileName = 'report'         % The file name to use when saving this report. Default: report.tex.
        showDate = true             % Display the date and time when the report was compiled. Default: true.
        compiler = ''               % The full path to the LATEX compiler on your system
        showOutput = true           % Print report creation progress to screen. Shows you the page number as it is created and as it is written. This is useful to see where a potential error occurs in report creation. Default: true.
        header = ''                 % The valid LATEX code to be included in the report before \begin{document}. Default: empty.
        reportDirName = 'tmpRepDir' % The name of the folder in which to store the component parts of the report (preamble, document, end). Default: tmpRepDir.
        maketoc = false             % Whether or not to make a table of contents. Default: false.
    end
    methods
        function o = report(varargin)
            %function o = report(varargin)
            % Report Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty report object
            %                   1 arg   : must be report object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [report]  report object
            %
            % SPECIAL REQUIREMENTS
            %   none
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'report'), ...
                    '@report.report: with one arg, you must pass a report object');
                o = varargin{1};
                return
            end

            if round(nargin/2) ~= nargin/2
                error('@report.report: options must be supplied in name/value pairs');
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
                    error('@report.report: %s is not a recognized option.', pair{1});
                end
            end

            % Check options provided by user
            assert(ischar(o.directory), '@report.report: directory must be a string');
            assert(ischar(o.title), '@report.report: title must be a string');
            assert(ischar(o.fileName), '@report.report: fileName must be a string');
            assert(ischar(o.compiler), '@report.report: compiler file must be a string');
            assert(islogical(o.showDate), '@report.report: showDate must be either true or false');
            assert(islogical(o.showOutput), '@report.report: showOutput must be either true or false');
            assert(isfloat(o.margin) && o.margin > 0, '@report.report: margin must be a float > 0.');
            assert(ischar(o.header), '@report.report: header must be a string');
            assert(ischar(o.reportDirName), '@report.report: reportDirName must be a string');
            valid_margin_unit = {'cm', 'in'};
            assert(any(strcmp(o.marginUnit, valid_margin_unit)), ...
                ['@report.report: marginUnit must be one of ' addCommasToCellStr(valid_margin_unit)]);

            valid_paper = {'a4', 'letter'};
            assert(any(strcmp(o.paper, valid_paper)), ...
                ['@report.report: paper must be one of ' addCommasToCellStr(valid_paper)]);

            valid_orientation = {'portrait', 'landscape'};
            assert(any(strcmp(o.orientation, valid_orientation)), ...
                ['@report.report: orientation must be one of ' addCommasToCellStr(valid_orientation)]);
            assert(islogical(o.maketoc), '@report.report: maketock must be logical');
        end
        o = addPage(o, varargin)
        o = addSection(o, varargin)
        o = addGraph(o, varargin)
        o = addTable(o, varargin)
        o = addVspace(o, varargin)
        o = addParagraph(o, varargin)
        o = addSeries(o, varargin)
        o = addData(o, varargin)
        o = compile(o, varargin)
        o = write(o)
    end
    methods (Hidden = true)
        n = numPages(o)
    end
end
