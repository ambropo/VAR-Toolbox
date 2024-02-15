function estimate(o, varargin)

% Estimate method for arima class.

% Copyright (C) 2017 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dseries submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

% Set default values for options.
options.tol = 1e-5;
options.exact = 'arma';
options.maxiter = 1500;
options.outofsample = false;
options.print='none';
options.save = 'estimates lkstats residuals';

% Update options.
if length(varargin)
    if mod(length(varargin), 2)
        error('arima:estimate:WrongInputArguments', 'Number of input should be even (option name, option value)!')
    else
        for option_id = 1:2:length(varargin)
            if ismember(varargin{option_id}, {'tol', 'exact', 'maxiter', 'outofsample', 'print', 'save'})
                eval(sprintf('options.%s = %s;', varargin{option_id}, varargin{option_id+1}))
            else
                warning('arima:estimate: Unknown option %s!', varargin{option_id})
            end
        end
    end
end

model = sprintf('(%i,%i,%i)', o.p, o.d, o.q);
for i = 1:length(o.P)
    model = sprintf('%s(%i,%i,%i)%i', model, o.P(i), o.D(i), o.Q(i), o.S(i));
end

% Set random name for temporary *.spc file.
basefilename = randomstring(10);

% Write *.spc file for estimation.
fid = fopen([basefilename '.spc'], 'w');
fprintf(fid, '# File created on %s by Dynare.\n\n', datetime());
fprintf(fid, 'series {\n');
fprintf(fid, '  title = "%s"\n', o.y.name{1});
fprintf(fid, '  start = %i.%i\n', o.y.init.year, o.y.init.subperiod);
fprintf(fid, '  period = %i\n', o.y.init.freq);
fprintf(fid, '  data = %s', sprintf(data2txt(o.y.data)));
fprintf(fid, '}\n\n');
fprintf(fid, 'arima{ Model = %s }\n\n', model);
fprintf(fid, 'estimate{\n');
fprintf(fid, '  tol = %d\n', options.tol);
fprintf(fid, '  maxiter = (%i)\n', options.maxiter);
fprintf(fid, '  exact = %s\n', options.exact);
if options.outofsample
    fprintf(fid, '  outofsample = yes\n');
else
    fprintf(fid, '  outofsample = no\n');
end
fprintf(fid, '  print = (%s)\n', options.print);
fprintf(fid, '  save = (%s)\n', options.save);
fprintf(fid, '}\n');
fclose(fid);

% Run estimation of the ARIMA model
[status, result] = system(sprintf('%s %s', select_x13_binary(), basefilename));

% Get the content of the generated *.est file
fid = fopen(sprintf('%s.est', basefilename), 'r');
if fid<=0, error('arima:estimate: Unable to find %.est', basefilename); end
txt = textscan(fid, '%s', 'delimiter', '\n');
txt = txt{1};
fclose(fid);

% Locate the lines where the estimates are reported.
l0 = find(strncmp(txt, '$arima$estimates$:',7))+3;
l1 = find(strncmp(txt, '$variance$:',7))-1;

% Read and store the estimation results.
for l = l0:l1
    linea = textscan(txt{l}, '%s %s %d %d %f %f');
    switch linea{1}{1}
      case 'AR'
        switch linea{2}{1}
          case 'Nonseasonal'
            o.ar(linea{4}) = linea{5};
            o.ar_std(linea{4}) = linea{6};
          case 'Seasonal'
            i = find(linea{3}==o.S);
            o.AR{i}(linea{4}) = linea{5};
            o.AR_std{i}(linea{4}) = linea{6};
          otherwise
            % For seasonal factors for wich the period is not matching the data frequency.
            linea = textscan(txt{l}, '%s %s %d %d %d %f %f');
            i = find(linea{4}==o.S);
            o.AR{i}(linea{5}) = linea{6};
            o.AR_std{i}(linea{5}) = linea{7};
        end
      case 'MA'
        switch linea{2}{1}
          case 'Nonseasonal'
            o.ma(linea{4}) = linea{5};
            o.ma_std(linea{4}) = linea{6};
          case 'Seasonal'
            i = find(linea{4}==o.S);
            o.MA{i}(linea{4}) = linea{5};
            o.MA_std{i}(linea{4}) = linea{6};
          otherwise
            % For seasonal factors for wich the period is not matching the data frequency.
            linea = textscan(txt{l}, '%s %s %d %d %d %f %f');
            i = find(linea{4}==o.S);
            o.MA{i}(linea{5}) = linea{6};
            o.MA_std{i}(linea{5}) = linea{7};
        end
      otherwise
        error('arima:estimate: Unable to interpret line %i line in %s.est!', l, basefilename)
    end
end

l2 = find(strncmp(txt, '$variance$:',7))+2;

% Get the estimated standard error of the innovations.
linea = textscan(txt{l2}, '%s %f');
if isequal(linea{1}{1}, 'mle')
    o.estimation.sigma = linea{2};
else
    error('arima:estimate: Unable to find the estimated standard error of the innovations in %s.est', basefilename)
end

% TODO Figure out what is se
% linea = textscan(txt{l2+1}, '%s %f');
% if isequal(linea{1}{1}, 'se')
%     o.sigma = linea{2}
% else
%     error()
%end

% Get the content of the generated *.rsd file
fid = fopen(sprintf('%s.rsd', basefilename), 'r');
if fid<=0, error('arima:estimate: Unable to find %.rsd', basefilename); end
txt = textscan(fid, '%s', 'delimiter', '\n');
txt = txt{1}(3:end);
fclose(fid);

% Read and store the estimated innovations.
data = cellfun(@(x) x{2}, cellfun(@(x) [textscan(x, '%d %f')], txt, 'UniformOutput', false), 'UniformOutput', false);
data = transpose([data{:}]);
o.estimation.e = dseries(data, o.y.init, {'innovations'}, {'\hat{\varepsilon}'});

% Get the content of the generated *.lks file
fid = fopen(sprintf('%s.lks', basefilename), 'r');
if fid<=0, error('arima:estimate: Unable to find %.lks', basefilename); end
txt = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

linea = textscan(txt{1}{2}, '%s %d');
if isequal(linea{1}{1}, 'nobs')
    o.estimation.number_of_observations = linea{2};
end

linea = textscan(txt{1}{3}, '%s %d');
if isequal(linea{1}{1}, 'nefobs')
    o.estimation.effective_number_of_observations = linea{2};
end

linea = textscan(txt{1}{5}, '%s %d');
if isequal(linea{1}{1}, 'np')
    o.estimation.number_of_estimated_parameters = linea{2};
end

% TODO Check the meaning of lnlkhd (versus mle)
% linea = textscan(txt{1}{8}, '%s %d');
% if isequal(linea{1}{1}, 'lnlkhd')
%     o.estimation.log_likelihood = linea{2};
% end

linea = textscan(txt{1}{9}, '%s %d');
if isequal(linea{1}{1}, 'aic')
    o.estimation.information_criteria.Akaike = linea{2};
end

linea = textscan(txt{1}{10}, '%s %d');
if isequal(linea{1}{1}, 'Aicc')
    % Akaike with correction for finite sample size.
    o.estimation.information_criteria.CorrectedAkaike = linea{2};
end

linea = textscan(txt{1}{11}, '%s %d');
if isequal(linea{1}{1}, 'hnquin')
    o.estimation.information_criteria.HannanQuinn = linea{2};
end

linea = textscan(txt{1}{12}, '%s %d');
if isequal(linea{1}{1}, 'bic')
    o.estimation.information_criteria.Schwarz = linea{2};
end


%@test:1
%$ try
%$    y = dseries([0; 0], '1938Q3', 'y')
%$    e = dseries(randn(201,1),'1938Q4','e');
%$    from from 1939Q1 to 1988Q4 do y(t) = .8*y(t-1) - .2*y(t-2) + e(t) - .15*e(t-1)
%$    model = arima(y, '(2,0,1)');
%$    estimate(model);
%$ catch
%$    t(1) = false;
%$ end
%$
%$ T = all(t);
%@eof:1
