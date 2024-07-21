function o = write(o)
%function o = write(o)
% Write Report object
%
% INPUTS
%   o     [report]  report object
%
% OUTPUTS
%   o     [report]  report object
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

if exist(o.directory, 'dir') ~= 7
    mkdir(o.directory);
end
if exist([o.directory '/' o.reportDirName], 'dir') ~= 7
    mkdir([o.directory '/' o.reportDirName]);
end
idx = strfind(o.fileName, '.tex');
if isempty(idx) || ~strcmp(o.fileName(idx:end), '.tex')
    preamble_file_name = [o.reportDirName '/' o.fileName '_preamble.tex'];
    document_file_name = [o.reportDirName '/' o.fileName '_document.tex'];
    page_file_name_root = [o.reportDirName '/' o.fileName '_pg'];
    o.fileName = [o.fileName '.tex'];
else
    preamble_file_name = [o.reportDirName '/' o.fileName(1:idx-1) '_preamble.tex'];
    document_file_name = [o.reportDirName '/' o.fileName(1:idx-1) '_document.tex'];
    page_file_name_root = [o.reportDirName '/' o.fileName(1:idx-1) '_pg'];
end

%% Create preamble
[fid_preamble, msg] = fopen([o.directory '/' preamble_file_name], 'w');
if fid_preamble == -1
    error(['@report.write: ' msg]);
end

fprintf(fid_preamble, '%% Report Object written %s\n', datestr(now));
fprintf(fid_preamble, '\\documentclass[11pt,notitlepage]{article}\n');

fprintf(fid_preamble, '\\usepackage[%spaper,margin=%f%s', o.paper, o.margin, o.marginUnit);
if strcmpi(o.orientation, 'landscape')
    fprintf(fid_preamble, ',landscape');
end
fprintf(fid_preamble, ']{geometry}\n');
fprintf(fid_preamble, '\\usepackage{pdflscape, booktabs, pgfplots, colortbl, adjustbox, multicol}\n');
fprintf(fid_preamble, '\\pgfplotsset{compat=1.5.1}');
fprintf(fid_preamble, ['\\makeatletter\n' ...
              '\\def\\blfootnote{\\gdef\\@thefnmark{}\\@footnotetext}\n' ...
              '\\makeatother\n']);

if isoctave && isempty(regexpi(computer, '.*apple.*', 'once'))
    fprintf(fid_preamble, '\\usepackage[T1]{fontenc}\n');
    fprintf(fid_preamble, '\\usepackage[utf8x]{inputenc}\n');
end
if ispc || ismac
    fprintf(fid_preamble, '\\usepgfplotslibrary{fillbetween}\n');
end
fprintf(fid_preamble, '\\definecolor{LightCyan}{rgb}{0.88,1,1}\n');
fprintf(fid_preamble, '\\definecolor{Gray}{gray}{0.9}\n');

if o.showDate
    fprintf(fid_preamble, '\\usepackage{fancyhdr, datetime}\n');
    fprintf(fid_preamble, '\\newdateformat{reportdate}{\\THEDAY\\ \\shortmonthname\\ \\THEYEAR}\n');
    fprintf(fid_preamble, '\\pagestyle{fancy}\n');
    fprintf(fid_preamble, '\\renewcommand{\\headrulewidth}{0pt}\n');
    fprintf(fid_preamble, '\\renewcommand{\\footrulewidth}{0.5pt}\n');
    fprintf(fid_preamble, '\\rfoot{\\scriptsize\\reportdate\\today\\ -- \\currenttime}\n');
end

% May not need these.....
fprintf(fid_preamble, '\\renewcommand{\\textfraction}{0.05}\n');
fprintf(fid_preamble, '\\renewcommand{\\topfraction}{0.8}\n');
fprintf(fid_preamble, '\\renewcommand{\\bottomfraction}{0.8}\n');
fprintf(fid_preamble, '\\setlength{\\parindent}{0in}\n');
fprintf(fid_preamble, '\\setlength{\\tabcolsep}{1em}\n');
fprintf(fid_preamble, '\\newlength\\sectionheight\n');
if ~isempty(o.header)
    fprintf(fid_preamble, '%s\n', o.header);
end

%% Write body of document
[fid_document, msg] = fopen([o.directory '/' document_file_name], 'w');
if fid_document == -1
    error(['@report.write: ' msg]);
end

if ~isempty(o.title)
    if o.showDate
        fprintf(fid_preamble, '\\newdateformat{reportdatelong}{\\THEDAY\\ \\monthname\\ \\THEYEAR}\n');
    end
    fprintf(fid_document, '\\title{\\huge\\bfseries %s\\vspace{-1em}}\n\\author{}\n', o.title);
    if o.showDate
        fprintf(fid_document, '\\date{\\reportdatelong\\today}\n');
    else
        fprintf(fid_document, '\\date{}\n');
    end
    fprintf(fid_document, '\\maketitle\n');
end

if o.maketoc
    if o.showDate
        fprintf(fid_preamble, '\\rhead{}\n\\lhead{}\n');
    end
    fprintf(fid_document, '\\tableofcontents\n');
end

if ~isempty(o.title) || o.maketoc
    fprintf(fid_document, '\\clearpage\n');
end

if isunix && ~ismac
    fprintf(fid_document, '\\pgfdeclarelayer{axis background}\n');
    fprintf(fid_document, '\\pgfdeclarelayer{axis lines}\n');
    fprintf(fid_document, '\\pgfsetlayers{axis background,axis lines,main}\n');
end
fprintf(fid_document, '\\pgfplotsset{tick scale binop={\\times},\ntrim axis left}\n');
fprintf(fid_document, '\\centering\n');

for i = 1:length(o.pages)
    if o.showOutput
        fprintf(1, 'Writing Page: %d\n', i);
    end
    page_file_name = [page_file_name_root num2str(i) '.tex'];
    [fid_pg, msg] = fopen([o.directory '/' page_file_name], 'w');
    if fid_pg == -1
        error(['@report.write: ' msg]);
    end
    o.pages{i}.write(fid_pg, i, o.directory);
    status = fclose(fid_pg);
    if status == -1
        error('@report.write: closing %s\n', o.fileName);
    end
    fprintf(fid_document, '\\input{%s}\n', page_file_name);
end

%% Close preamble, document
fprintf(fid_preamble, '\\begin{document}\n');
status = fclose(fid_preamble);
if status == -1
    error('@report.write: closing %s\n', preamble_file_name);
end

status = fclose(fid_document);
if status == -1
    error('@report.write: closing %s\n', document_file_name);
end

%% Create report comprised of preamble and document
[fid, msg] = fopen([o.directory '/' o.fileName], 'w');
if fid == -1
    error(['@report.write: ' msg]);
end
fprintf(fid, '\\input{%s}\n\\input{%s}\n', ...
    preamble_file_name, document_file_name);
fprintf(fid, '\\end{document}\n');
status = fclose(fid);
if status == -1
    error('@report.write: closing %s\n', o.fileName);
end

if o.showOutput
    disp('Finished Writing Report!');
end
end
