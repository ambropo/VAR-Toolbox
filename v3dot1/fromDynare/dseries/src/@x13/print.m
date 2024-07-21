function basename = print(o, basename) % --*-- Unitary tests --*--

% Prints spc file.

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

if nargin<2 || isempty(basename)
    basename = randomstring(10);
end

fid = fopen(sprintf('%s.spc', basename), 'w');

% Print creation date
if ~isoctave() && ~verLessThan('matlab','9.0')
    fprintf(fid, '# File created on %s by Dynare.\n\n', datetime());
else
    fprintf(fid, '# File created on %s by Dynare.\n\n', datestr(now));
end

% Write SERIES block
fprintf(fid, 'series {\n');
fprintf(fid, ' title = "%s"\n', o.y.name{1});
p1 = firstobservedperiod(o.y);
p2 = lastobservedperiod(o.y);
printstart(fid, p1);
fprintf(fid, ' period = %i\n', o.y.init.freq);
fprintf(fid, ' data = %s', sprintf(data2txt(o.y(p1:p2).data)));
fprintf(fid, '}\n\n');

% Write TRANSFORM block
if ismember('transform', o.commands)
    fprintf(fid, 'transform {');
    if ~all(cellfun(@isempty, struct2cell(o.transform)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.transform);
        for i=1:length(optionnames)
            if ~isempty(o.transform.(optionnames{i}))
                printoption(fid, optionnames{i}, o.transform.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write REGRESSION block
if ismember('regression', o.commands)
    fprintf(fid, 'regression {');
    if ~all(cellfun(@isempty, struct2cell(o.regression)))
        optionnames = fieldnames(o.regression);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.regression.(optionnames{i}))
                if isequal(optionnames{i}, 'user') % Write needed data to a file.
                                                   % Determine the set of needed data
                    conditionningvariables = strsplit(o.regression.user, {',' , '(' , ')' , ' '});
                    conditionningvariables = conditionningvariables(~cellfun(@isempty,conditionningvariables));
                    % Check that these data are available.
                    for j=1:length(conditionningvariables)
                        if ~ismember(conditionningvariables{j}, o.x.name)
                            fclose(fid);
                            error('x13:regression: Variable %s is unkonwn', conditionningvariables{j})
                        end
                    end
                    % Select the data.
                    if length(conditionningvariables)<vobs(o.x)
                        x = o.x{conditionningvariables{:}};
                    else
                        x= o.x;
                    end
                    % Print user statement.
                    fprintf(fid, ' user = %s\n', o.regression.user);
                    % Print data statement.
                    fprintf(fid, ' data = %s\n', sprintf(data2txt(x.data)));
                elseif isequal(optionnames{i}, 'start')
                    if ischar(o.regression.start)
                        if isdate(o.regression.start)
                            PERIOD = dates(o.regression.start);
                        else
                            error('x13:regression: Option start cannot be interpreted as a date!')
                        end
                    elseif isdates(o.regression.start)
                        PERIOD = o.regression.start;
                    else
                        error('x13:regression: Option start cannot be interpreted as a date!')
                    end
                    printstart(fid, PERIOD);
                else
                    printoption(fid, optionnames{i}, o.regression.(optionnames{i}));
                end
            end
        end
        if ~isempty(o.x) && isempty(o.regression.start)
            fprintf(fid, ' start = %i.%i\n', year(o.x.init), subperiod(o.x.init));
        end
    end
    fprintf(fid, '}\n\n');
end

% Write ARIMA block
if ismember('arima', o.commands)
    fprintf(fid, 'arima {');
    if ~all(cellfun(@isempty, struct2cell(o.arima)))
        optionnames = fieldnames(o.arima);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.arima.(optionnames{i}))
                printoption(fid, optionnames{i}, o.arima.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write AUTOMDL block
if ismember('automdl', o.commands)
    fprintf(fid, 'automdl {');
    if ~all(cellfun(@isempty, struct2cell(o.automdl)))
        optionnames = fieldnames(o.automdl);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.automdl.(optionnames{i}))
                printoption(fid, optionnames{i}, o.automdl.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write OUTLIER block
if ismember('outlier', o.commands)
    fprintf(fid, 'outlier {');
    if ~all(cellfun(@isempty, struct2cell(o.outlier)))
        optionnames = fieldnames(o.outlier);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.outlier.(optionnames{i}))
                printoption(fid, optionnames{i}, o.outlier.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write FORECAST block
if ismember('forecast', o.commands)
    fprintf(fid, 'forecast {');
    if ~all(cellfun(@isempty, struct2cell(o.forecast)))
        optionnames = fieldnames(o.forecast);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.forecast.(optionnames{i}))
                printoption(fid, optionnames{i}, o.forecast.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write ESTIMATE block
if ismember('estimate', o.commands)
    fprintf(fid, 'estimate {');
    if ~all(cellfun(@isempty, struct2cell(o.estimate)))
        optionnames = fieldnames(o.estimate);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.estimate.(optionnames{i}))
                printoption(fid, optionnames{i}, o.estimate.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write CHECK block
if ismember('check', o.commands)
    fprintf(fid, 'check {');
    if ~all(cellfun(@isempty, struct2cell(o.check)))
        optionnames = fieldnames(o.check);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.check.(optionnames{i}))
                printoption(fid, optionnames{i}, o.check.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write X11 block
if ismember('x11', o.commands)
    fprintf(fid, 'x11 {');
    if ~all(cellfun(@isempty, struct2cell(o.x11)))
        optionnames = fieldnames(o.x11);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.x11.(optionnames{i}))
                printoption(fid, optionnames{i}, o.x11.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write FORCE block
if ismember('force', o.commands)
    fprintf(fid, 'force {');
    if ~all(cellfun(@isempty, struct2cell(o.force)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.force);
        for i=1:length(optionnames)
            if ~isempty(o.force.(optionnames{i}))
                printoption(fid, optionnames{i}, o.force.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write HISTORY block
if ismember('history', o.commands)
    fprintf(fid, 'history {');
    if ~all(cellfun(@isempty, struct2cell(o.history)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.history);
        for i=1:length(optionnames)
            if ~isempty(o.history.(optionnames{i}))
                printoption(fid, optionnames{i}, o.history.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write METADATA block
if ismember('metadata', o.commands)
    fprintf(fid, 'metadata {');
    if ~all(cellfun(@isempty, struct2cell(o.metadata)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.metadata);
        for i=1:length(optionnames)
            if ~isempty(o.metadata.(optionnames{i}))
                printoption(fid, optionnames{i}, o.metadata.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write IDENTIFY block
if ismember('identify', o.commands)
    fprintf(fid, 'identify {');
    if ~all(cellfun(@isempty, struct2cell(o.identify)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.identify);
        for i=1:length(optionnames)
            if ~isempty(o.identify.(optionnames{i}))
                printoption(fid, optionnames{i}, o.identify.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write PICKMDL block
if ismember('pickmdl', o.commands)
    fprintf(fid, 'pickmdl {');
    if ~all(cellfun(@isempty, struct2cell(o.pickmdl)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.pickmdl);
        for i=1:length(optionnames)
            if ~isempty(o.pickmdl.(optionnames{i}))
                printoption(fid, optionnames{i}, o.pickmdl.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write SEATS block
if ismember('seats', o.commands)
    fprintf(fid, 'seats {');
    if ~all(cellfun(@isempty, struct2cell(o.seats)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.seats);
        for i=1:length(optionnames)
            if ~isempty(o.seats.(optionnames{i}))
                printoption(fid, optionnames{i}, o.seats.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write SLIDINGSPANS block
if ismember('slidingspans', o.commands)
    fprintf(fid, 'slidingspans {');
    if ~all(cellfun(@isempty, struct2cell(o.slidingspans)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.slidingspans);
        for i=1:length(optionnames)
            if ~isempty(o.slidingspans.(optionnames{i}))
                printoption(fid, optionnames{i}, o.slidingspans.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write SPECTRUM block
if ismember('spectrum', o.commands)
    fprintf(fid, 'spectrum {');
    if ~all(cellfun(@isempty, struct2cell(o.spectrum)))
        fprintf(fid, '\n');
        optionnames = fieldnames(o.spectrum);
        for i=1:length(optionnames)
            if ~isempty(o.spectrum.(optionnames{i}))
                printoption(fid, optionnames{i}, o.spectrum.(optionnames{i}));
            end
        end
    end
    fprintf(fid, '}\n\n');
end

% Write X11REGRESSION block
if ismember('x11regression', o.commands)
    fprintf(fid, 'x11regression {');
    if ~all(cellfun(@isempty, struct2cell(o.x11regression)))
        optionnames = fieldnames(o.x11regression);
        fprintf(fid, '\n');
        for i=1:length(optionnames)
            if ~isempty(o.x11regression.(optionnames{i}))
                if isequal(optionnames{i}, 'user') % Write needed data to a file.
                                                   % Determine the set of needed data
                    conditionningvariables = strsplit(o.x11regression.user, {',' , '(' , ')' , ' '});
                    conditionningvariables = conditionningvariables(~cellfun(@isempty,conditionningvariables));
                    % Check that these data are available.
                    for j=1:length(conditionningvariables)
                        if ~ismember(conditionningvariables{j}, o.x.name)
                            fclose(fid);
                            error('x13:x11regression: Variable %s is unknown', conditionningvariables{j})
                        end
                    end
                    % Select the data.
                    if length(conditionningvariables)<vobs(o.x)
                        x = o.x{conditionningvariables{:}};
                    else
                        x= o.x;
                    end
                    % Print user statement.
                    fprintf(fid, ' user = %s\n', o.x11regression.user);
                    % Print data statement.
                    fprintf(fid, ' data = %s\n', sprintf(data2txt(x.data)));
                elseif isequal(optionnames{i}, 'start')
                    if ischar(o.x11regression.start)
                        if isdate(o.x11regression.start)
                            PERIOD = dates(o.x11regression.start);
                        else
                            error('x13:x11regression: Option start cannot be interpreted as a date!')
                        end
                    elseif isdates(o.x11regression.start)
                        PERIOD = o.x11regression.start;
                    else
                        error('x13:x11regression: Option start cannot be interpreted as a date!')
                    end
                    printstart(fid, PERIOD);
                else
                    printoption(fid, optionnames{i}, o.x11regression.(optionnames{i}));
                end
            end
        end
        if ~isempty(o.x) && isempty(o.x11regression.start)
            fprintf(fid, ' start = %i.%i\n', year(o.x.init), subperiod(o.x.init));
        end
    end
    fprintf(fid, '}\n\n');
end

fclose(fid);

return

%@test:1
try
    series = dseries(rand(100,1),'1999M1');
    o = x13(series);
    o.x11('save','(d11)');
    o.automdl('savelog','amd','mixed','no');
    o.outlier('types','all','save','(fts)');
    o.check('maxlag',24,'save','(acf pcf)');
    o.estimate('save','(mdl est)');
    o.forecast('maxlead',18,'probability',0.95,'save','(fct fvr)');
    o.run(); % necessary to invoke alphanumeric "basename"
    o.print();

    text = fileread(sprintf('%s.spc',o.results.name));
    comm = o.commands;

    for i = 1:numel(comm)
        ex(i,1) = ~isempty(strfind(text,[comm{i} ' {']));
    end

    if all(ex)
        t(1) = true;
        o.clean();
    end
catch
    t(1) = false;
end

T = all(t);
%@eof:1