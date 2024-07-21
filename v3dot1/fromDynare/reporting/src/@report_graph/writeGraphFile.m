function graphName = writeGraphFile(o, pg, sec, row, col, rep_dir)
%function graphName = writeGraphFile(o, pg, sec, row, col, rep_dir)
% Write the tikz file that contains the graph
%
% INPUTS
%   o         [report_graph]   report_graph object
%   pg        [integer] this page number
%   sec       [integer] this section number
%   row       [integer] this row number
%   col       [integer] this col number
%   rep_dir   [string]  directory containing report.tex
%
% OUTPUTS
%   graphName   [string] name of graph written
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2013-2020 Dynare Team
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

ne = length(o.series);
if ne < 1
    warning('@report_graph.writeGraphFile: no series to plot, returning');
    return
end

if exist([rep_dir '/' o.graphDirName], 'dir') ~= 7
    mkdir([rep_dir '/' o.graphDirName]);
end
if isempty(o.graphName)
    graphName = sprintf([o.graphDirName '/graph_pg%d_sec%d_row%d_col%d.tex'], pg, sec, row, col);
else
    graphName = [o.graphDirName '/' o.graphName];
end

[fid, msg] = fopen([rep_dir '/' graphName], 'w');
if fid == -1
    error(['@report_graph.writeGraphFile: ' msg]);
end

fprintf(fid, '%% Graph Object written %s\n', datestr(now));
fprintf(fid, '\\begin{tikzpicture}[baseline');
if ~isempty(o.miscTikzPictureOptions)
    fprintf(fid, ',%s', o.miscTikzPictureOptions);
end
fprintf(fid, ']');

if isempty(o.xrange)
    dd = getMaxRange(o.series);
else
    dd = o.xrange;
end

if ispc || ismac
    fprintf(fid, '\\begin{axis}[%%\nset layers,\n');
else
    fprintf(fid, '\\begin{axis}[%%\n');
end
% set tick labels
if isempty(o.xTickLabels)
    stringsdd = strings(dd);
    if ~isempty(o.shade)
        x1 = find(strcmpi(date2string(o.shade(1)), stringsdd));
        x2 = find(strcmpi(date2string(o.shade(end)), stringsdd));
        if x1 == 1
            x = [1 x2 dd.ndat];
            xTickLabels = [stringsdd(1) stringsdd(x2) stringsdd(end)];
        elseif x2 == dd.ndat
            x = [1 x1 dd.ndat];
            xTickLabels = [stringsdd(1) stringsdd(x1) stringsdd(end)];
        else
            x = [1 x1 x2 dd.ndat];
            xTickLabels = [stringsdd(1) stringsdd(x1) stringsdd(x2) stringsdd(end)];
        end
    else
        x = [1 dd.ndat];
        xTickLabels = [stringsdd(1) stringsdd(end)];
    end
    fprintf(fid, 'xminorticks=true,\nyminorticks=true,\n');
elseif iscell(o.xTickLabels)
    fprintf(fid,'minor xtick,\n');
    x = o.xTicks;
    xTickLabels = o.xTickLabels;
else
    x = [1:dd.ndat];
    xTickLabels = strings(dd);
end
fprintf(fid, 'xticklabels={');
xlen = length(x);
for i = 1:xlen
    fprintf(fid,'%s,',lower(xTickLabels{i}));
end
fprintf(fid, '},\nxtick={');
for i = 1:xlen
    fprintf(fid, '%d',x(i));
    if i ~= length(x)
        fprintf(fid,',');
    end
end
fprintf(fid, '},\ny tick label style={\n/pgf/number format/.cd,\n');
if o.yTickLabelFixed
    fprintf(fid, 'fixed,\n');
end
if o.yTickLabelZeroFill
    fprintf(fid, 'zerofill,\n');
end
fprintf(fid, 'precision=%d,\n/tikz/.cd\n},\n', o.yTickLabelPrecision);
fprintf(fid, 'x tick label style={rotate=%f', o.xTickLabelRotation);
if o.xTickLabelRotation ~= 0
    fprintf(fid, ',anchor=%s', o.xTickLabelAnchor);
end
fprintf(fid, ['},\n',...
              'width=%fin,\n'...
              'height=%fin,\n'...
              'scale only axis,\n'...
              'unbounded coords=jump,\n'], o.width, o.height);

if strcmpi(o.axisShape, 'box')
    fprintf(fid, 'axis lines=box,\n');
elseif strcmpi(o.axisShape, 'L')
    fprintf(fid, 'axis x line=bottom,\naxis y line=left,\n');
end

if ~isempty(o.title{1})
    fprintf(fid, 'title style={align=center');
    if ~isempty(o.titleFormat)
        fprintf(fid, ',font=%s', o.titleFormat);
    end
    fprintf(fid, '},\ntitle=');
    nt = length(o.title);
    for i=1:nt
        fprintf(fid, '%s', o.title{i});
        if i ~= nt
            fprintf(fid, '\\\\');
        end
    end
    fprintf(fid, ',\n');
end

if o.xAxisTight
    fprintf(fid, 'enlarge x limits=false,\n');
else
    fprintf(fid, 'enlarge x limits=true,\n');
end

if isempty(o.yrange)
    nonzeroseries = false;
    for i=1:ne
        if ~o.series{i}.isZero()
            nonzeroseries = true;
            break;
        end
    end
    if ~nonzeroseries
        fprintf(fid, 'ymin=-1,\nymax=1,\n');
    end
    if o.yAxisTight
        fprintf(fid, 'enlarge y limits=false,\n');
    else
        fprintf(fid, 'enlarge y limits=true,\n');
    end
else
    fprintf(fid, 'ymin=%f,\nymax=%f,\n',o.yrange(1),o.yrange(2));
end
fprintf(fid, 'xmin = 1,\nxmax = %d,\n', length(dd));

if o.showLegend
    fprintf(fid, 'legend style={');
    if ~o.showLegendBox
        fprintf(fid, 'draw=none,');
    end
    fprintf(fid, 'font=\\%s,', o.legendFontSize);
    if strcmp(o.legendOrientation, 'horizontal')
        fprintf(fid,'legend columns=-1,');
    end
    if isempty(o.legendAt)
        fprintf(fid, '},\nlegend pos=%s,\n', o.legendLocation);
    else
        fprintf(fid, 'at={(%f,%f)}},\n',o.legendAt(1),o.legendAt(2));
    end
end

fprintf(fid, 'tick label style={font=\\%s},\n', o.tickFontSize);

if o.showGrid
    fprintf(fid, 'xmajorgrids=true,\nymajorgrids=true,\n');
end

if ~isempty(o.xlabel)
    fprintf(fid, 'xlabel=%s,\n', o.xlabel);
end

if ~isempty(o.ylabel)
    fprintf(fid, 'ylabel=%s,\n', o.ylabel);
end

if ~o.yTickLabelScaled
    fprintf(fid, 'scaled y ticks = false,\n');
end

if ~isempty(o.miscTikzAxisOptions)
    fprintf(fid, '%s', o.miscTikzAxisOptions);
end
fprintf(fid, ']\n');

if ~isempty(o.title{1})
    fprintf(fid, '\\pgfplotsset{every axis title/.append style={}}=[font=\\%s]\n', o.titleFontSize);
end

if ~isempty(o.shade)
    fprintf(fid, '%%shading\n');
    stringsdd = strings(dd);
    x1 = find(strcmpi(date2string(o.shade(1)), stringsdd));
    x2 = find(strcmpi(date2string(o.shade(end)), stringsdd));
    assert(~isempty(x1) && ~isempty(x2), ['@report_graph.writeGraphFile: either ' ...
                        date2string(o.shade(1)) ' or ' date2string(o.shade(end)) ' is not in the date ' ...
                        'range of data selected.']);
    if x1 == 1
        fprintf(fid,['\\begin{pgfonlayer}{axis background}\n\\fill[%s!%f]\n(axis ' ...
                     'cs:\\pgfkeysvalueof{/pgfplots/xmin},\\pgfkeysvalueof{/pgfplots/ymin})\nrectangle (axis ' ...
                     'cs:%f,\\pgfkeysvalueof{/pgfplots/ymax});\n\\end{pgfonlayer}\n'], ...
                o.shadeColor, o.shadeOpacity, x2);
    elseif x2 == dd.ndat
        fprintf(fid,['\\begin{pgfonlayer}{axis background}\n\\fill[%s!%f]\n(axis ' ...
                     'cs:%f,\\pgfkeysvalueof{/pgfplots/ymin})\nrectangle (axis ' ...
                     'cs:\\pgfkeysvalueof{/pgfplots/xmax},\\pgfkeysvalueof{/' ...
                     'pgfplots/ymax});\n\\end{pgfonlayer}\n'], ...
                o.shadeColor, o.shadeOpacity, x1);
    else
        fprintf(fid,['\\begin{pgfonlayer}{axis background}\n\\fill[%s!%f]\n(axis ' ...
                     'cs:%f,\\pgfkeysvalueof{/pgfplots/ymin})\nrectangle (axis ' ...
                     'cs:%f,\\pgfkeysvalueof{/pgfplots/ymax});\n\\end{pgfonlayer}\n'], ...
                o.shadeColor, o.shadeOpacity, x1, x2);
    end
end

if o.showZeroline
    fprintf(fid, '%%zeroline\n\\addplot[%s,line width=.5,forget plot] coordinates {(1,0)(%d,0)};\n', ...
            o.zeroLineColor, dd.ndat);
end

if o.writeCSV
    csvseries = dseries();
end

if isunix && ~ismac
    for i=1:ne
        isfan = ~isempty(o.series{i}.graphFanShadeColor);
        if isfan
            break
        end
    end
    if isfan
        data = dseries();
        for i=1:ne
            tmp = o.series{i}.data;
            tmp = tmp.set_names(int2str(i));
            data = [data tmp];
        end

        if isempty(dd) || all(dd == data.dates)
            ds = data;
        else
            ds = data(dd);
        end

        for i=2:ne
            tmp = ds{i} - ds{i-1};
            idx = find(tmp.data ~= 0);
            assert(~isempty(idx), ...
                   'Problem creating fan area for data provided. Please check your data.');
            split = ds(ds.dates(idx));
        end
        idx = find(ds.dates == split.dates(1));
        for i=2:ne
            fprintf(fid, '\\addplot[fill=%s!%d, draw=none, forget plot] coordinates {',...
                    o.series{i}.graphFanShadeColor, o.series{i}.graphFanShadeOpacity);
            for j=idx-1:ds.dates.ndat
                fprintf(fid, '(%d, %f) ', j, ds{i-1}(ds.dates(j),1).data);
            end
            for j=ds.dates.ndat:-1:idx-1
                fprintf(fid, '(%d, %f) ', j, ds{i}(ds.dates(j),1).data);
            end
            fprintf(fid, '} \\closedcycle;\n');
        end
    end
end

for i=1:ne
    o.series{i}.writeSeriesForGraph(fid, dd, i);
    if o.writeCSV
        csvseries = [csvseries ...
            o.series{i}.data(dd).set_names([...
            o.series{i}.data.name{:} '_' ...
            o.series{i}.graphLegendName '_' ...
            o.series{i}.graphLineColor '_' ...
            o.series{i}.graphLineStyle '_' ...
            num2str(o.series{i}.graphLineWidth) '_' ...
            o.series{i}.graphMarker '_' ...
            o.series{i}.graphMarkerEdgeColor '_' ...
            o.series{i}.graphMarkerFaceColor '_' ...
            num2str(o.series{i}.graphMarkerSize)]) ...
            ];
    end
    if o.showLegend
        le = o.series{i}.getNameForLegend();
        if ~isempty(le)
            fprintf(fid, '\\addlegendentry{%s}\n', le);
        end
    end
end
if o.writeCSV
    csvseries.save(strrep(o.graphName, '.tex', ''), 'csv');
end
fprintf(fid, '\\end{axis}\n\\end{tikzpicture}%%');
if fclose(fid) == -1
    error('@report_graph.writeGraphFile: closing %s\n', o.filename);
end
end
