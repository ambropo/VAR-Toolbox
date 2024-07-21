classdef report_table < handle
    % report_table Class
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
        titleFormatDefalut = {'\large'}
    end
    properties (Access = private)
        series = {}
        table_data = {}               % The table data
        % Not documented
        preamble = {''}
        afterward = {''}
    end
    properties (SetAccess = private)
        tableDirName = 'tmpRepDir'    % The name of the folder in which to store this table. Default: tmpRepDir.
        tableName = ''                % The name to use when saving this table. Default: something of the form table_pg1_sec2_row1_col3.tex.
        title = {''}                  % Table Title. Default: none.
        titleFormat = ''              % A string representing the valid LATEX markup to use on title. The number of cell array entries must be equal to that of the title option if you do not want to use the default value for the title (and subtitles). Default: \large\bfseries.
        showHlines = false            % Whether or not to show horizontal lines separating the rows. Default: false.
        showVlines = false            %
        vlineAfter = ''               % Show a vertical line after the specified date (or dates if a cell array of dates is passed). Default: empty.
        vlineAfterEndOfPeriod = false % Show a vertical line after the end of every period (i.e. after every year, after the fourth quarter, etc.). Default: false.
        data = ''                     % The dseries that provides the data for the table. Default: none.
        seriesToUse = ''              % The names of the series contained in the dseries provided to the data option. If empty, use all series provided to data option. Default: empty.
        range = {}                    % The date range of the data to be displayed. Default: all.
        precision = 1                 % The number of decimal places to report in the table data (rounding done via the round half away from zero method). Default: 1.
        writeCSV = false              % Whether or not to write a CSV file containing the data displayed in the table. The file will be saved in the directory specified by tableDirName with the same base name as specified by tableName with the ending .csv. Default: false.
        highlightRows = {''}          % A cell array containing the colors to use for row highlighting. See shadeColor for how to use colors with reports. Highlighting for a specific row can be overridden by using the tableRowColor option to addSeries. Default: empty.
    end
    methods
        function o = report_table(varargin)
            %function o = report_table(varargin)
            % Report_Table Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty report_table object
            %                   1 arg   : must be report_table object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [report_table]  report_table object
            %
            % SPECIAL REQUIREMENTS
            %   none
            o.titleFormat = o.titleFormatDefalut;
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'report_table'), ...
                    'With one arg to the Report_Table constructor, you must pass a report_table object');
                o = varargin{1};
                return
            end

            if round(nargin/2) ~= nargin/2
                error('Options to Report_Table constructor must be supplied in name/value pairs.');
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
                    error('%s is not a recognized option to the Report_Table constructor.', pair{1});
                end
            end

            if ~iscell(o.range)
                o.range = {o.range};
            end

            if isdates(o.vlineAfter)
                o.vlineAfter = {o.vlineAfter};
            end

            % Check options provided by user
            if ischar(o.title)
                o.title = {o.title};
            end

            if ischar(o.titleFormat)
                o.titleFormat = {o.titleFormat};
            end
            if length(o.title) ~= length(o.titleFormat)
                o.titleFormat = repmat(o.titleFormatDefalut, 1, length(o.title));
            end
            assert(islogical(o.showHlines), '@report_table.report_table: showHlines must be true or false');
            assert(islogical(o.showVlines), '@report_table.report_table: showVlines must be true or false');
            assert(isint(o.precision) && o.precision >= 0, '@report_table.report_table: precision must be a non-negative integer');
            assert(isempty(o.range) || length(o.range) <=2 && allCellsAreDatesRange(o.range), ...
                ['@report_table.report_table: range is specified as a dates range, e.g. ' ...
                '''dates(''1999q1''):dates(''1999q3'')''.']);
            assert(isempty(o.data) || isdseries(o.data), ...
                '@report_table.report_table: data must be a dseries');
            assert(isempty(o.seriesToUse) || iscellstr(o.seriesToUse), ...
                '@report_table.report_table: seriesToUse must be a cell array of string(s)');
            assert(isempty(o.vlineAfter) || allCellsAreDates(o.vlineAfter), ...
                '@report_table.report_table: vlineAfter must be a dates');
            if o.showVlines
                o.vlineAfter = '';
            end
            assert(islogical(o.vlineAfterEndOfPeriod), ...
                '@report_table.report_table: vlineAfterEndOfPeriod must be true or false');
            assert(iscellstr(o.title), ...
                '@report_table.report_table: title must be a cell array of string(s)');
            assert(iscellstr(o.titleFormat), ...
                '@report_table.report_table: titleFormat must be a cell array of string(s)');
            assert(ischar(o.tableName), '@report_table.report_table: tableName must be a string');
            assert(ischar(o.tableDirName), '@report_table.report_table: tableDirName must be a string');
            assert(islogical(o.writeCSV), '@report_table.report_table: writeCSV must be either true or false');
            assert(iscellstr(o.highlightRows), '@report_table.report_table: highlightRowsmust be a cell string');

            % using o.seriesToUse, create series objects and put them in o.series
            if ~isempty(o.data)
                if isempty(o.seriesToUse)
                    for i=1:o.data.vobs
                        o.series{end+1} = report_series('data', o.data{o.data.name{i}});
                    end
                else
                    for i=1:length(o.seriesToUse)
                        o.series{end+1} = report_series('data', o.data{o.seriesToUse{i}});
                    end
                end
            end
            o.data = '';
            o.seriesToUse = '';
        end
    end
    methods (Hidden = true)
        o = addData(o, varargin)
        o = addSeries(o, varargin)
        write(o, fid, pg, sec, row, col, rep_dir)
    end
    methods (Access = private)
        o = writeTableFile(o, pg, sec, row, col, rep_dir)
    end
end

function tf = allCellsAreDatesRange(dcell)
%function tf = allCellsAreDatesRange(dcell)
% Determines if all the elements of dcell are a range of dates
%
% INPUTS
%   dcell     cell of dates
%
% OUTPUTS
%   tf        true if every entry of dcell is a range of dates
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2014-2015 Dynare Team
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

assert(iscell(dcell));
tf = true;
for i=1:length(dcell)
    if ~(isdates(dcell{i}) && dcell{i}.ndat >= 2)
        tf = false;
        return
    end
end
end

function tf = allCellsAreDates(dcell)
%function tf = allCellsAreDates(dcell)
% Determines if all the elements of dcell are dates objects
%
% INPUTS
%   dcell     cell of dates objects
%
% OUTPUTS
%   tf        true if every entry of dcell is a dates object
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2014-2015 Dynare Team
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

assert(iscell(dcell));
tf = true;
for i=1:length(dcell)
    if ~isdates(dcell{i})
        tf = false;
        return
    end
end
end
