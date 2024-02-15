function write(o, fid, pg, sec, row, col, rep_dir)
%function write(o, fid, pg, sec, row, col, rep_dir)
% Write a Table object
%
% INPUTS
%   o         [table]   table object
%   fid       [integer] file id
%   pg        [integer] this page number
%   sec       [integer] this section number
%   row       [integer] this row number
%   col       [integer] this col number
%   rep_dir   [string]  directory containing report.tex
%
% OUTPUTS
%   o   [table] table object
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

tableName = writeTableFile(o, pg, sec, row, col, rep_dir);
fprintf(fid, '\\input{%s}', tableName);
end
