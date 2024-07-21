function write(o, fid, pg, sec, rep_dir)
%function write(o, fid, pg, sec, rep_dir)
% Write Section object
%
% INPUTS
%   o         [section] section object
%   fid       [integer] file id
%   pg        [integer] this page number
%   sec       [integer] this section number
%   rep_dir   [string]  directory containing report.tex
%
% OUTPUTS
%   o         [section] section object
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

fprintf(fid, '%% Section Object written %s\n', datestr(now));
if isempty(o.elements)
    warning(['reporting:section.write(): trying to print a section ' ...
             'with no elements. Perhaps you forgot to overwrite the report object.']);
    return
end

if ~isempty(o.height)
    fprintf(fid, '\\setlength\\sectionheight{%s}%%\n', o.height);
end
fprintf(fid, '\\maxsizebox{\\linewidth}{');
if isempty(o.height)
    fprintf(fid, '!');
else
    fprintf(fid, '\\sectionheight');
end
fprintf(fid, '}{%%\n');
fprintf(fid, '\\begin{tabular}[t]{');
for i=1:o.cols
    if ~isa(o.elements{1}, 'paragraph')
        % if one element is a paragraph, they all are
        % due to check in add*.m functions
        fprintf(fid, 'l');
    else
        fprintf(fid, 'c');
    end
end
fprintf(fid, '}\n');

ne = numElements(o);
row = 1;
col = 1;
for i=1:ne
    if isa(o.elements{i}, 'vspace')
        o.elements{i}.write(fid);
        fprintf(fid, '\\\\\n');
        if col ~= o.cols
            fprintf(fid, '\\end{tabular}}\\\\\n');
            fprintf(fid, '%% End Section Object\n\n');
            return
        end
    else
        if isa(o.elements{i}, 'paragraph')
            o.elements{i}.write(fid);
        else
            o.elements{i}.write(fid, pg, sec, row, col, rep_dir);
        end
        if col ~= o.cols
            fprintf(fid, ' & ');
            col = col + 1;
        else
            fprintf(fid, '\\\\\n');
            row = row + 1;
            col = 1;
        end
    end
end
fprintf(fid, '\\end{tabular}}\\\\\n');
fprintf(fid, '%% End Section Object\n\n');
end
