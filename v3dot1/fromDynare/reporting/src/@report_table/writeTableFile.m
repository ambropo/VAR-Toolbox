function tableName = writeTableFile(o, pg, sec, row, col, rep_dir)
%function tableName = writeTableFile(o, pg, sec, row, col, rep_dir)
% Write a Report_Table object
%
% INPUTS
%   o         [report_table]  report_table object
%   pg        [integer]       this page number
%   sec       [integer]       this section number
%   row       [integer]       this row number
%   col       [integer]       this col number
%   rep_dir   [string]        directory containing report.tex
%
% OUTPUTS
%   tableName   [string]    name of table written
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2013-2019 Dynare Team
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
is_data_table = ~isempty(o.table_data);
if ne == 0 && ~is_data_table
    warning('@report_table.write: no series to plot, returning');
    return
end
if is_data_table
    ne = size(o.table_data{1}.data,2);
end
if exist([rep_dir '/' o.tableDirName], 'dir') ~= 7
    mkdir([rep_dir '/' o.tableDirName]);
end
if isempty(o.tableName)
    tableName = sprintf([o.tableDirName '/table_pg%d_sec%d_row%d_col%d.tex'], pg, sec, row, col);
else
    tableName = [o.tableDirName '/' o.tableName];
end

[fid, msg] = fopen([rep_dir '/' tableName], 'w');
if fid == -1
    error(['@report_table.writeTableFile: ' msg]);
end

fprintf(fid, '%% Report_Table Object written %s\n', datestr(now));
fprintf(fid, '\\begin{tabular}[t]{l}\n');
fprintf(fid, '\\setlength{\\parindent}{6pt}\n');
fprintf(fid, '\\setlength{\\tabcolsep}{4pt}\n');

%number of left-hand columns, 1 until we allow the user to group data,
% e.g.: GDP Europe
%         GDP France
%         GDP Germany
% this example would be two lh columns, with GDP Europe spanning both
nlhc = 1;
if ~is_data_table
    fprintf(fid, '\\begin{tabular}{@{}l');
    if isempty(o.range)
        Dates = getMaxRange(o.series);
        o.range = {Dates};
    else
        Dates = o.range{1};
    end
    ndates = Dates.ndat;

    for i=1:ndates
        fprintf(fid, 'r');
        if o.showVlines
            fprintf(fid, '|');
        elseif o.vlineAfterEndOfPeriod && subperiod(Dates(i)) == Dates(i).freq
            fprintf(fid, '|');
        elseif ~isempty(o.vlineAfter)
            for j=1:length(o.vlineAfter)
                if Dates(i) == o.vlineAfter{j}
                    fprintf(fid, '|');
                end
            end
        end
    end
    years = unique(year(Dates));
    if length(o.range) > 1
        rhscols = strings(o.range{2});
        if o.range{2}.freq == 1
            rhscols = strrep(rhscols, 'Y', '');
        end
    else
        rhscols = {};
    end
    for i=1:length(rhscols)
        fprintf(fid, 'r');
        if o.showVlines
            fprintf(fid, '|');
        end
    end
    nrhc = length(rhscols);
    ncols = ndates+nlhc+nrhc;
    fprintf(fid, '@{}}%%\n');
    for i=1:length(o.title)
        if ~isempty(o.title{i})
            fprintf(fid, '\\multicolumn{%d}{c}{%s %s}\\\\\n', ...
                ncols, o.titleFormat{i}, o.title{i});
        end
    end
    fprintf(fid, '\\toprule%%\n');

    % Column Headers
    thdr = num2cell(years, size(years, 1));
    if Dates.freq == 1
        for i=1:size(thdr, 1)
            fprintf(fid, ' & %d', thdr{i, 1});
        end
        for i=1:length(rhscols)
            fprintf(fid, ' & %s', rhscols{i});
        end
    else
        thdr{1, 2} = subperiod(Dates)';
        if size(thdr, 1) > 1
            for i=2:size(thdr, 1)
                split = find(thdr{i-1, 2} == Dates.freq, 1, 'first');
                assert(~isempty(split), '@report_table.writeTableFile: Shouldn''t arrive here');
                thdr{i, 2} = thdr{i-1, 2}(split+1:end);
                thdr{i-1, 2} = thdr{i-1, 2}(1:split);
            end
        end
        for i=1:size(thdr, 1)
            fprintf(fid, ' & \\multicolumn{%d}{c}{%d}', size(thdr{i,2}, 2), thdr{i,1});
        end
        for i=1:length(rhscols)
            fprintf(fid, ' & %s', rhscols{i});
        end
        fprintf(fid, '\\\\\n');
        switch Dates.freq
            case 4
                sep = 'Q';
            case 12
                sep = 'M';
            case 52
                sep = 'W';
            otherwise
                error('@report_table.writeTableFile: Invalid frequency.');
        end
        for i=1:size(thdr, 1)
            period = thdr{i, 2};
            for j=1:size(period, 2)
                fprintf(fid, ' & \\multicolumn{1}{c');
                if o.showVlines
                    fprintf(fid, '|');
                elseif o.vlineAfterEndOfPeriod && j == size(period, 2)
                    fprintf(fid, '|');
                elseif ~isempty(o.vlineAfter)
                    for k=1:length(o.vlineAfter)
                        if year(o.vlineAfter{k}) == thdr{i} && ...
                                subperiod(o.vlineAfter{k}) == period(j)
                            fprintf(fid, '|');
                        end
                    end
                end
                fprintf(fid, '}{%s%d}', sep, period(j));
            end
        end
    end
else
    fprintf(fid, '\\begin{tabular}{');
    if o.showVlines
        fprintf(fid, '|');
    end
    if ~isempty(o.table_data{1}.column_names) && ne ~= length(o.table_data{1}.column_names)
        error(['@report_table.writeTableFile: when writing a data table and passing the ' ...
            '`column_names` option, it must have the same number of elements as the ' ...
            'number of columns in the data']);
    end
    for i = 1:ne
        if isempty(o.table_data{1}.column_names) ||isempty(o.table_data{1}.column_names{i})
            fprintf(fid, 'l');
        else
            fprintf(fid, 'r');
        end
        if o.showVlines
            fprintf(fid, '|');
        end
    end
    fprintf(fid,'}');
end

% Write Report_Table Data
if ~is_data_table
    fprintf(fid, '\\\\[-2pt]%%\n');
    fprintf(fid, '\\hline%%\n');
    fprintf(fid, '%%\n');
    if o.writeCSV
        csvseries = dseries();
    end
    for i=1:ne
        o.series{i}.writeSeriesForTable(fid, o.range, o.precision, ncols, o.highlightRows{mod(i,length(o.highlightRows))+1});
        if o.writeCSV
            if isempty(o.series{i}.tableSubSectionHeader)
                csvseries = [csvseries ...
                    o.series{i}.data(Dates).set_names([...
                    num2str(i) '_' ...
                    o.series{i}.data.name{:}])];
            end
        end
        if o.showHlines
            fprintf(fid, '\\hline\n');
        end
    end
    if o.writeCSV
        csvseries.save(strrep(o.tableName, '.tex', ''), 'csv');
    end
else
    if ~isempty(o.table_data{1}.column_names)
        fprintf(fid, '%%\n');
        fprintf(fid, '\\hline%%\n');
        fprintf(fid, '%%\n');
    end
    for i = 1:ne
        if ~isempty(o.table_data{1}.column_names) && ~isempty(o.table_data{1}.column_names{i})
            fprintf(fid, '%s', o.table_data{1}.column_names{i});
        end
        if i ~= ne
            fprintf(fid, ' & ');
        end
    end
    fprintf(fid, '\\\\[-2pt]%%\n');
    fprintf(fid, '\\hline%%\n');
    o.table_data{1}.writeDataForTable(fid, o.precision);
end
fprintf(fid, '\\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\setlength{\\parindent}{0pt}\n \\par \\medskip\n\n');
fprintf(fid, '%% End Report_Table Object\n');
if fclose(fid) == -1
    error('@report_table.writeTableFile: closing %s\n', o.filename);
end
end
