function checkcommandcompatibility(o, comm) % --*-- Unitary tests --*--

% Checks for compatibility of X13 commands.

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

switch comm
  case 'arima'
    if ismember('automdl', o.commands)
        error('x13:arima: ARIMA command is not compatible with AUTOMDL command!')
    elseif ismember('pickmdl', o.commands)
        error('x13:arima: ARIMA command is not compatible with PICKMDL command!')
    end
  case 'automdl'
    if ismember('arima', o.commands)
        error('x13:automdl: AUTOMDL command is not compatible with ARIMA command!')
    elseif ismember('pickmdl', o.commands)
        error('x13:automdl: AUTOMDL command is not compatible with PICKMDL command!')
    end
  case 'pickmdl'
    if ismember('arima', o.commands)
        error('x13:pickmdl: PICKMDL command is not compatible with ARIMA command!')
    elseif ismember('automdl', o.commands)
        error('x13:pickmdl: PICKMDL command is not compatible with AUTOMDL command!')
    end
  otherwise
end

%@test:1
%$ t = zeros(2,1);
%$
%$ series = dseries(rand(100,1),'1999M1');
%$ o = x13(series);
%$ o.arima('save','(d11)');
%$
%$ try
%$     o.automdl('savelog','amd');
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ try
%$     o.pickmdl('savelog','amd');
%$     t(2) = false;
%$ catch
%$     t(2) = true;
%$ end
%$
%$ T = all(t);
%@eof:1