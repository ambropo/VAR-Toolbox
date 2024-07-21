function printstart(fid, period) % --*-- Unitary tests --*--

% Copyright (C) 2017-2021 Dynare Team
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

if ~ismember(period.freq, [1 4 12])
    error('x13:printstart: Only monthly, quaterly or annual data are allowed (option start)!')
end

switch period.freq
  case 12
    ListOfMonths = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
    fprintf(fid, ' start = %i.%s\n', period.year, ListOfMonths{period.subperiod});
  case 4
    fprintf(fid, ' start = %i.%i\n', period.year, period.subperiod);
  case 1
    fprintf(fid, ' start = %i\n', period.year);
  otherwise
    error('x13:regression: This frequency is not available in X-13 class.')
end

%@test:1
%$ try
%$     per = dates(52,1996,1);
%$     fid = fopen('test.spc', 'w');
%$     printstart(fid,per);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:1