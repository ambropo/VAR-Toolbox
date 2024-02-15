classdef report_graph < handle
    % report_graph Class
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
        series = {}
    end
    properties (SetAccess = private)
        title = ''                       % With one entry (a STRING), the title of the page. With more than one entry (a CELL_ARRAY_STRINGS), the title and subtitle(s) of the page. Values passed must be valid LATEX code (e.g., % must be \%). Default: none.
        titleFormat = ''                 % The format to use for the graph title. Unlike other titleFormat options, due to a constraint of TikZ, this format applies to the title and subtitles. Default: TikZ default.
        titleFontSize = 'normalsize'     % The font size for title. Default: normalsize.
        ylabel = ''                      % The x-axis label. Default: none.
        xlabel = ''                      % The y-axis label. Default: none.
        axisShape = 'box'                % The shape the axis should have. `box' means that there is an axis line to the left, right, bottom, and top of the graphed line(s). ?L??? means that there is an axis to the left and bottom of the graphed line(s). Default: `box'.
        graphDirName = 'tmpRepDir'       % The name of the folder in which to store this figure. Default: tmpRepDir.
        graphName = ''                   % The name to use when saving this figure. Default: something of the form graph_pg1_sec2_row1_col3.tex.
        data = ''                        % The dseries that provides the data for the graph. Default: none.
        seriesToUse = ''                 % The names of the series contained in the dseries provided to the data option. If empty, use all series provided to data option. Default: empty.
        xrange = ''                      % The boundary on the x-axis to display in the graph. Default: all.
        xAxisTight = true                % Use a tight x axis. If false, uses PGFPLOTS/TikZ enlarge x limits to choose appropriate axis size. Default: true.
        yrange = ''                      % The boundary on the y-axis to display in the graph, represented as a NUMERICAL_VECTOR of size 2, with the first entry less than the second entry. Default: all.
        yAxisTight = false               % Use a tight y axis. If false, uses PGFPLOTS/TikZ enlarge y limits to choose appropriate axis size. Default: false.
        shade = ''                       % The date range showing the portion of the graph that should be shaded. Default: none.
        shadeColor = 'green'             % The color to use in the shaded portion of the graph. All valid color strings defined for use by PGFPLOTS/TikZ are valid. Furthermore, You can use combinations of these colors. For example, if you wanted a color that is 20% green and 80% purple, you could pass the string 'green!20!purple'. You can also use RGB colors, following the syntax: `rgb,255:red,231;green,84;blue,121' which corresponds to the RGB color (231;84;121). More examples are available in the section 4.7.5 of the PGFPLOTS/TikZ manual, revision 1.10. Default: `green'
        shadeOpacity = 20                % The opacity of the shaded area, must be in [0,100]. Default: 20.
        showGrid = true                  % Whether or not to display the major grid on the graph. Default: true.
        showLegend = false               % Whether or not to display the legend. Unless you use the graphLegendName option, the name displayed in the legend is the tex name associated with the dseries. You can modify this tex name by using tex_rename. Default: false.
        legendAt = []                    % The coordinates for the legend location. If this option is passed, it overrides the legendLocation option. Must be of size 2. Default: empty.
        showLegendBox = false            % Whether or not to display a box around the legend. Default: false.
        legendLocation = 'south east'    % Where to place the legend in the graph. Default: `south east'.
        legendOrientation = 'horizontal' % Orientation of the legend. Default: `horizontal'.
        legendFontSize = 'tiny'          % The font size for legend entries. Default: tiny.
        showZeroline = false             % Display a solid black line at y = 0. Default: false.
        zeroLineColor = 'black'          % The color to use for the zero line. Only used if showZeroLine is true. See the explanation in shadeColor for how to use colors with reports. Default: `black'.
        xTicks = []                      % Used only in conjunction with xTickLabels, this option denotes the numerical position of the label along the x-axis. The positions begin at 1. Default: the indices associated with the first and last dates of the dseries and, if passed, the index associated with the first date of the shade option.
        xTickLabels = {}                 % The labels to be mapped to the ticks provided by xTicks. Default: the first and last dates of the dseries and, if passed, the date first date of the shade option.
        xTickLabelRotation = 0           % The amount to rotate the x tick labels by. Default: 0.
        xTickLabelAnchor = 'east'        % Where to anchor the x tick label. Default: `east'.
        yTickLabelScaled = true          % Determines whether or not there is a common scaling factor for the y axis. Default: true.
        yTickLabelPrecision = 0          % The precision with which to report the yTickLabel. Default: 0.
        yTickLabelFixed = true           % Round the y tick labels to a fixed number of decimal places, given by yTickLabelPrecision. Default: true.
        yTickLabelZeroFill = true        % Whether or not to fill missing precision spots with zeros. Default: true.
        tickFontSize = 'normalsize'      % The font size for x- and y-axis tick labels. Default: normalsize.
        width = 6                        % The width of the graph, in inches. Default: 6.0.
        height = 4.5                     % The height of the graph, in inches. Default: 4.5.
        miscTikzPictureOptions = ''      % If you are comfortable with PGFPLOTS/TikZ, you can use this option to pass arguments directly to the PGFPLOTS/TikZ tikzpicture environment command. (e.g., to scale the graph in the x and y dimensions, you can pass following to this option: ?xscale=2.5, yscale=0.5?). Specifically to be used for desired ``PGFPLOTS/TikZoptionsthathavenotbeenincorporatedinto Dynare Reporting. Default: empty.
        miscTikzAxisOptions = ''         % If you are comfortable with PGFPLOTS/TikZ, you can use this option to pass arguments directly to the PGFPLOTS/TikZ axis environment command. Specifically to be used for desired PGFPLOTS/ TikZ options that have not been incorporated into Dynare Reporting. Default: empty.
        writeCSV = false                 % Whether or not to write a CSV file with only the plotted data. The file will be saved in the directory specified by graphDirName with the same base name as specified by graphName with the ending .csv. Default: false.
    end
    methods
        function o = report_graph(varargin)
            %function o = report_graph(varargin)
            % report_graph class constructor
            %
            % INPUTS
            %   varargin        0 args  : empty report_graph object
            %                   1 arg   : must be report_graph object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for
            %                   options)
            %
            % OUTPUTS
            %   o   [report_graph] report_graph object
            %
            % SPECIAL REQUIREMENTS
            %   none
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'report_graph'), ...
                    'With one arg to the report_graph constructor, you must pass a report_graph object');
                o = varargin{1};
                return
            elseif nargin > 1
                if round(nargin/2) ~= nargin/2
                    error('@report_graph.report_graph: options must be supplied in name/value pairs.');
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
                        error('@report_graph.report_graph: %s is not a recognized option.', pair{1});
                    end
                end
            end

            % Check options provided by user
            if ischar(o.title)
                o.title = {o.title};
            end
            assert(iscellstr(o.title), '@report_graph.report_graph: title must be a cell array of string(s)');
            assert(ischar(o.titleFormat), '@report_graph.report_graph: titleFormat file must be a string');
            assert(ischar(o.xlabel), '@report_graph.report_graph: xlabel file must be a string');
            assert(ischar(o.ylabel), '@report_graph.report_graph: ylabel file must be a string');
            assert(ischar(o.miscTikzPictureOptions), '@report_graph.report_graph: miscTikzPictureOptions file must be a string');
            assert(ischar(o.miscTikzAxisOptions), '@report_graph.report_graph: miscTikzAxisOptions file must be a string');
            assert(ischar(o.graphName), '@report_graph.report_graph: graphName must be a string');
            assert(ischar(o.graphDirName), '@report_graph.report_graph: graphDirName must be a string');
            assert(islogical(o.showGrid), '@report_graph.report_graph: showGrid must be either true or false');
            assert(islogical(o.xAxisTight), '@report_graph.report_graph: xAxisTight must be either true or false');
            assert(islogical(o.yAxisTight), '@report_graph.report_graph: yAxisTight must be either true or false');
            assert(islogical(o.showLegend), '@report_graph.report_graph: showLegend must be either true or false');
            assert(isempty(o.legendAt) || (isfloat(o.legendAt) && length(o.legendAt)==2), ...
                '@report_graph.report_graph: legendAt must be a double array of size two');
            assert(islogical(o.showLegendBox), '@report_graph.report_graph: showLegendBox must be either true or false');
            assert(islogical(o.showZeroline), '@report_graph.report_graph: showZeroline must be either true or false');
            assert(isfloat(o.shadeOpacity) && length(o.shadeOpacity)==1 && ...
                o.shadeOpacity >= 0 && o.shadeOpacity <= 100, ...
                '@report_graph.report_graph: o.shadeOpacity must be a real in [0 100]');
            assert(isfloat(o.width), '@report_graph.report_graph: o.width must be a real number');
            assert(isfloat(o.height), '@report_graph.report_graph: o.height must be a real number');
            assert(isfloat(o.xTickLabelRotation), '@report_graph.report_graph: o.xTickLabelRotation must be a real number');
            assert(ischar(o.xTickLabelAnchor), '@report_graph.report_graph: xTickLabelAnchor must be a string');
            assert(isint(o.yTickLabelPrecision), '@report_graph.report_graph: o.yTickLabelPrecision must be an integer');
            assert(islogical(o.yTickLabelFixed), '@report_graph.report_graph: yTickLabelFixed must be either true or false');
            assert(islogical(o.yTickLabelZeroFill), '@report_graph.report_graph: yTickLabelZeroFill must be either true or false');
            assert(islogical(o.yTickLabelScaled), '@report_graph.report_graph: yTickLabelScaled must be either true or false');
            assert(islogical(o.writeCSV), '@report_graph.report_graph: writeCSV must be either true or false');
            assert(ischar(o.shadeColor), '@report_graph.report_graph: shadeColor must be a string');
            assert(ischar(o.zeroLineColor), '@report_graph.report_graph: zeroLineColor must be a string');
            assert(any(strcmp(o.axisShape, {'box', 'L'})), ['@report_graph.report_graph: axisShape ' ...
                'must be one of ''box'' or ''L''']);
            valid_legend_locations = ...
                {'south west','south east','north west','north east','outer north east'};
            assert(any(strcmp(o.legendLocation, valid_legend_locations)), ...
                ['@report_graph.report_graph: legendLocation must be one of ' addCommasToCellStr(valid_legend_locations)]);

            valid_font_sizes = {'tiny', 'scriptsize', 'footnotesize', 'small', ...
                'normalsize', 'large', 'Large', 'LARGE', 'huge', 'Huge'};
            assert(any(strcmp(o.legendFontSize, valid_font_sizes)), ...
                ['@report_graph.report_graph: legendFontSize must be one of ' addCommasToCellStr(valid_font_sizes)]);
            assert(any(strcmp(o.titleFontSize, valid_font_sizes)), ...
                ['@report_graph.report_graph: titleFontSize must be one of ' addCommasToCellStr(valid_font_sizes)]);
            assert(any(strcmp(o.tickFontSize, valid_font_sizes)), ...
                ['@report_graph.report_graph: tickFontSize must be one of ' addCommasToCellStr(valid_font_sizes)]);

            valid_legend_orientations = {'vertical', 'horizontal'};
            assert(any(strcmp(o.legendOrientation, valid_legend_orientations)), ...
                ['@report_graph.report_graph: legendOrientation must be one of ' addCommasToCellStr(valid_legend_orientations)]);

            assert(isempty(o.shade) || (isdates(o.shade) && o.shade.ndat >= 2), ...
                ['@report_graph.report_graph: shade is specified as a dates range, e.g. ' ...
                '''dates(''1999q1''):dates(''1999q3'')''.']);
            assert(isempty(o.xrange) || (isdates(o.xrange) && o.xrange.ndat >= 2), ...
                ['@report_graph.report_graph: xrange is specified as a dates range, e.g. ' ...
                '''dates(''1999q1''):dates(''1999q3'')''.']);
            assert(isempty(o.yrange) || (isfloat(o.yrange) && length(o.yrange) == 2 && ...
                o.yrange(1) < o.yrange(2)), ...
                ['@report_graph.report_graph: yrange is specified an array with two float entries, ' ...
                'the lower bound and upper bound.']);
            assert(isempty(o.data) || isdseries(o.data), ['@report_graph.report_graph: data must ' ...
                'be a dseries']);
            assert(isempty(o.seriesToUse) || iscellstr(o.seriesToUse), ['@report_graph.report_graph: ' ...
                'seriesToUse must be a cell array of string(s)']);
            assert(isempty(o.xTicks) || isfloat(o.xTicks),...
                '@report_graph.report_graph: xTicks must be a numerical array');
            assert(iscellstr(o.xTickLabels) || (ischar(o.xTickLabels) && strcmpi(o.xTickLabels, 'ALL')), ...
                ['@report_graph.report_graph: xTickLabels must be a cell array of strings or ' ...
                'equivalent to the string ''ALL''']);
            if ~isempty(o.xTickLabels)
                assert((ischar(o.xTickLabels) && strcmpi(o.xTickLabels, 'ALL')) || ...
                    ~isempty(o.xTicks), ['@report_graph.report_graph: if you set xTickLabels and ' ...
                    'it''s not equal to ''ALL'', you must set xTicks']);
            end
            if ~isempty(o.xTicks)
                assert(~isempty(o.xTickLabels), '@report_graph.report_graph: if you set xTicks, you must set xTickLabels');
            end

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
            o.seriesToUse = '';
            o.data = '';
        end
    end
    methods (Hidden = true)
        o = addSeries(o, varargin)
        write(o, fid, pg, sec, row, col, rep_dir)
    end
    methods (Access = private)
        % Methods defined in separate files
        lastIndex = end(o, k, n)
        graphName = writeGraphFile(o, pg, sec, row, col, rep_dir)
    end
end
