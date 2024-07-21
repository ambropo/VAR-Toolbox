function p = extract(o, varargin) % --*-- Unitary tests --*--

% Extract some variables from a database.

% Copyright (C) 2012-2017 Dynare Team
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

useimplicitloops = false;
useregularexpression = false;
usewildcardparameter = false;

p = dseries();

% Get the names of the variables to be extracted from dseries object B.
VariableName_ = {};
for i=1:nargin-1
    VariableName = varargin{i};
    % Implicit loop.
    idArobase = strfind(VariableName,'@');
    if mod(length(idArobase),2)
        error('dseries::extract: (Implicit loops) The number of @ symbols must be even!')
    end
    if ~isempty(idArobase)
        useimplicitloops = true;
    end
    % Regular expression.
    idBracket.open = strfind(VariableName,'[');
    idBracket.close = strfind(VariableName,']');
    if ~isempty(idBracket.open) && ~isempty(idBracket.close)
        if isequal(idBracket.open(1), 1) && isequal(idBracket.close(end), length(VariableName))
            useregularexpression = true;
        end
    end
    % Wildcard parameter.
    if ~useregularexpression
        idStar = strfind(VariableName,'~');
        if ~isempty(idStar)
            usewildcardparameter = true;
            useregularexpression = true;
            VariableName = sprintf('[%s]', VariableName);
            VariableName = strrep(VariableName, '~', '\w*');
        end
    end
    % Check that square brackets are not used, unless extract method is called with a regular expression.
    if ~useregularexpression && ~(isempty(idBracket.open) && isempty(idBracket.close))
        error('dseries::extract: Square brackets are not allowed, unless regexp are used to select variables!')
    end
    if useregularexpression && usewildcardparameter && ~(isempty(idBracket.open) && isempty(idBracket.close))
        error('dseries::extract: Square brackets are not allowed, unless regexp are used to select variables!')
    end
    % Check that square brackets in regular expressions
    if useregularexpression && ~usewildcardparameter && ~isequal(length(idBracket.open),length(idBracket.open))
        error('dseries::extract: (MATLAB/Octave''s regular expressions) Check opening and closing square brackets!')
    end
    % Loops and regular expressions are not compatible
    if useregularexpression && useimplicitloops
        error('dseries::extract: You cannot use implicit loops and regular expressions in the same rule!')
    end
    % Update the list of variables.
    if useimplicitloops
        VariableName_ = build_list_of_variables_with_loops(o.name, idArobase, VariableName, VariableName_);
    elseif useregularexpression
        VariableName_ = build_list_of_variables_with_regexp(o.name, VariableName(2:end-1), usewildcardparameter);
    else
        VariableName_ = varargin(:);
    end
end

% Remove trailing white spaces if any
VariableName_ = strtrim(VariableName_);

% Get indices of the selected variables
idVariableName = NaN(length(VariableName_),1);
for i = 1:length(idVariableName)
    idx = find(strcmp(VariableName_{i},o.name));
    if isempty(idx)
        error(['dseries::extract: Variable ' VariableName_{i} ' is not a member of ' inputname(1) '!'])
    end
    idVariableName(i) = idx;
end

p.data = o.data(:,idVariableName);
p.dates = o.dates;
p.name = o.name(idVariableName);
p.tex = o.tex(idVariableName);
p.ops = o.ops(idVariableName);

%@test:1
%$ % Define a data set.
%$ A = rand(10,24);
%$
%$ % Define names
%$ A_name = {'GDP_1';'GDP_2';'GDP_3'; 'GDP_4'; 'GDP_5'; 'GDP_6'; 'GDP_7'; 'GDP_8'; 'GDP_9'; 'GDP_10'; 'GDP_11'; 'GDP_12'; 'HICP_1';'HICP_2';'HICP_3'; 'HICP_4'; 'HICP_5'; 'HICP_6'; 'HICP_7'; 'HICP_8'; 'HICP_9'; 'HICP_10'; 'HICP_11'; 'HICP_12';};
%$
%$ % Instantiate a time series object.
%$ ts1 = dseries(A,[],A_name,[]);
%$
%$ % Call the tested method.
%$ a = ts1{'GDP_@1,2,3,4,5@'};
%$ b = ts1{'@GDP,HICP@_1'};
%$
%$ % Expected results.
%$ e1.data = A(:,1:5);
%$ e1.nobs = 10;
%$ e1.vobs = 5;
%$ e1.name = {'GDP_1';'GDP_2';'GDP_3'; 'GDP_4'; 'GDP_5'};
%$ e1.freq = 1;
%$ e1.init = dates(1,1);
%$ e2.data = A(:,[1, 13]);
%$ e2.nobs = 10;
%$ e2.vobs = 2;
%$ e2.name = {'GDP_1';'HICP_1'};
%$ e2.freq = 1;
%$ e2.init = dates(1,1);
%$
%$ % Check results.
%$ t(1) = dassert(e1.data,a.data);
%$ t(2) = dassert(e1.nobs,a.nobs);
%$ t(3) = dassert(e1.vobs,a.vobs);
%$ t(4) = dassert(e1.name,a.name);
%$ t(5) = dassert(e1.init,a.init);
%$ t(6) = dassert(e2.data,b.data);
%$ t(7) = dassert(e2.nobs,b.nobs);
%$ t(8) = dassert(e2.vobs,b.vobs);
%$ t(9) = dassert(e2.name,b.name);
%$ t(10) = dassert(e2.init,b.init);
%$ T = all(t);
%@eof:1


%@test:2
%$ % Define a data set.
%$ A = rand(10,24);
%$
%$ % Define names
%$ A_name = {'GDP_1';'GDP_2';'GDP_3'; 'GDP_4'; 'GDP_5'; 'GDP_6'; 'GDP_7'; 'GDP_8'; 'GDP_9'; 'GDP_10'; 'GDP_11'; 'GDP_12'; 'HICP_1';'HICP_2';'HICP_3'; 'HICP_4'; 'HICP_5'; 'HICP_6'; 'HICP_7'; 'HICP_8'; 'HICP_9'; 'HICP_10'; 'HICP_11'; 'HICP_12';};
%$
%$ % Instantiate a time series object.
%$ ts1 = dseries(A,[],A_name,[]);
%$
%$ % Call the tested method.
%$ try
%$   a = ts1{'GDP_@1,2,3,4,55@'};
%$   t = 0;
%$ catch
%$   t = 1;
%$ end
%$
%$ T = all(t);
%@eof:2


%@test:3
%$ % Define a data set.
%$ A = rand(10,24);
%$
%$ % Define names
%$ A_name = {'GDP_1';'GDP_2';'GDP_3'; 'GDP_4'; 'GDP_5'; 'GDP_6'; 'GDP_7'; 'GDP_8'; 'GDP_9'; 'GDP_10'; 'GDP_11'; 'GDP_12'; 'HICP_1';'HICP_2';'HICP_3'; 'HICP_4'; 'HICP_5'; 'HICP_6'; 'HICP_7'; 'HICP_8'; 'HICP_9'; 'HICP_10'; 'HICP_11'; 'HICP_12';};
%$
%$ % Instantiate a time series object.
%$ ts1 = dseries(A,[],A_name,[]);
%$
%$ % Call the tested method.
%$ try
%$   a = ts1{'@GDP,HICP@_@1,2,3,4,5@'};
%$   t = 1;
%$ catch
%$   t = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(a.name,{'GDP_1';'GDP_2';'GDP_3';'GDP_4';'GDP_5';'HICP_1';'HICP_2';'HICP_3';'HICP_4';'HICP_5'});
%$ end
%$
%$ T = all(t);
%@eof:3