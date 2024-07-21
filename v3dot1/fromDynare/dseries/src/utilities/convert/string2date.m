function date = string2date(a) % --*-- Unitary tests --*--

% Copyright © 2013-2021 Dynare Team
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

date = struct('freq', NaN, 'time', NaN);

if ~ischar(a) || ~isdate(a)
    error('dates::string2date: Input must be a string that can be interpreted as a date!');
end

if isyearly(a)
    idt = 1:(regexp(a,'[AaYy]')-1);
    date.freq = 1;
    date.time = str2double(a(idt));
    return
end

if isbiannual(a)
    period = cellfun(@str2double, strsplit(a, {'H','h','S','s'}));
    date.freq = 2;
    date.time = period(1)*2+period(2);
    return
end

if isquarterly(a)
    period = cellfun(@str2double, strsplit(a, {'Q','q'}));
    date.freq = 4;
    date.time = period(1)*4+period(2);
    return
end

if ismonthly(a)
    period = cellfun(@str2double, strsplit(a, {'M','m'}));
    date.freq = 12;
    date.time = period(1)*12+period(2);
    return
end

if isdaily(a)
    date.freq = 365;
    date.time(1) = datenum(a, 'yyyy-mm-dd');
    return
end

return

%@test:1
% Define some dates
date_1 = '1950Q2';
date_2 = '1950m10';
date_4 = '1950a';
date_5 = '1967y';
date_6 = '2009A';
date_7 = '2009H1';
date_8 = '2009h2';
date_9 = '2009-01-01';

% Define expected results.
e_date_1 = 1950*4+2;
e_freq_1 = 4;
e_date_2 = 1950*12+10;
e_freq_2 = 12;
e_date_4 = 1950;
e_freq_4 = 1;
e_date_5 = 1967;
e_freq_5 = 1;
e_date_6 = 2009;
e_freq_6 = 1;
e_date_7 = 2009*2+1;
e_freq_7 = 2;
e_date_8 = 2009*2+2;
e_freq_8 = 2;
e_date_9 = 733774;
e_freq_9 = 365;

% Call the tested routine.
d1 = string2date(date_1);
d2 = string2date(date_2);
d4 = string2date(date_4);
d5 = string2date(date_5);
d6 = string2date(date_6);
d7 = string2date(date_7);
d8 = string2date(date_8);
d9 = string2date(date_9);

% Check the results.
t(1) = isequal(d1.time,e_date_1);
t(2) = isequal(d2.time,e_date_2);
t(3) = isequal(d4.time,e_date_4);
t(4) = isequal(d5.time,e_date_5);
t(5) = isequal(d6.time,e_date_6);
t(6) = isequal(d7.time,e_date_7);
t(7) = isequal(d8.time,e_date_8);
t(8) = isequal(d1.freq,e_freq_1);
t(9) = isequal(d2.freq,e_freq_2);
t(10) = isequal(d4.freq,e_freq_4);
t(11)= isequal(d5.freq,e_freq_5);
t(12)= isequal(d6.freq,e_freq_6);
t(13)= isequal(d7.freq,e_freq_7);
t(14)= isequal(d8.freq,e_freq_8);
t(15)= isequal(d9.freq,e_freq_9);
t(16)= isequal(d9.time(1),e_date_9(1));
T = all(t);
%@eof:1