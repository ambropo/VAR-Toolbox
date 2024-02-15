function o = printSeries(o, fid, dser, dates, precision)
%function printSeries(o, fid, dser, dates, precision)
% function to print a row of data, contained in dser
%
% INPUTS
%   fid          [int]              file id
%   dser         [string]           name of data series to be printed
%   dates        [dates]            dates for report_series slice
%   precision    [float]            precision with which to print the data
%
%
% OUTPUTS
%   o            [report_series]    report_series object
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

dataString = sprintf('%%.%df', precision);
precision  = 10^precision;

data = dser(dates);
data = setDataToZeroFromZeroTol(o, data);
for i=1:size(data,1)
    fprintf(fid, '&');
    if o.tableShowMarkers
        if data(i) < -o.tableMarkerLimit
            fprintf(fid, '\\color{%s}', o.tableNegColor);
        elseif data(i) > o.tableMarkerLimit
            fprintf(fid, '\\color{%s}', o.tablePosColor);
        end
        fprintf(fid, '[');
    end
    % Use round half away from zero rounding
    output = round(data(i)*precision)/precision;
    if isnan(output)
        fprintf(fid, '%s', o.tableNaNSymb);
    else
        fprintf(fid, dataString, output);
    end

    if o.tableShowMarkers
        fprintf(fid, ']');
    end
end
end
