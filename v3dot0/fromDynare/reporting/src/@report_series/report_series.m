classdef report_series < handle
    % report_series Class to write a page to the report
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
    properties (SetAccess = private)
        data = ''                        % The dseries that provides the data for the graph. Default: none.
        graphFanShadeColor = ''          % The shading color to use between a series and the previously-added series in a graph. Useful for making fan charts. Default: empty.
        graphFanShadeOpacity = 50        % The opacity of the color passed in graphFanShadeColor. Default: 50.
        graphLegendName = ''             % The name to display in the legend for this series, passed as valid LATEX (e.g., GDP_{US}, $\alpha$, \color{red}GDP\color{black}). Will be displayed only if the data and showLegend options have been passed. Default: the tex name of the series.
        graphLineColor = 'black'         % Color to use for the series in a graph. See the explanation in shadeColor for how to use colors with reports. Default: `black'
        graphLineStyle = 'solid'         % Line style for this series in a graph. Default: `solid'.
        graphLineWidth = 0.5             % Line width for this series in a graph. Default: 0.5.
        graphShowInLegend = true         % Whether or not to show this series in the legend, given that the showLegend option was passed to addGraph. Default: true.
        graphMarker = ''                 % The Marker to use on this series in a graph. Default: none.
        graphMarkerEdgeColor = ''        % The edge color of the graph marker. See the explanation in shadeColor for how to use colors with reports. Default: graphLineColor.
        graphMarkerFaceColor = ''        % The face color of the graph marker. See the explanation in shadeColor for how to use colors with reports. Default: graphLineColor.
        graphMarkerSize = 1              % The size of the graph marker. Default: 1.
        graphMiscTikzAddPlotOptions = '' % If you are comfortable with PGFPLOTS/TikZ, you can use this option to pass arguments di- rectly to the PGFPLOTS/TikZ addPlots command. (e.g., Instead of passing the marker options above, you can pass a string such as the following to this option: `mark=halfcircle*,mark options={rotate=90,scale=3}'). Specifically to be used for desired PGFPLOTS/TikZ options that have not been incorporated into Dynare Reproting. Default: empty.
        graphHline = {}                  % Use this option to draw a horizontal line at the given value. Default: empty.
        graphVline = dates()             % Use this option to draw a vertical line at a given date. Default: empty.
        graphBar = false                 % Whether or not to display this series as a bar graph as oppsed to the default of displaying it as a line graph. Default: false.
        graphBarColor = 'black'          % The outline color of each bar in the bar graph. Only active if graphBar is passed. Default: `black'.
        graphBarFillColor = 'black'      % The fill color of each bar in the bar graph. Only active if graphBar is passed. Default: `black'.
        graphBarWidth = 2                % The width of each bar in the bar graph. Only active if graphBar is passed. Default: 2.
        tableShowMarkers = false         % In a Table, if true, surround each cell with brackets and color it according to tableNegColor and tablePosColor. No effect for graphs. Default: false.
        tableNegColor = 'red'            % The color to use when marking Table data that is less than zero. Default: `red'
        tablePosColor = 'blue'           % The color to use when marking Table data that is greater than zero. Default: `blue'
        tableMarkerLimit = 1e-4          % For values less than ?1 * tableMarkerLimit, mark the cell with the color denoted by tableNeg- Color. For those greater than tableMarkerLimit, mark the cell with the color denoted by table- PosColor. Default: 1e-4.
        tableSubSectionHeader = ''       % A header for a subsection of the table. No data will be associated with it. It is equivalent to adding an empty series with a name. Default: ''
        tableAlignRight = false          % Whether or not to align the series name to the right of the cell. Default: false.
        tableRowColor = 'white'          % The color that you want the row to be. Predefined values include LightCyan and Gray. Default: white.
        tableRowIndent = 0               % The number of times to indent the name of the series in the table. Used to create subgroups of series. Default: 0.
        tableDataRhs = ''                % A series to be added to the right of the current series. Usefull for displaying aggregate data for a series. e.g if the series is quarterly tableDataRhs could point to the yearly averages of the quarterly series. This would cause quarterly data to be displayed followed by annual data. Default: empty.
        tableNaNSymb = 'NaN'             % Replace NaN values with the text in this option. Default: NaN.
        tablePrecision = ''              % The number of decimal places to report in the table data. Default: the value set by precision.
        zeroTol = 1e-6                   % The zero tolerance. Anything smaller than zeroTol and larger than -zeroTol will be set to zero before being graphed or written to the table. Default: 1e-6.
    end
    methods
        function o = report_series(varargin)
            %function o = report_series(varargin)
            % Report_Series Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty report_series object
            %                   1 arg   : must be report_series object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [report_series]  report_series object
            %
            % SPECIAL REQUIREMENTS
            %   none
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'report_series'), ...
                    '@report_series.report_series: with one arg you must pass a report_series object');
                o = varargin{1};
                return
            end

            if round(nargin/2) ~= nargin/2
                error('@report_series.report_series: options must be supplied in name/value pairs.');
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
                    error('@report_series.report_series: %s is not a recognized option.', pair{1});
                end
            end
            if ~isempty(o.graphLegendName)
                o.data = o.data.tex_rename(o.graphLegendName);
            end
        end
    end
    methods (Hidden = true)
        s = getNameForLegend(o)
        writeSeriesForGraph(o, fid, xrange, series_num)
    end
    methods (Hidden = true)
        writeSeriesForTable(o, fid, dates, precision, ncols, rowcolor)
    end
    methods (Hidden = true)
        tf = isZero(o)
    end
    methods
        dd = getRange(o)
    end
    methods (Access = private)
        s = getTexName(o)
        o = printSeries(o, fid, dser, dates, precision)
        d = setDataToZeroFromZeroTol(o, ds)
        ymax = ymax(o, dd)
        ymin = ymin(o, dd)
    end
end
