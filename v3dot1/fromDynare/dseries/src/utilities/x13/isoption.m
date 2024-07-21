function b = isoption(command, option) % --*-- Unitary tests --*--

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

switch command
  case 'arima'
    b = ismember(option, {'ar', 'ma', 'model', 'print', 'save', 'title'});
  case 'automdl'
    b = ismember(option, {'acceptdefault', 'checkmu', 'diff', 'ljungboxlimit', 'maxdiff', 'maxorder', ...
                        'mixed', 'print', 'savelog', 'armalimit', 'balanced', 'exactdiff', 'fcstlim', ...
                        'hrinitial', 'reducecv', 'rejectfcst', 'urfinal'});
  case 'regression'
    b = ismember(option, {'aicdiff', 'aictest', 'chi2test', 'chi2testcv', ...
                        'print', 'save', 'pvaictest', 'savelog', 'start', ...
                        'tlimit', 'user', 'usertype', 'variables', 'b', ...
                        'centeruser', 'eastermeans', 'noapply', 'tcrate'});
  case 'transform'
    b = ismember(option, {'adjust', 'aicdiff', 'function', 'mode', 'name', ...
                        'power', 'precision', 'print', 'save', 'savelog', ...
                        'start', 'title', 'type'});
  case 'estimate'
    b = ismember(option, {'exact', 'maxiter', 'outofsample', 'print', 'save', 'savelog', 'tol', 'file', 'fix'});
  case 'outlier'
    b = ismember(option, {'critical', 'lsrun', 'method', 'print', 'save', ...
                        'savelog', 'span', 'types', 'almost', 'tcrate'});
  case 'forecast'
    b = ismember(option, {'exclude', 'lognormal', 'maxback', 'maxlead', 'print', 'save', 'probability'});
  case 'check'
    b = ismember(option, {'maxlag', 'print', 'save', 'qtype', 'savelog'});
  case 'x11'
    b = ismember(option, {'appendbcst', 'appendfcst', 'final', 'mode', 'print', 'save', ...
                        'savelog', 'seasonalma', 'sigmalim', 'title', 'trendma', 'type', ...
                        'calendarsigma', 'centerseasonal', 'keepholiday', 'print1stpass', ...
                        'sfshort', 'sigmavec', 'trendic', 'true7term', 'excludefcst'});
  case 'force'
    b = ismember(option, {'print', 'save', 'lambda', 'mode', 'rho', 'round', 'start', 'target', 'type', ...
                         'usefcst', 'indforce'});
  case 'history'
    b = ismember(option, {'print', 'save', 'endtable', 'estimates', 'fixmdl', 'fixreg', 'fstep', 'sadjlags', ...
                         'savelog', 'start', 'target', 'trendlags', 'fixx11reg', 'outlier', 'outlierwin', ...
                         'refresh', 'transformfcst', 'x11outlier'});
  case 'metadata'
    b = ismember(option, {'keys', 'values'});
  case 'identify'
    b = ismember(option, {'print', 'save', 'diff', 'maxlag', 'sdiff'});
  case 'pickmdl'
    b = ismember(option, {'print', 'bcstlim', 'fcstlim', 'file', 'identify', 'method', 'mode', 'outofsample', ...
                          'overdiff', 'qlim', 'savelog'});
  case 'seats'
    b = ismember(option, {'print', 'save', 'appendfcst', 'finite', 'hpcycle', 'noadmiss', 'out', 'printphtrf', 'qmax', ...
                         'savelog', 'statseas', 'tabtables', 'bias', 'epsiv', 'epsphi', 'hplan', 'imean', ...
                         'maxit', 'rmod', 'xl'});
  case 'slidingspans'
    b = ismember(option, {'print', 'save', 'cutchng', 'cutseas', 'cuttd', 'fixmdl', 'fixreg', 'length', 'numspans', ...
                         'outlier', 'savelog', 'start', 'additivesa', 'fixx11reg', 'x11outlier'});
  case 'spectrum'
    b = ismember(option, {'print', 'save', 'logqs', 'qcheck', 'savelog', 'start', 'tukey120', 'decibel', 'difference', ...
                         'maxar', 'peaxwidth', 'series', 'siglevel', 'type'});
  case 'x11regression'
    b = ismember(option, {'print', 'save', 'aicdiff', 'aictest', 'critical', 'data', 'file', 'format', 'outliermethod', ...
                         'outlierspan', 'prior', 'savelog','sigma', 'span', 'start', 'tdprior', 'user', ...
                         'usertype', 'variables', 'almost', 'b', 'centeruser', 'eastermeans', 'forcecal', ...
                         'noapply', 'reweight', 'umdata', 'umfile', 'umformat', 'umname', 'umprecision', ...
                         'umstart', 'umtrimzero'});
  otherwise
    error('x13:isoption: Unknown block!')
end

%@test:1
%$ try
%$     b = isoption('unicorn','horse sounds');
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ b = isoption('arima','ar');
%$ c = ~isoption('arima','unicorn');
%$ t = [b;c];
%$ T = all(t);
%@eof:2