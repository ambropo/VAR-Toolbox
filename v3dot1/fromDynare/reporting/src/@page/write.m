function write(o, fid, pg, rep_dir)
%function write(o, fid, pg, rep_dir)
% Write a Page object
%
% INPUTS
%   o              [page]     page object
%   fid            [integer]  file id
%   pg             [integer]  this page number
%   rep_dir        [string]   directory containing report.tex
%
% OUTPUTS
%   o              [page]     page object
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

fprintf(fid, '\n%% Page Number %d written %s\n', pg, datestr(now));
if ~isempty(o.setPageNumber)
    fprintf(fid, '\\setcounter{page}{%d}\n', o.setPageNumber);
end
if o.removeHeaderAndFooter
    fprintf(fid, '\\thispagestyle{empty}\n');
end
if strcmpi(o.orientation, 'landscape')
    fprintf(fid, '\\begin{landscape}\n');
end

for i=1:length(o.footnote)
    fprintf(fid, '\\blfootnote{\\tiny %d. %s}', i, o.footnote{i});
end
fprintf(fid, '\n');

if ~isempty(o.latex)
    dir = [rep_dir '/' o.pageDirName];
    if exist(dir, 'dir') ~= 7
        mkdir(dir);
    end
    pagename = [dir '/page_' num2str(pg) '.tex'];
    [fidp, msg] = fopen(pagename, 'w');
    if fidp == -1
        error(['@page.write: ' msg]);
    end
    fprintf(fidp, '%s', o.latex);
    if fclose(fidp) == -1
        error('@page.write: closing %s\n', pagename);
    end
    fprintf(fid, '\\input{%s}', pagename);
else
    if ~isempty(o.title)
        fprintf(fid, '\\addcontentsline{toc}{subsection}{%s}\n', o.title{1});
    end
    fprintf(fid, '\\begin{tabular}[t]{c}\n');
    for i = 1:length(o.title)
        if isint(o.titleTruncate)
            if length(o.title{i}) > o.titleTruncate
                o.title{i} = o.title{i}(1:o.titleTruncate);
            end
        end
        fprintf(fid, '\\multicolumn{1}{c}{%s %s}\\\\\n', o.titleFormat{i}, o.title{i});
    end

    for i = 1:length(o.sections)
        o.sections{i}.write(fid, pg, i, rep_dir);
    end
    fprintf(fid, '\\end{tabular}\n');
end

if strcmpi(o.orientation, 'landscape')
    fprintf(fid, '\\end{landscape}\n');
end
fprintf(fid, '\\clearpage\n');
fprintf(fid, '%% End Page Object\n\n');
end
