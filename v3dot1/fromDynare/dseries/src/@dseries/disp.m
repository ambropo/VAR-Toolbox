function disp(o)

% Overloads disp method.
%
% INPUTS
% - o  [dseries]   Object to be displayed.
%
% OUTPUTS
% None

% Copyright (C) 2011-2017 Dynare Team
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

vspace = ' ';

if ~vobs(o)
    disp(vspace)
    disp([inputname(1) ' is an empty dseries object.'])
    return
end

separator = repmat(' | ', nobs(o)+1,1);
TABLE = ' ';
for t=1:nobs(o)
    TABLE = char(TABLE, date2string(o.dates(t)));
end
for i = 1:vobs(o)
    TABLE = horzcat(TABLE,separator);
    tmp = o.name{i};
    for t=1:nobs(o)
        tmp = char(tmp,num2str(o.data(t,i)));
    end
    TABLE = horzcat(TABLE, tmp);
end
disp(vspace)
disp([inputname(1) ' is a dseries object:'])
disp(vspace);
disp(TABLE);
disp(vspace);