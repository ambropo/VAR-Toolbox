function str = addCommasToCellStr(cs)
%function ncs = addCommasToCellStr(cs)
% Add commas between entries of cell string and return a sting
%
% INPUTS
%   cs [Cell Arrays of Strings]  Cell string in which to intersperse commas
%
% OUTPUTS
%   str [string]                 cs with commas interspersed
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2016 Dynare Team
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

assert(iscellstr(cs), 'addCommasToCellStr: cs should be a cell array of strings.');

str = '';
for i=1:length(cs)
    if i < length(cs)
        str = [str cs{i} ', '];
    else
        str = [str cs{i}];
    end
end
end