function from(varargin)   % --*-- Unitary tests --*--

% Copyright (C) 2014-2018 Dynare Team
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

lvarargin = lower(varargin);

to_id = strmatch('to',lvarargin);
do_id = strmatch('do',lvarargin);

if isempty(to_id) || isempty(do_id)
    error(get_error_message_0())
end

if do_id<to_id
    msg = sprinf('dseries::from: Wrong syntax! The TO keyword must preceed the DO keyword.\n');
    error(get_error_message_0(msg))
end

if ~isdate(varargin{1})
    % The first argument is not a string formatted date. Test if this argument refers to a dates object
    % in the caller workspace.
    try
        d1 = evalin('caller', varargin{1});
        if ~isdates(d1)
            error(['dseries::from: Variable ' varargin{1} ' is not a dates object!'])
        end
    catch
        error(['dseries::from: Variable ' varargin{1} ' is unknown!'])
    end
    if ~exist('d1')
        msg = sprintf('dseries::from: Wrong syntax! The FROM statement must be followed by a string formatted date.\n');
        error(get_error_message_0(msg))
    end
else
    d1 = dates(varargin{1}); % First date
end

if ~isequal(to_id,2)
    msg = sprintf('dseries::from: Wrong syntax! The first dates object must be immediately followed by the TO keyword.\n');
    error(get_error_message_0(msg))
end

if ~isdate(varargin{3})
    % The third argument is not a string formatted date. Test if this argument refers to a dates object
    % in the caller workspace.
    try
        d2 = evalin('caller', varargin{3});
        if ~isdates(d2)
            error(['dseries::from: Variable ' varargin{3} ' is not a dates object!'])
        end
    catch
        error(['dseries::from: Variable ' varargin{3} ' is unknown!'])
    end
    if ~exist('d2')
        msg = sprintf('dseries::from: Wrong syntax! The TO keyword must be followed by a second dates object.\n');
        error(get_error_message_0(msg))
    end
else
    d2 = dates(varargin{3}); % Last date
end

if d1>d2
    error('dseries::from: The first date must preceed the second one!')
end

if ~isequal(do_id,4)
    msg = sprintf('dseries::from: Wrong syntax! The second dates object must be immediately followed by the DO keyword.\n');
    error(get_error_message_0(msg))
end

% Build the recursive expression.
EXPRESSION = char([varargin{5:end}]);

% Check that the expression is an assignment
equal_id = strfind(EXPRESSION,'=');
if isempty(equal_id)
    error('dseries::from: Wrong syntax! The expression following the DO keyword must be an assignment (missing equal symbol).')
end

% Issue ann error message if the user attempts to do more than one assignment.
if ~isequal(length(equal_id),1)
    error('dseries::from: Not yet implemented! Only one assignment is allowed in the FROM-TO-DO statement.')
end

% Get all the variables involved in the recursive expression.
variables = unique(regexpi(EXPRESSION, '\w*\(t\)|\w*\(t\-\d\)|\w*\(t\+\d\)|\w*\.\w*\(t\)|\w*\.\w*\(t\-\d\)|\w*\.\w*\(t\+\d\)','match'));

% Copy EXPRESSION in expression. In the next loop we will remove all indexed variables from expression.
expression = EXPRESSION;

% Build an incidence table (max lag/lead for each variable)
%
% Column 1: Name of the variable.
% Column 2: Maximum lag order.
% Column 3: Equal to 1 if the variable appears at the current period, 0 otherwise.
% Column 4: Maximum lead order.
% Column 5: Vector of effective lag orders.
% Column 6: Vector of effective lead orders.
%
% Initialization.
leadlagtable = cell(0,6);
% Loop over the variables (dseries objects).
for i=1:length(variables)
    expression = strrep(expression,variables{i},'');
    current = ~isempty(regexpi(variables{i},'\(t\)'));
    lag = ~isempty(regexpi(variables{i},'\(t\-\d\)'));
    lead = ~isempty(regexpi(variables{i},'\(t\+\d\)'));
    start = regexpi(variables{i},'\(t\)|\(t\-\d\)|\(t\+\d\)');
    index = variables{i}(start:end);
    variables(i) = {variables{i}(1:start-1)};
    if isempty(leadlagtable)
        leadlagtable(1,1) = {variables{i}};
        if current
            leadlagtable(1,3) = {1};
        else
            leadlagtable(1,3) = {0};
        end
        if lag
            tmp = regexpi(index,'\d','match');
            leadlagtable(1,2) = {str2double(tmp{1})};
            leadlagtable(1,5) = {str2double(tmp{1})};
        else
            leadlagtable(1,2) = {0};
            leadlagtable(1,5) = {[]};
        end
        if lead
            tmp = regexpi(index,'\d','match');
            leadlagtable(1,4) = {str2double(tmp{1})};
            leadlagtable(1,6) = {str2double(tmp{1})};
        else
            leadlagtable(1,4) = {0};
            leadlagtable(1,6) = {[]};
        end
    else
        linea = strmatch(variables{i},leadlagtable(:,1));
        if isempty(linea)
            % This is a new variable!
            linea = size(leadlagtable,1)+1;
            leadlagtable(linea,1) = {variables{i}};
            leadlagtable(linea,2) = {0};
            leadlagtable(linea,3) = {0};
            leadlagtable(linea,4) = {0};
            leadlagtable(linea,5) = {[]};
            leadlagtable(linea,6) = {[]};
        end
        if current
            leadlagtable(linea,3) = {1};
        end
        if lag
            tmp = regexpi(index,'\d','match');
            leadlagtable(linea,2) = {max(str2double(tmp{1}),leadlagtable{linea,2})};
            leadlagtable(linea,5) = {sortrows([leadlagtable{linea,5}; str2double(tmp{1})])};
        end
        if lead
            tmp = regexpi(index,'\d','match');
            leadlagtable(linea,4) = {max(str2double(tmp{1}),leadlagtable{linea,4})};
            leadlagtable(linea,6) = {sortrows([leadlagtable{linea,6}; str2double(tmp{1})])};
        end
    end
end

% Set the number of variables
number_of_variables = size(leadlagtable,1);

% Initialize a cell array containing the names of the variables.
variable_names = cell(1);

% Test that all the involved variables are available dseries objects. Also check that
% these time series are defined over the time range given by d1 and d2 (taking care of
% the lags and leads) and check that each object is a singleton
for i=1:number_of_variables
    current_variable = leadlagtable{i,1};
    idvar = strfind(current_variable,'.');
    if isempty(idvar)
        idvar = 0;
    end
    if idvar
        current_variable_0 = current_variable(1:idvar-1);
    else
        current_variable_0 = current_variable;
    end
    try
        var = evalin('caller',current_variable_0);
    catch
        error(['dseries::from: Variable ' current_variable_0 ' is unknown!'])
    end
    if idvar
        try
            eval(sprintf('var = var.%s;',current_variable(idvar+1:end)))
        catch
            error(sprintf('dseries::from: Variable %s is not a member of dseries object %s!', current_variable(idvar+1:end), current_variable_0))
        end
    end
    if ~isdseries(var)
        error(['dseries::from: Variable ' current_variable ' is not a dseries object!'])
    else
        if ~var.vobs
            msg = sprintf('dseries::from: Object %s must not be empty!\n',current_variable);
            error(msg)
        end
        if var.vobs>1
            msg = sprintf('dseries::from: Object %s must contain only one variable!\n',current_variable);
            error(msg)
        end
        if i>1
            if ismember(var.name,variable_names)
                % Locally change variable name.
                var = var.rename(var.name{1},get_random_string(20));
            end
            variable_names(i) = {var.name{1}};
        else
            variable_names(i) = {var.name{1}};
        end
        if d1<var.dates(1)+leadlagtable{i,2}
            msg = sprintf('dseries::from: Initial date of the loop (%s) is inconsistent with %s''s range!\n',char(d1),current_variable);
            msg = [msg, sprintf('               Initial date should be greater than or equal to %s.',char(var.dates(1)+leadlagtable{i,2}))];
            error(msg)
        end
        if d2>var.dates(end)-leadlagtable{i,4}
            % The first variable should be the assigned variable (will be tested later)
            if ~isassignedvariable(leadlagtable{i,1},EXPRESSION)
                msg = sprintf('dseries::from: Last date of the loop (%s) is inconsistent with %s''s range!\n',char(d2),current_variable);
                msg = [msg, sprintf('               Last date should be less than or equal to %s.',char(var.dates(end)-leadlagtable{i,4}))];
                error(msg)
            else
                var = [var; dseries(NaN((d2-var.dates(end)),1),var.dates(end)+1:d2,var.name)];
            end
        end
        eval(sprintf('%s = var;',current_variable));
    end
end

% Get the name of the assigned variable (with time index)
assignedvariablename = regexpi(EXPRESSION(1:equal_id-1), '\w*\(t\)|\w*\(t\-\d\)|\w*\(t\+\d\)|\w*\.\w*\(t\)|\w*\.\w*\(t\-\d\)|\w*\.\w*\(t\+\d\)','match');
if isempty(assignedvariablename)
    error('dseries::from: Wrong syntax! The expression following the DO keyword must be an assignment (missing variable before the equal symbol).')
end
if length(assignedvariablename)>1
    error('dseries::from: No more than one variable can be assigned!')
end
% Check if the model is static
start = regexpi(assignedvariablename{1},'\(t\)|\(t\-\d\)|\(t\+\d\)');
index = assignedvariablename{1}(start:end);
assignedvariablename = assignedvariablename{1}(1:start-1);
indva = strmatch(assignedvariablename, leadlagtable(:,1));
dynamicmodel = ~isempty(regexpi(EXPRESSION(equal_id:end), ...
                                sprintf('%s\\(t\\)|%s\\(t\\-\\d\\)|%s\\(t\\+\\d\\)',assignedvariablename,assignedvariablename,assignedvariablename),'match'));
% Check that the dynamic model for the endogenous variable is not forward looking.
if dynamicmodel
    indum = index2num(index);
    if indum<leadlagtable{indva,4}
        error('dseries::from: It is not possible to simulate a forward looking model!')
    end
end
% Check that the assigned variable does not depend on itself (the assigned variable can depend on its past level but not on the current level).
if dynamicmodel
    tmp = regexpi(EXPRESSION(equal_id+1:end), ...
                  sprintf('%s\\(t\\)|%s\\(t\\-\\d\\)|%s\\(t\\+\\d\\)',assignedvariablename,assignedvariablename,assignedvariablename),'match');
    tmp = cellfun(@extractindex, tmp);
    tmp = cellfun(@index2num, tmp);
    if ~all(tmp(:)<indum)
        error(sprintf('dseries::from: On the righthand side, the endogenous variable, %s, must be indexed by %s at most.',assignedvariablename,num2index(indum-1)))
    end
end

% Put all the variables in a unique dseries object.
list_of_variables = leadlagtable{1,1};
for i=2:number_of_variables
    list_of_variables = [list_of_variables, ',' leadlagtable{i,1}];
end
eval(sprintf('tmp = [%s];', list_of_variables));

% Get base time index
t1 = find(d1==tmp.dates);
t2 = find(d2==tmp.dates);

% Get data
data = tmp.data;

% Isolate the (potential) parameters in the expression to be evaluated
TMP314 = regexp(expression, '([0-9]*\.[0-9]*|\w*)', 'match');
% Here I remove the numbers (TMP314 -> TMP314159).
TMP3141 = regexp(TMP314,'(([0-9]*\.[0-9]*)|([0-9]*))','match');
TMP31415 = find(cellfun(@isempty,TMP3141));
TMP314159 = TMP314(TMP31415);

if dynamicmodel
    % Transform EXPRESSION by replacing calls to the dseries objects by references to data.
    for i=1:number_of_variables
        EXPRESSION = regexprep(EXPRESSION,sprintf('%s\\(t\\)',leadlagtable{i,1}),sprintf('data(t,%s)',num2str(i)));
        for j=1:length(leadlagtable{i,5})
            lag = leadlagtable{i,5}(j);
            EXPRESSION = regexprep(EXPRESSION,sprintf('%s\\(t-%s\\)',leadlagtable{i,1},num2str(lag)), ...
                                   sprintf('data(t-%s,%s)',num2str(lag),num2str(i)));
        end
        for j=1:length(leadlagtable{i,6})
            lead = leadlagtable{i,6}(j);
            EXPRESSION = regexprep(EXPRESSION,sprintf('%s\\(t+%s\\)',leadlagtable{i,1},num2str(lead)), ...
                                   sprintf('data(t+%s,%s)',num2str(lead),num2str(i)));
        end
    end
    % Get values for the parameters (if any)
    if ~isempty(TMP314159)
        for i=1:length(TMP314159)
            wordcandidate = TMP314159{i};
            try % If succesful, word is a reference to a variable in the caller function/script.
                thiswordisaparameter = evalin('caller', wordcandidate);
                eval(sprintf('%s = thiswordisaparameter;',wordcandidate));
            catch
                % I assume that word is a reference to a function.
            end
        end
    end
    % Do the job. Evaluate the recursion.
    eval(sprintf('for t=%s:%s, %s; end',num2str(t1),num2str(t2),EXPRESSION));
else
    % Transform EXPRESSION by replacing calls to the dseries objects by references to data.
    for i=1:number_of_variables
        EXPRESSION = regexprep(EXPRESSION,sprintf('%s\\(t\\)',leadlagtable{i,1}), ...
                               sprintf('data(%s:%s,%s)',num2str(t1),num2str(t2),num2str(i)));
        for j=1:length(leadlagtable{i,5})
            lag = leadlagtable{i,5}(j);
            EXPRESSION = regexprep(EXPRESSION,sprintf('%s\\(t-%s\\)',leadlagtable{i,1},num2str(lag)), ...
                                   sprintf('data(%s:%s,%s)',num2str(t1-lag),num2str(t2-lag),num2str(i)));
        end
        for j=1:length(leadlagtable{i,6})
            lead = leadlagtable{i,6}(j);
            EXPRESSION = regexprep(EXPRESSION,sprintf('%s\\(t+%s\\)',leadlagtable{i,1},num2str(lead)), ...
                                   sprintf('data(%s:%s,%s)',num2str(t1-lead),num2str(t2-lead),num2str(i)));
        end
    end
    % Transform some operators (^ -> .^, / -> ./ and * -> .*)
    EXPRESSION = strrep(EXPRESSION,'^','.^');
    EXPRESSION = strrep(EXPRESSION,'*','.*');
    EXPRESSION = strrep(EXPRESSION,'/','./');
    % Get values for the parameters (if any)
    if ~isempty(TMP314159)
        for i=1:length(TMP314159)
            wordcandidate = TMP314159{i};
            try % If succesful, word is a reference to a variable in the caller function/script.
                thiswordisaparameter = evalin('caller', wordcandidate);
                eval(sprintf('%s = thiswordisaparameter;',wordcandidate));
            catch
                % I assume that word is a reference to a function.
            end
        end
    end
    % Do the job. Evaluate the static expression.
    eval(sprintf('%s;',EXPRESSION));
end

% Put assigned variable back in the caller workspace...
if isempty(strfind(assignedvariablename,'.'))
    eval(sprintf('assignin(''caller'', ''%s'', dseries(data(:,indva),%s.init,%s.name,%s.tex));', ...
                 assignedvariablename,assignedvariablename,assignedvariablename,assignedvariablename))
else
    DATA = num2cell(data(:,indva));
    strdata = sprintf('%f ', DATA{:});
    evalin('caller',sprintf('%s = dseries(transpose([%s]),%s.init,%s.name,%s.tex);', ...
                            assignedvariablename,strdata,assignedvariablename,assignedvariablename,assignedvariablename))
end

function msg = get_error_message_0(msg)
if ~nargin
    msg = sprintf('Wrong syntax! The correct syntax is:\n\n');
else
    msg = [msg, sprintf('The correct syntax is:\n\n')];
end
msg = [msg, sprintf('    from d1 to d2 do SOMETHING\n\n')];
msg = [msg, sprintf('where d1<d2 are dates objects, and SOMETHING is a recursive expression involving dseries objects.')];


function index = extractindex(str)
index = regexpi(str,'\(t\)|\(t\-\d\)|\(t\+\d\)','match');


function i = index2num(id)
if isequal('(t)',id)
    i = 0;
    return
end
if isequal('-',id(3))
    i = - str2num(id(4:end-1));
else
    i = str2num(id(4:end-1));
end


function id = num2index(i)
if isequal(i,0)
    id = '(t)';
    return
end
if i<0
    id = ['(t-' int2str(abs(i)) ')'];
else
    id = ['(t+' int2str(i) ')'];
end

function i = isassignedvariable(var,expr)
idv = strfind(expr,var);
idq = strfind(expr,'=');
if ~isempty(idv)
    if idv(1)<idq
        i = 1;
        return
    end
end
i = 0;

return

%@test:1
try
    y = dseries(zeros(400,1),dates('1950Q1')) ;
    v = dseries(randn(400,1),dates('1950Q1')) ;
    u = dseries(randn(400,1),dates('1950Q1')) ;
    from 1950Q2 to 2049Q4 do y(t) = (1+.01*u(t))*y(t-1) + v(t)
    t(1) = 1;
catch
    t(1) = 0;
end

T = all(t);
%@eof:1

%@test:2
try
    y = dseries(zeros(400,1),dates('1950Q1')) ;
    v = dseries(randn(400,1),dates('1950Q1')) ;
    u = dseries(randn(400,1),dates('1950Q1')) ;
    from 1950Q2 to 2049Q3 do y(t) = (1+.01*u(t))*y(t+1) + v(t)
    t(1) = 0;
catch
    t(1) = 1;
end

T = all(t);
%@eof:2

%@test:3
try
    y = dseries(zeros(400,1),dates('1950Q1')) ;
    v = dseries(randn(400,1),dates('1950Q1')) ;
    u = dseries(randn(400,1),dates('1950Q1')) ;
    from 1950Q2 to 2049Q4 do y(t) = v(t) -.5*v(t-1);
    t(1) = 1;
catch
    t(1) = 0;
end

T = all(t);
%@eof:3

%@test:4
try
    y = dseries(zeros(400,1),dates('1950Q1')) ;
    v = dseries(randn(400,1),dates('1950Q1')) ;
    u = dseries(randn(400,1),dates('1950Q1')) ;
    from 1950Q2 to 2049Q4 do y(t) = 2*((v(t) -.5*v(t-1))>0)-1;
    t(1) = 1;
catch
    t(1) = 0;
end

T = all(t);
%@eof:4

%@test:5
try
    y = dseries(zeros(4000,1),dates('1950Q1')) ;
    v = dseries(randn(4000,1),dates('1950Q1')) ;
    u = dseries(randn(4000,1),dates('1950Q1')) ;
    from 1950Q2 to 2949Q4 do y(t) = y(t-1)*(2*((v(t) -.5*v(t-1))>u(t))-1)+u(t); %plot(y)
    t(1) = 1;
catch
    t(1) = 0;
end

T = all(t);
%@eof:5

%@test:6
try
    y = dseries(zeros(2*365+1,1),dates('2000-01-01')) ;
    v = dseries(randn(2*365+1,1),dates('2000-01-01')) ;
    u = dseries(randn(2*365+1,1),dates('2000-01-01')) ;
    from 2000-01-02 to 2001-12-31 do y(t) = (1+.01*u(t))*y(t-1) + v(t)
    t(1) = true;
catch
    t(1) = false;
end

T = all(t);
%@eof:6
