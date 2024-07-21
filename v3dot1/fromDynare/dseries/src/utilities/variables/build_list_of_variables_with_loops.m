function list_of_variables = build_list_of_variables_with_loops(o_list_of_variables, idArobase, VariableName, list_of_variables)

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

checknames = ~isempty(o_list_of_variables);

NumberOfImplicitLoops = .5*length(idArobase);

idComma = cell(NumberOfImplicitLoops,1);

expressions = cell(NumberOfImplicitLoops,1);

for i=0:NumberOfImplicitLoops-1
    idComma(i+1) = { strfind(VariableName(idArobase(2*i+1)+1:idArobase(2*i+2)-1),',') };
    expressions(i+1) = { VariableName(idArobase(2*i+1)+1:idArobase(2*i+2)-1) };
end

if any(cellfun(@isempty,idComma))
    error('dseries::loops: (Implicit loops) Wrong syntax!')
end

switch NumberOfImplicitLoops
  case 1
    expression = expressions{1};
    idVariables_ = [];
    while ~isempty(expression)
        [token, expression] = strtok(expression,',');
        candidate = [VariableName(1:idArobase(1)-1), token, VariableName(idArobase(2)+1:end)];
        if checknames
            id = find(strcmp(candidate,o_list_of_variables));
            if isempty(id)
                error(['dseries::loops: (Implicit loops) Variable ''' candidate ''' does not exist in dseries object ''' inputname(1) '''!'])
            else
                idVariables_ = [idVariables_; id];
            end
        else
            list_of_variables = vertcat(list_of_variables, candidate);
        end
    end
    if checknames
        VariableName = o_list_of_variables(idVariables_);
    end
  case 2
    idVariables_ = [];
    expression_1 = expressions{1};
    while ~isempty(expression_1)
        [token_1, expression_1] = strtok(expression_1,',');
        expression_2 = expressions{2};
        while ~isempty(expression_2)
            [token_2, expression_2] = strtok(expression_2,',');
            candidate = [VariableName(1:idArobase(1)-1), token_1, VariableName(idArobase(2)+1:idArobase(3)-1),  token_2, VariableName(idArobase(4)+1:end)];
            if checknames
                id = find(strcmp(candidate,o_list_of_variables));
                if isempty(id)
                    error(['dseries::loops: (Implicit loops) Variable ''' candidate ''' does not exist in dseries object ''' inputname(1) '''!'])
                else
                    idVariables_ = [idVariables_; id];
                end
            else
                list_of_variables = vertcat(list_of_variables, candidate);
            end
        end
    end
    if checknames
        VariableName = o_list_of_variables(idVariables_);
    end
  otherwise
    error('dseries::loops: (Implicit loops) Cannot unroll more than two implicit loops!')
end

if checknames
    list_of_variables = vertcat(list_of_variables, VariableName);
end