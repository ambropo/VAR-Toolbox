function o = write(o, fid)
%function o = write(o, fid)
% Write a Vspace object
%
% INPUTS
%   o           [vspace]   vspace object
%   fid         [integer]  file id
%
% OUTPUTS
%   o           [vspace]   vspace object
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

fprintf(fid, repmat(' \\par \\medskip ', 1, o.number));
if o.hline > 0
    fprintf(fid, ['\\\\\n' repmat('\\noindent\\makebox[\\linewidth]{\\rule{\\linewidth}{0.4pt}}\\\\', 1, o.hline)]);
end
end
