classdef arima<handle % --*-- Unitary tests --*--

% Class for ARIMA models (interface to X13).

% Copyright (C) 2017-2022 Dynare Team
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

properties
    y      = [];         % dseries object with a single variable.
    p      = [];         % Number of lags on the autoregressive part.
    d      = [];         % Order of differenciation.
    q      = [];         % Number of lags on the moving average part.
    P      = [];         % Seasonal component autoregressive part number of lags.
    D      = [];         % Seasonal component order of differenciation.
    Q      = [];         % Seasonal component moving average part number of lags.
    S      = [];         % Seasonal component period.
    ar     = [];         % Autoregressive parameters.
    ma     = [];         % Moving arverage parameters.
    AR     = [];         % Seasonal component autoregressive parameters.
    MA     = [];         % Seasonal component moving average parameters.
    ar_std = [];         % Autoregressive parameters estimator std.
    ma_std = [];         % Moving arverage parameters estimator std.
    AR_std = [];         % Seasonal component autoregressive parameters estimator std.
    MA_std = [];         % Seasonal component moving average parameters estimator std.
    sigma  = [];         % Standard deviation of the schock.
    estimation = [];     % Structure gathering informations related to the estimation of the model.
end

methods
        function o = arima(y, model)
        % Constructor for the arma class.
        %
        % INPUTS
        % - y      [dseries]    Data.
        % - model  [string]     Specification of the model of the form '(p, d, q)(P,D,Q)S', See X-13ARIMA-SEATS manual.
        %
        % OUPUTS
        % - o      [arima]      ARIMA model object.
        switch nargin
          case 0
            % Return empty object.
            o.y      = [];               % dseries object with a single variable.
            o.p      = [];               % Number of lags on the autoregressive part.
            o.d      = [];               % Order of differenciation.
            o.q      = [];               % Number of lags on the moving average part.
            o.P      = [];               % Seasonal component autoregressive part number of lags.
            o.D      = [];               % Seasonal component order of differenciation.
            o.Q      = [];               % Seasonal component moving average part number of lags.
            o.S      = [];               % Seasonal component period.
            o.ar     = [];               % Autoregressive parameters.
            o.ma     = [];               % Moving arverage parameters.
            o.AR     = [];               % Seasonal component autoregressive parameters.
            o.MA     = [];               % Seasonal component moving average parameters.
            o.ar_std = [];               % Autoregressive parameters estimator std.
            o.ma_std = [];               % Moving arverage parameters estimator std.
            o.AR_std = [];               % Seasonal component autoregressive parameters estimator std.
            o.MA_std = [];               % Seasonal component moving average parameters estimator std.
            o.sigma  = [];               % Standard deviation of the schock.
            o.estimation = [];           % Structure gathering informations related to the estimation of the model.
            return
          case 2
            if ~isdseries(y)
                error('arima::WrongInputArguments', 'First input argument must be a dseries object!')
            end
            if ~ischar(model)
                error('arima::WrongInputArguments', 'Second input argument must be a string!')
            end
            o.y = y;
            o.estimation = struct();
            % Read the description of the ARIMA model.
            model = regexprep(model,'(\s)',''); % Removes all spaces.
            description = regexp(model, '(\([0-9],[0-9],[0-9]\)([0-9]+)?)', 'tokens');
            % First cell is the non seasonal component.
            ns_arima = description{1}{1};
            ns_arima_specification = regexp(ns_arima, '([0-9]*)', 'tokens');
            o.p = str2num(ns_arima_specification{1}{1});
            o.d = str2num(ns_arima_specification{2}{1});
            o.q = str2num(ns_arima_specification{3}{1});
            % Set default values for parameters and estimate std.
            if o.p
                o.ar = zeros(o.p, 1);
                o.ar_std = zeros(o.p, 1);
            else
                o.ar = [];
                o.ar_std = [];
            end
            if o.q
                o.ma = zeros(o.q, 1);
                o.ma_std = zeros(o.q, 1);
            else
                o.ma = [];
                o.ma_std = [];
            end
            % Following cells are the ARIMA models on the seasonal components.
            number_of_seasonal_components = length(description)-1;
            if number_of_seasonal_components
                o.P = zeros(number_of_seasonal_components, 1);
                o.D = zeros(number_of_seasonal_components, 1);
                o.Q = zeros(number_of_seasonal_components, 1);
                o.S = zeros(number_of_seasonal_components, 1);
                for i=1:number_of_seasonal_components
                    s_arima = description{i+1}{1};
                    s_arima_specification = regexp(s_arima, '([0-9]*)', 'tokens');
                    if isequal(i, 1) && isequal(length(s_arima_specification), 3)
                        o.S(i) = y.init.freq;
                    else
                        o.S(i) = str2num(s_arima_specification{4}{1});
                    end
                    o.P(i) = str2num(s_arima_specification{1}{1});
                    o.D(i) = str2num(s_arima_specification{2}{1});
                    o.Q(i) = str2num(s_arima_specification{3}{1});
                end
            end
            % Set default values for parameters and estimate std.
            o.AR = {};
            o.MA = {};
            o.AR_std = {};
            o.MA_std = {};
            for i=1:number_of_seasonal_components
                if o.P(i)
                    o.AR{i} = zeros(o.P(i), 1);
                    o.AR_std{i} = zeros(o.P(i), 1);
                else
                    o.AR{i} = [];
                    o.AR_std{i} = [];
                end
                if o.Q(i)
                    o.MA{i} = zeros(o.Q(i), 1);
                    o.MA_std{i} = zeros(o.Q(i), 1);
                else
                    o.MA{i} = [];
                    o.MA_std{i} = [];
                end
            end
            % Set default value for the size of the innovation.
            o.sigma = std(y.data);
          otherwise
            error('arima::WrongInputArguments', 'Two input argument are mandatory!')
        end
        end % arima
end % methods
end % classdef

%@test:1
%$ try
%$    data = dseries(cumsum(randn(200, 1)), '1990Q1', 'Output');
%$    arma = arima(data, '(1,1,1)(0,0,1)');
%$    t(1) = true;
%$ catch
%$    t(1) = false;
%$ end
%$
%$ T = all(t);
%@eof:1
