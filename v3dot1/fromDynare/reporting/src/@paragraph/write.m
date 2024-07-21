function write(o, fid)
%function write(o, fid)
% Write Paragraph object
%
% INPUTS
%   o         [paragraph] paragraph object
%   fid       [integer] file id
%
% OUTPUTS
%   o         [paragraph] paragraph object
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

fprintf(fid, '%% Paragraph Object written %s\n', datestr(now));
fprintf(fid, '\\multicolumn{1}{p{\\linewidth}}{%%\n');
if o.cols ~= 1
    bc = '';
    if o.balancedCols
        bc = '*';
    end
    fprintf(fid, '\\begin{multicols%s}{%d}%%\n', bc, o.cols);
end

if ~isempty(o.heading)
    if o.cols ~= 1
        fprintf(fid, '[%s\n]\n', o.heading);
    else
        fprintf(fid, '%s\\newline \\newline\n', o.heading);
    end
end

if o.indent
    fprintf(fid, '\\hspace{4ex}');
end

fprintf(fid, '%s', o.text);

if o.cols ~= 1
    fprintf(fid, '\\end{multicols%s}\n', bc);
end
fprintf(fid, '}\n%% End Paragraph Object\n\n');
end
