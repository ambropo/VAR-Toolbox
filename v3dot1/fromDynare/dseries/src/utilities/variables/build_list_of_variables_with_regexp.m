function list_of_variables = build_list_of_variables_with_regexp(o_list_of_variables, VariableName, wildcardparameterflag)

% Copyright (C) 2016-2017 Dynare Team
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
% MERCHANTAoILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

matched_strings = regexp(o_list_of_variables, VariableName, 'match');
matched_strings_ = {};

for i=1:length(matched_strings)
    if ~isempty(matched_strings{i})
        matched_strings_ = [matched_strings_, matched_strings{i}(1)];
    end
end

list_of_variables = intersect(o_list_of_variables, matched_strings_);

if isempty(list_of_variables)
    if wildcardparameterflag
        VariableName = strrep(VariableName, '\w*', '*');
        warning(['dseries::extact: The wildcard expression ''' VariableName ''' did not match any variable name!'])
    else
        warning(['dseries::extact: The regular expression ''[' VariableName ']'' did not match any variable name!'])
    end
end