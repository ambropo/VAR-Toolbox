classdef report_data < handle
    % report_data Class to write a page to the report
    %
    % Copyright (C) 2019-2022 Dynare Team
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
        data = ''
        tableAlignRight = false
        tableRowColor = 'white'
        tableRowIndent = 0
        tableNaNSymb = 'NaN'
        tablePrecision = ''
        zeroTol = 1e-6
    end
    properties
        column_names = ''
    end
    methods
        function o = report_data(varargin)
            %function o = report_data(varargin)
            % report_data Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty report_data object
            %                   1 arg   : must be report_data object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [report_data]  report_data object
            %
            % SPECIAL REQUIREMENTS
            %   none
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'report_data'), ...
                    '@report_data.report_data: with one arg you must pass a report_data object');
                o = varargin{1};
                return
            end
            if round(nargin/2) ~= nargin/2
                error('@report_data.report_data: options must be supplied in name/value pairs.');
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
                    error('@report_data.report_data: %s is not a recognized option.', pair{1});
                end
            end
        end
    end
    methods (Hidden = true)
        writeDataForTable(o, fid, precision)
    end
end
