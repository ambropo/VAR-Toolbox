function writeDataForTable(o, fid, precision)
%function writeDataForTable(o, fid, precision)
% Write Table Data
%
% INPUTS
%   o            [report_data]      report_data object
%   fid          [int]              file id
%   precision    [float]            precision with which to print the data
%
%
% OUTPUTS
%   o            [report_data]    report_data object
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2019 Dynare Team
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
assert(ischar(o.tableRowColor), '@report_data.writeDataForTable: tableRowColor must be a string');
assert(isint(o.tableRowIndent) && o.tableRowIndent >= 0, ...
       '@report_data.writeDataForTable: tableRowIndent must be an integer >= 0');
assert(islogical(o.tableAlignRight), '@report_data.writeDataForTable: tableAlignRight must be true or false');
assert(ischar(o.tableNaNSymb), '@report_data.writeDataForTable: tableNaNSymb must be a string');

if ~isempty(o.tablePrecision)
    assert(isint(o.tablePrecision) && o.tablePrecision >= 0, ...
           '@report_data.writeDataForTable: tablePrecision must be a non-negative integer');
    precision = o.tablePrecision;
end
rounding = 10^precision;

%% Write Output
fprintf(fid, '%% Table Data (report_data)\n');
[nrows, ncols] = size(o.data);
for i = 1:nrows
    fprintf(fid, '\\rowcolor{%s}', o.tableRowColor);
    if o.tableAlignRight
        fprintf(fid, '\\multicolumn{1}{r}{');
    end
    if o.tableRowIndent == 0
        fprintf(fid, '\\noindent ');
    else
        for j=1:o.tableRowIndent
            fprintf(fid,'\\indent ');
        end
    end
    if o.tableAlignRight
        fprintf(fid, '}');
    end
    for j = 1:ncols
        val = o.data(i,j);
        if iscell(val)
            val = val{:};
        end
        if isnan(val)
            val = o.tableNaNSymb;
            dataString = '%s';
        elseif isnumeric(val)
            dataString = sprintf('%%.%df', precision);
            if val < o.zeroTol && val > -o.zeroTol
                val = 0;
            end
            % Use round half away from zero rounding
            val = round(val*rounding)/rounding;
            if isnan(val)
                val = o.tableNaNSymb;
                dataString = '%s';
            end
        else
            dataString = '%s';
            val = regexprep(val, '_', '\\_');
        end
        fprintf(fid, dataString, val);
        if j ~= ncols
            fprintf(fid, ' & ');
        else
            fprintf(fid, '\\\\%%\n');
        end
    end
end
end
