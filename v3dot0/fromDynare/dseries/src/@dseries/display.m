function display(o)

% Overloads display method.
%
% INPUTS
% - o  [dseries]   Object to be displayed.
%
% OUTPUTS
% None
%
% REMARKS
% Contray to the disp method, the whole dseries object is not displayed if the number of
% observations is greater than 40 and if the number of variables is greater than 10.

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

TABLE = ' ';

if vobs(o)<=10
    if nobs(o)<=40
        separator = repmat(' | ', nobs(o)+1,1);
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
    else
        n = 10;
        separator = repmat(' | ',2*n+3,1);
        for t=1:n
            TABLE = char(TABLE, date2string(o.dates(t)));
        end
        TABLE = char(TABLE,vspace);
        for t = nobs(o)-n:nobs(o)
            TABLE = char(TABLE, date2string(o.dates(t)));
        end
        for i=1:vobs(o)
            TABLE = horzcat(TABLE,separator);
            tmp = o.name{i};
            for t=1:10
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            tmp = char(tmp,vspace);
            for t=nobs(o)-10:nobs(o)
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            TABLE = horzcat(TABLE, tmp);
        end
    end
else
    m = 4;
    if nobs(o)<=40
        separator = repmat(' | ', nobs(o)+1,1);
        for t=1:nobs(o)
            TABLE = char(TABLE, date2string(o.dates(t)));
        end
        for i = 1:m
            TABLE = horzcat(TABLE,separator);
            tmp = o.name{i};
            for t=1:nobs(o)
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            TABLE = horzcat(TABLE, tmp);
        end
        TABLE = horzcat(TABLE, separator, repmat(' ... ', nobs(o)+1,1));
        for i = vobs(o)-m+1:vobs(o)
            TABLE = horzcat(TABLE,separator);
            tmp = o.name{i};
            for t=1:nobs(o)
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            TABLE = horzcat(TABLE, tmp);
        end
    else
        n = 10;
        separator = repmat(' | ',2*n+3,1);
        for t=1:n
            TABLE = char(TABLE, date2string(o.dates(t)));
        end
        TABLE = char(TABLE,vspace);
        for t = nobs(o)-n:nobs(o)
            TABLE = char(TABLE, date2string(o.dates(t)));
        end
        for i=1:m
            TABLE = horzcat(TABLE,separator);
            tmp = o.name{i};
            for t=1:10
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            tmp = char(tmp,vspace);
            for t=nobs(o)-10:nobs(o)
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            TABLE = horzcat(TABLE, tmp);
        end
        TABLE = horzcat(TABLE, separator, repmat(' ... ', 2*n+3,1));
        for i=vobs(o)-m+1:vobs(o)
            TABLE = horzcat(TABLE,separator);
            tmp = o.name{i};
            for t=1:10
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            tmp = char(tmp,vspace);
            for t=nobs(o)-10:nobs(o)
                tmp = char(tmp,num2str(o.data(t,i)));
            end
            TABLE = horzcat(TABLE, tmp);
        end
    end
end
disp(vspace)
disp([inputname(1) ' is a dseries object:'])
disp(vspace);
if ~isempty(strtrim(TABLE))
    disp(TABLE);
    disp(vspace);
end
