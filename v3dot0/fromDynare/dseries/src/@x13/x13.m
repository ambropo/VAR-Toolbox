classdef x13<handle % --*-- Unitary tests --*--

% Class for X13 toolbox.

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

properties
    y             = [];  % dseries object with a single variable.
    x             = [];  % dseries object with an arbitrary number of variables (to be used in the REGRESSION block).
    arima         = [];  % ARIMA model.
    automdl       = [];  % ARIMA model selection.
    regression    = [];  % Regression command, specification for including regression variables in a regARIMA model, or for specifying regression variables whose effects are to be removed by the identify spec to aid ARIMA model identification.
    estimate      = [];  % Estimation command, estimates the regARIMA model specified with the regression and arima commands.
    transform     = [];  % Transform command, transforms or adjusts the series prior to estimating a regARIMA model.
    outlier       = [];  % Outlier command, performs automatic detection of additive (point) outliers, temporary change outliers, level shifts, or any combination of the three using the specified model.
    forecast      = [];  % Forecast command, forecasts and/or backcasts the time series y using the estimated model.
    check         = [];  % Check command, produces statistics for diagnostic checking of residuals from the estimated model.
    x11           = [];  % X11 command, invokes seasonal adjustment by an enhanced version of the methodology of the Census Bureau X-11 and X-11Q program.
    force         = [];  % Force command, allow users to force yearly totals of the seasonally adjusted series to equal those of the original series for convenience.
    history       = [];  % History command, requests a sequence of runs from a sequence of truncated versions of the time series.
    metadata      = [];  % Metadata command, allows users to insert metadata into the diagnostic summary file.
    identify      = [];  % Identify command, produces tables and line printer plots of sample ACFs and PACFs for identifying the ARIMA part of a regARIMA model.
    pickmdl       = [];  % Pickmdl command, automatic model selection procedure for the ARIMA part of the regARIMA model.
    seats         = [];  % Seats command, invokes the production of model based signal extraction using SEATS, a seasonal adjustment program developed by Victor Gomez and Agustin Maravall at the Bank of Spain.
    slidingspans  = [];  % Slidingspans command, compares different features of seasonal adjustment output from overlapping subspans of the time series data.
    spectrum      = [];  % Spectrum command, spectrum diagnostics to detect seasonality or trading day effects in monthly series.
    x11regression = [];  % X11Regression command, estimates calendar effects by regression modeling of the irregular component with predefined or user-defined regressors.
    results       = [];  % Estimation results.
    commands      = {};  % List of commands.
end

methods
    function o = x13(y, x)
    % Constructor for the x13 class.
    %
    % INPUTS
    % - y      [dseries]    Data.
    %
    % OUPUTS
    % - o      [x13]        Empty object except for the data.
        if ~nargin
            o.y = dseries();
            o.x = dseries();
            o.arima = setdefaultmember('arima');
            o.automdl = setdefaultmember('automdl');
            o.regression = setdefaultmember('regression');
            o.estimate = setdefaultmember('estimate');
            o.transform = setdefaultmember('transform');
            o.outlier = setdefaultmember('outlier');
            o.forecast = setdefaultmember('forecast');
            o.check = setdefaultmember('check');
            o.x11 = setdefaultmember('x11');
            o.force = setdefaultmember('force');
            o.history = setdefaultmember('history');
            o.metadata = setdefaultmember('metadata');
            o.identify = setdefaultmember('identify');
            o.pickmdl = setdefaultmember('pickmdl');
            o.seats = setdefaultmember('seats');
            o.slidingspans = setdefaultmember('slidingspans');
            o.spectrum = setdefaultmember('spectrum');
            o.x11regression = setdefaultmember('x11regression');
            o.results = struct();
            o.commands = {};
            return
        end
        if isdseries(y)
            if isequal(y.vobs, 1)
                o.y = y;
            else
                error('x13:: Wrong input argument (a dseries object with a single variable is expected)!')
            end
        else
            error('x13:: Wrong input argument (a dseries object is expected)!')
        end
        if nargin>1
            if isdseries(x)
                o.x = x;
            else
                error('x13:: Wrong input argument (a dseries object is expected)!')
            end
        else
            o.x = dseries();
        end
        % Initialize other members (they are empty initially and must be set by calling methods)
        o.arima = setdefaultmember('arima');
        o.automdl = setdefaultmember('automdl');
        o.regression = setdefaultmember('regression');
        o.estimate = setdefaultmember('estimate');
        o.transform = setdefaultmember('transform');
        o.outlier = setdefaultmember('outlier');
        o.forecast = setdefaultmember('forecast');
        o.check = setdefaultmember('check');
        o.x11 = setdefaultmember('x11');
        o.force = setdefaultmember('force');
        o.history = setdefaultmember('history');
        o.metadata = setdefaultmember('metadata');
        o.identify = setdefaultmember('identify');
        o.pickmdl = setdefaultmember('pickmdl');
        o.seats = setdefaultmember('seats');
        o.slidingspans = setdefaultmember('slidingspans');
        o.spectrum = setdefaultmember('spectrum');
        o.x11regression = setdefaultmember('x11regression');
        o.results = struct();
        o.commands = {};
    end
end

end

%@test:1
%$
%$ try
%$     series = dseries(rand(100,2),'1999M1');
%$     o = x13(series);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     series = rand(100,2);
%$     o = x13(series);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ try
%$     y = dseries(rand(100,1),'1999M1');
%$     x = rand(100,2);
%$     o = x13(y,x);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:3