function writeSeriesForGraph(o, fid, xrange, series_num)
%function writeSeriesForGraph(o, fid, xrange, series_num)
% Print a TikZ line
%
% INPUTS
%   o          [report_series]    series object
%   xrange     [dates]            range of x values for line
%   series_num [int]              the number of this series in the total number of series passed to this graph
%
% OUTPUTS
%   NONE
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

%% Validate options provided by user
if isempty(o.graphVline) && isempty(o.graphHline)
    assert(~isempty(o.data) && isdseries(o.data), ['@report_series.writeSeriesForGraph: must ' ...
                        'provide data as a dseries']);
end

assert(ischar(o.graphMiscTikzAddPlotOptions), ['@report_series.writeSeriesForGraph: ' ...
                    'graphMiscTikzAddPlotOptions file must be a string']);
assert(islogical(o.graphShowInLegend), ['@report_series.writeSeriesForGraph: ' ...
                    'graphShowInLegend must be either true or false']);

% Line
assert(ischar(o.graphLineColor), '@report_series.writeSeriesForGraph: graphLineColor must be a string');
assert(ischar(o.graphLineStyle), '@report_series.writeSeriesForGraph: graphLineStyle must be a string');
assert(isfloat(o.graphLineWidth) && o.graphLineWidth > 0, ...
       '@report_series.writeSeriesForGraph: graphLineWidth must be a positive number');

% Bar
assert(islogical(o.graphBar), '@report_series.writeSeriesForGraph: graphBar must be either true or false');
assert(ischar(o.graphBarColor), '@report_series.writeSeriesForGraph: graphBarColor must be a string');
assert(ischar(o.graphBarFillColor), '@report_series.writeSeriesForGraph: graphBarFillColor must be a string');
assert(isfloat(o.graphBarWidth) && o.graphBarWidth > 0, ...
       '@report_series.writeSeriesForGraph: graphbarWidth must be a positive number');

% GraphMarker
valid_graphMarker = {'x', '+', '-', '|', 'o', 'asterisk', 'star', '10-pointed star', 'oplus', ...
                    'oplus*', 'otimes', 'otimes*', 'square', 'square*', 'triangle', 'triangle*', 'diamond', ...
                    'diamond*', 'halfdiamond*', 'halfsquare*', 'halfsquare right*', ...
                    'halfsquare left*','Mercedes star','Mercedes star flipped','halfcircle',...
                    'halfcircle*','pentagon','pentagon star'};
assert(isempty(o.graphMarker) || any(strcmp(o.graphMarker, valid_graphMarker)), ...
       ['@report_series.writeSeriesForGraph: graphMarker must be one of ' addCommasToCellStr(valid_graphMarker)]);

assert(ischar(o.graphMarkerEdgeColor), '@report_series.writeSeriesForGraph: graphMarkerEdgeColor must be a string');
assert(ischar(o.graphMarkerFaceColor), '@report_series.writeSeriesForGraph: graphMarkerFaceColor must be a string');
assert(isfloat(o.graphMarkerSize) && o.graphMarkerSize > 0, ...
       '@report_series.writeSeriesForGraph: graphMarkerSize must be a positive number');

% Marker & Line
assert(~(strcmp(o.graphLineStyle, 'none') && isempty(o.graphMarker)), ['@report_series.writeSeriesForGraph: ' ...
                    'you must provide at least one of graphLineStyle and graphMarker']);

% Validate graphVline
assert(isempty(o.graphVline) || (isdates(o.graphVline) && o.graphVline.ndat == 1), ...
       '@report_series.writeSeriesForGraph: graphVline must be a dates of size one');
assert(isempty(o.graphHline) || isnumeric(o.graphHline), ...
       '@report_series.writeSeriesForGraph: graphHline must a single numeric value');

% Zero tolerance
assert(isfloat(o.zeroTol), '@report_series.write: zeroTol must be a float');

% Fan Chart
assert(ischar(o.graphFanShadeColor), '@report_series.writeSeriesForGraph: graphFanShadeColor must be a string');
assert(isint(o.graphFanShadeOpacity), '@report_series.writeSeriesForGraph: graphFanShadeOpacity must be an int');

%% graphVline && graphHline
if ~isempty(o.graphVline)
    fprintf(fid, '%%Vertical Line\n\\begin{pgfonlayer}{axis lines}\n\\draw');
    writeLineOptions(o, fid, series_num);
    stringsdd = strings(xrange);
    x = find(strcmpi(date2string(o.graphVline), stringsdd));
    fprintf(fid, ['(axis cs:%d,\\pgfkeysvalueof{/pgfplots/ymin}) -- (axis ' ...
                  'cs:%d,\\pgfkeysvalueof{/pgfplots/ymax});\n\\end{pgfonlayer}\n'], ...
            x, x);
end
if ~isempty(o.graphHline)
    fprintf(fid, '%%Horizontal Line\n\\begin{pgfonlayer}{axis lines}\n\\addplot');
    writeLineOptions(o, fid, series_num);
    fprintf(fid, ['coordinates {(\\pgfkeysvalueof{/pgfplots/xmin},%f)' ...
                  '(\\pgfkeysvalueof{/pgfplots/xmax},%f)};\n\\end{pgfonlayer}\n'], ...
            o.graphHline, o.graphHline);
end
if ~isempty(o.graphVline) || ~isempty(o.graphHline)
    % return since the code below assumes that o.data exists
    return
end

%%
if isempty(xrange) || all(xrange == o.data.dates)
    ds = o.data;
else
    ds = o.data(xrange);
end

thedata = setDataToZeroFromZeroTol(o, ds);
fprintf(fid, '%%series %s\n\\addplot', o.data.name{:});
writeLineOptions(o, fid, series_num);
fprintf(fid,'\ntable[row sep=crcr]{\nx y\\\\\n');
for i=1:ds.dates.ndat
    if ~isnan(thedata(i))
        fprintf(fid, '%d %f\\\\\n', i, thedata(i));
    end
end
fprintf(fid,'};\n');

% For Fan charts
if ispc || ismac
    if ~isempty(o.graphFanShadeColor)
        assert(isint(series_num) && series_num > 1, ['@report_series.writeSeriesForGraph: can only add '...
                            'graphFanShadeColor and graphFanShadeOpacity starting from the ' ...
                            'second series in the graph']);
        fprintf(fid, '\\addplot[%s!%d, forget plot] fill between[of=%d and %d];\n', ...
                o.graphFanShadeColor, o.graphFanShadeOpacity, series_num, series_num - 1);
    end
end
end

function writeLineOptions(o, fid, series_num)
if o.graphBar
    fprintf(fid, '[ybar,ybar legend,color=%s,fill=%s,line width=%fpt',...
            o.graphBarColor, o.graphBarFillColor, o.graphBarWidth);
else
    fprintf(fid, '[color=%s,%s,line width=%fpt,line join=round',...
            o.graphLineColor, o.graphLineStyle, o.graphLineWidth);

    if ~isempty(o.graphMarker)
        if isempty(o.graphMarkerEdgeColor)
            o.graphMarkerEdgeColor = o.graphLineColor;
        end
        if isempty(o.graphMarkerFaceColor)
            o.graphMarkerFaceColor = o.graphLineColor;
        end
        fprintf(fid, ',mark=%s,mark size=%f,every mark/.append style={draw=%s,fill=%s}',...
                o.graphMarker,o.graphMarkerSize,o.graphMarkerEdgeColor,o.graphMarkerFaceColor);
    end
end
if ~isempty(o.graphMiscTikzAddPlotOptions)
    fprintf(fid, ',%s', o.graphMiscTikzAddPlotOptions);
end
if isunix && ~ismac
    fprintf(fid,']');
else
    fprintf(fid,',name path=%d]', series_num);
end
end
