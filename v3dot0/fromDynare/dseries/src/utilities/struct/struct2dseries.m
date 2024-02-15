function o = struct2dseries(s)

% Converts structure to dseries object.

% Copyright (C) 2017 Dynare Team
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

missingfields = setdiff({'data', 'dates', 'name', 'tex', 'ops', 'tags'}, fieldnames(s)); 
    
if isempty(missingfields)
    if s.dates.freq==1
        time = s.dates.time(1);
    else
        time = s.dates.time(1,:);
    end
    o = dseries(s.data, dates(s.dates.freq, time), s.name, s.tex);
    o.resetops(s.ops);
    o.resettags(s.tags);
else
    error('Missing field ins structure: %s\n', missingfields)
end