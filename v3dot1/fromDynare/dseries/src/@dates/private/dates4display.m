function str = dates4display(o, name, max_number_of_elements) % --*-- Unitary tests --*--

% Converts a list object to a string.
%
% INPUTS
% - o                      [list]     A dates object to be displayed.
% - name                   [string]   Name of the dates object o.
% - max_number_of_elements [integer]  Maximum number of elements displayed.
%
% OUTPUTS
% - str  [string] Representation of the dates object as a string.

% Copyright (C) 2014-2021 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if isempty(o)
    str = sprintf('%s is an empty dates object.\n', name);
    return
end

str = sprintf('%s = <dates: ', name);

if o.length()<=max_number_of_elements
    % All the elements are displayed
    for i=1:length(o)-1
        str = sprintf('%s%s, ', str, date2string(o.time(i), o.freq));
    end
else
    % Only display four elements (two first and two last)
    for i=1:2
        str = sprintf('%s%s, ', str, date2string(o.time(i), o.freq));
    end
    str = sprintf('%s%s, ', str, '...');
    str = sprintf('%s%s, ', str, date2string(o.time(o.length()-1), o.freq));
end
str = sprintf('%s%s>\n', str, date2string(o.time(o.length()), o.freq));

%@test:1
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     toto = dates();
%$     str = dates4display(toto, 'toto', 5);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     expected_str_1 = sprintf('toto is an empty dates object.\\n');
%$     try
%$         t(2) = dassert(str, expected_str_1);
%$     catch
%$         t(2) = false;
%$     end
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:1

%@test:2
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     toto = dates('1950Q1'):dates('1950Q2');
%$     str = dates4display(toto, 'toto', 5);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     expected_str_2 = sprintf('toto = <dates: 1950Q1, 1950Q2>\\n');
%$     try
%$         t(2) = dassert(str, expected_str_2);
%$     catch
%$         t(2) = false;
%$     end
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:2

%@test:3
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     toto = dates('1950Q1'):dates('1951Q1');
%$     str = dates4display(toto, 'toto', 4);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     expected_str_3 = sprintf('toto = <dates: 1950Q1, 1950Q2, ..., 1950Q4, 1951Q1>\\n');
%$     try
%$         t(2) = dassert(str, expected_str_3);
%$     catch
%$         t(2) = false;
%$     end
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:3

%@test:4
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     toto = dates('1950Q1'):dates('1951Q1');
%$     str = dates4display(toto, 'toto', 6);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     expected_str_4 = sprintf('toto = <dates: 1950Q1, 1950Q2, 1950Q3, 1950Q4, 1951Q1>\\n');
%$     try
%$         t(2) = dassert(str, expected_str_4);
%$     catch
%$         t(2) = false;
%$     end
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:4
