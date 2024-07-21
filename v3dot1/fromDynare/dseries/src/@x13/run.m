function run(o, basename)

% Runs x13 program and saves results.

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

% Print spc file.
basename = o.print();

% Get expected path to X13 binary.
x13b = select_x13_binary();

% Test for the existence of the binary.
if ~exist(x13b, 'file')
    error('X13 is not available, so we cannot run the generated spc file.')
end

% Run spc file.
[~, ~] = system(sprintf('%s %s', x13b, basename));

o.results.name = basename; % Base name of the generated files.

% Save results related to the REGRESSION command
if ~all(cellfun(@isempty, struct2cell(o.regression)))
    if ~isempty(o.regression.save)
        savedoutput = strsplit(o.regression.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
            end
        end
    end
end

% Save results related to the X11 command
if ~all(cellfun(@isempty, struct2cell(o.x11)))
    if ~isempty(o.x11.save)
        savedoutput = strsplit(o.x11.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
            end
        end
    end
end

% Save results related to the FORECAST command
if ~all(cellfun(@isempty, struct2cell(o.forecast)))
    if ~isempty(o.forecast.save)
        savedoutput = strsplit(o.forecast.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                initdate = num2str(tmp.data(1,1)); % wrong in series
                t = o.y.dates;
                name = strsplit(tmp.textdata{1},'\t');
                name = name(2:end);
                data = tmp.data(:,2:end);
                if isempty(data)
                    disp(['x13:forecast:: Problem reading ' sprintf('%s.%s', basename, lower(savedoutput{i})) '. Output formatting may be incorrect!']);
                    initdate = tmp.textdata{3,1};
                    o.results.(savedoutput{i}) = dseries(NaN(length(tmp.data),numel(name)), dates(t.freq,str2num(initdate(1:4)),str2num(initdate(5:end))),name);
                else
                    o.results.(savedoutput{i}) = dseries(data, dates(t.freq,str2num(initdate(1:4)),str2num(initdate(5:end))),name);
                end
            end
        end
    end
end

% Save results related to the TRANSFORM command
if ~all(cellfun(@isempty, struct2cell(o.transform)))
    if ~isempty(o.transform.save)
        savedoutput = strsplit(o.transform.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
            end
        end
    end
end

% Save results related to the OUTLIER command
if ~all(cellfun(@isempty, struct2cell(o.outlier)))
    if ~isempty(o.outlier.save)
        savedoutput = strsplit(o.outlier.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                if lower(savedoutput{i}) == 'fts'
                    header = strjoin(tmp.textdata(1));
                    header = strsplit(header, {'\t'});
                    header = header(1,2:end);
                    o.results.(savedoutput{i}) = dseries(data(:,2:end), o.y.init, regexprep(header,'\(|\)',''));
                elseif lower(savedoutput{i}) == 'oit'
                    header = strjoin(tmp.textdata(1,1));
                    header = strsplit(header, {'\t'});
                    header = header(1,4:end);
                    info   = tmp.textdata(3:end,3);
                    for j = 1:numel(info)
                        flag = strjoin(info(j));
                        o.results.(savedoutput{i}).(['outlier_' num2str(j)]).type = flag(1:2);
                        o.results.(savedoutput{i}).(['outlier_' num2str(j)]).date(1,1) = str2double(flag(3:strfind(flag,'.')-1));
                        o.results.(savedoutput{i}).(['outlier_' num2str(j)]).date(1,2) = str2double(flag(strfind(flag,'.')+1:end));
                        o.results.(savedoutput{i}).(['outlier_' num2str(j)]).(header{1}) = data(j,1);% medrmse
                        o.results.(savedoutput{i}).(['outlier_' num2str(j)]).(header{2}) = data(j,2);% rmse
                        o.results.(savedoutput{i}).(['outlier_' num2str(j)]).(header{3}) = data(j,3);% t-stat
                    end
                end
            end
        end
    end
end

% Save results related to the SLIDINGSPANS command
if ~all(cellfun(@isempty, struct2cell(o.slidingspans)))
    if ~isempty(o.slidingspans.save)
        savedoutput = strsplit(o.slidingspans.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                header = strjoin(tmp.textdata(1));
                header = strsplit(header, {'\t'});
                header = header(1,2:end);
                % In this case, the initial date is not the start of the series provided
                startdate = num2str(data(1,1));
                startdate = dates(o.y.dates.freq,str2double(startdate(1:4)),str2double(startdate(5:6)));
                o.results.(savedoutput{i}) = dseries(data(:,2:end),startdate, regexprep(header,'%','pct'));
            end
        end
    end
end

% Save results related to the IDENTIFY command
if ~all(cellfun(@isempty, struct2cell(o.identify)))
    if ~isempty(o.identify.save)
        savedoutput = strsplit(o.identify.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                header = strjoin(tmp.textdata(3,1));
                header = strsplit(header, {'\t'});
                header = header(1,2:end);
                for j = 1:length(data)
                    for k = 1:numel(header)
                        o.results.(savedoutput{i}).(['lag' num2str(j)]).(strjoin(regexprep(header(k),'(\.||\-)',''))) = data(j,k+1);
                    end
                end
            end
        end
    end
end

% Save results related to the CHECK command
if ~all(cellfun(@isempty, struct2cell(o.check)))
    if ~isempty(o.check.save)
        savedoutput = strsplit(o.check.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                % if "ac2" is selected and output is treated as a table/struct, there will be a
                % dimension error. As long as there is no fix, ac2 is saved as text.
                if lower(savedoutput{i}) == 'ac2'
                    o.results.(savedoutput{i}) = fileread(sprintf('%s.ac2', basename));
                else
                    tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                    data = tmp.data;
                    header = strjoin(tmp.textdata(1,1));
                    header = strsplit(header, {'\t'});
                    header = header(1,2:end);
                    for j = 1:length(data)
                        for k = 1:numel(header)
                            o.results.(savedoutput{i}).(['lag' num2str(j)]).(strjoin(regexprep(header(k),'(\.||\-)',''))) = data(j,k+1);
                        end
                    end
                end
            end
        end
    end
end

% Save results related to the FORCE command
if ~all(cellfun(@isempty, struct2cell(o.force)))
    if ~isempty(o.force.save)
        savedoutput = strsplit(o.force.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
            end
        end
    end
end

% Save results related to the SPECTRUM command
if ~all(cellfun(@isempty, struct2cell(o.spectrum)))
    if ~isempty(o.spectrum.save)
        savedoutput = strsplit(o.spectrum.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                header = strjoin(tmp.textdata(1,1));
                header = strsplit(header, {'\t'});
                header = regexprep(header(2:end),'10','Ten');
                for j = 1:numel(header)
                    o.results.(savedoutput{i}).(strjoin(regexprep(header(j),'(\*||\(||\))',''))) = data(:,j+1);
                end
            end
        end
    end
end

% Save results related to the SEATS command
if ~all(cellfun(@isempty, struct2cell(o.seats)))
    if ~isempty(o.seats.save)
        savedoutput = strsplit(o.seats.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                data = tmp.data;
                o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
            end
        end
    end
    o.results.tbs = fileread(sprintf('%s.tbs', basename));
end

% Save results related to the X11REGRESSION command
if ~all(cellfun(@isempty, struct2cell(o.x11regression)))
    if ~isempty(o.x11regression.save)
        savedoutput = strsplit(o.x11regression.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                if lower(savedoutput{i}) == 'xrc'
                    o.results.out = fileread(sprintf('%s.xrc', basename));
                else
                    tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                    data = tmp.data;
                    o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
                end
            end
        end
    end
end

% Save results related to the ESTIMATE command
if ~all(cellfun(@isempty, struct2cell(o.estimate)))
    if ~isempty(o.estimate.save)
        savedoutput = strsplit(o.estimate.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i = 1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                % The .est file cannot be read straightforwardly using
                % importdata, so it is treated separately:
                if lower(savedoutput{i}) == 'est'
                    fid  = fopen(sprintf('%s.%s', basename, lower(savedoutput{i})));
                    fid2 = fopen(sprintf('%s.estx', basename), 'w');
                    r = 1;
                    s = 0;
                    while s<=1
                        a = fgetl(fid);
                        if a ~= -1
                            output{r,1} = a;
                            fprintf(fid2,[a '\n']);
                        else
                            s = s+1;
                        end
                        r = r+1;
                    end
                    o.results.(savedoutput{i}) = fileread(sprintf('%s.estx', basename));
                elseif lower(savedoutput{i}) == 'mdl'
                    o.results.(savedoutput{i}) = fileread(sprintf('%s.mdl', basename));
                elseif lower(savedoutput{i}) == 'rcm'
                    o.results.(savedoutput{i}) = fileread(sprintf('%s.rcm', basename));
                elseif lower(savedoutput{i}) == 'acm'
                    o.results.(savedoutput{i}) = fileread(sprintf('%s.acm', basename));
                else % Files that can be read with importdata
                    tmp  = importdata(sprintf('%s.%s', basename, lower(savedoutput{i})), '\t');
                    data = tmp.data;

                    if lower(savedoutput{i}) == 'lks'
                        for j = 1:numel(tmp.textdata)
                            o.results.(savedoutput{i}).(tmp.textdata{j}) = data(j);
                        end
                    elseif lower(savedoutput{i}) == 'ref'
                        header = strjoin(tmp.textdata(1,1));
                        header = strsplit(header, {'\t'});
                        header = regexprep(header(1,2:end),'( ||\-)','');
                        for j = 1:numel(header)
                            o.results.(savedoutput{i}).(header{j}) = dseries(data(:,j+1), o.y.init, header(j));
                        end
                    elseif lower(savedoutput{i}) == 'rrs'
                        o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
                    elseif lower(savedoutput{i}) == 'rsd'
                        o.results.(savedoutput{i}) = dseries(data(:,2), o.y.init, savedoutput{i});
                    elseif lower(savedoutput{i}) == 'rts'
                        header = strjoin(tmp.textdata(1,1));
                        header = strsplit(header, {'\t'});
                        info   = tmp.textdata(3:end,1:2);
                        for j = 1:rows(data)
                            for k = 1:columns(info)
                                o.results.(savedoutput{i}).(['root_' num2str(j)]).(header{k}) = strjoin(info(j,k));
                            end
                            for k = 1:columns(data)
                                o.results.(savedoutput{i}).(['root_' num2str(j)]).(header{k+columns(info)}) = data(j,k);
                            end
                        end
                    elseif lower(savedoutput{i}) == 'itr'
                        data   = data(:,3:end);
                        header = strjoin(tmp.textdata(1,1));
                        header = strsplit(header, {'\t'});
                        header = header(3:end-1);
                        for j = 1:rows(data)
                            for k = 1:columns(header)
                                o.results.(savedoutput{i}).(['iter_' num2str(j)]).(header{k}) = data(j,k);
                            end
                        end
                    end
                end
            end
        end
    end
end

% Save results related to the HISTORY command
if ~all(cellfun(@isempty, struct2cell(o.history)))
    if ~isempty(o.history.save)
        savedoutput = strsplit(o.history.save, {',' , '(' , ')' , ' '});
        savedoutput = savedoutput(~cellfun('isempty', savedoutput));
        for i=1:length(savedoutput)
            if exist(sprintf('%s.%s', basename, lower(savedoutput{i})))
                % Prov
                o.results.(savedoutput{i}) =fileread(sprintf('%s.%s', basename,lower(savedoutput{i})));
            end
        end
    end
end

% Save main generated output file.
o.results.out = fileread(sprintf('%s.out', basename));
