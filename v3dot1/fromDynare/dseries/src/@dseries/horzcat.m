function o = horzcat(varargin) % --*-- Unitary tests --*--

% Overloads horzcat method for dseries objects.
%
% INPUTS
%  o o1    dseries object.
%  o o2    dseries object.
%  o ...
%
% OUTPUTS
%  o o     dseries object.
%
% EXAMPLE 1
%  If o1, o2 and o3 are dseries objects the following syntax:
%
%    o = [o1, o2, o3] ;
%
%  defines a dseries object o containing the variables appearing in o1, o2 and o3.
%
% REMARKS
%  o o1, o2, ... must not have common variables.

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

switch nargin
  case 0
    o = dseries();
  case 1
    o = varargin{1};
  otherwise
    o = concatenate(copy(varargin{1}), copy(varargin{2}));
    if nargin>2
        o = horzcat(o, varargin{3:end});
    end
end

function a = concatenate(b,c)
[n,message] = common_strings_in_cell_arrays(b.name, c.name);
if isempty(b)
    a = c;
    return
end
if isempty(c)
    a = b;
    return
end
if n
    error(['dseries::horzcat: I cannot concatenate dseries objects with common variable names (' message ')!'])
end
if ~isequal(frequency(b),frequency(c))
    error('dseries::horzcat: All time series objects must have common frequency!')
else
    a = dseries();
end
d_nobs_flag = 0;
if ~isequal(nobs(b),nobs(c))
    d_nobs_flag = 1;
end
d_init_flag = 0;
if ~isequal(firstdate(b),firstdate(c))
    d_init_flag = 1;
end
a.ops = vertcat(b.ops,c.ops);
a.name = vertcat(b.name,c.name);
a.tex  = vertcat(b.tex,c.tex);
btagnames = fieldnames(b.tags);
ctagnames = fieldnames(c.tags);
atagnames = union(btagnames, ctagnames);
if isempty(atagnames)
    a.tags = struct();
else
    for i=1:length(atagnames)
        if ismember(atagnames{i}, btagnames) && ismember(atagnames{i}, ctagnames)
            a.tags.(atagnames{i}) = vertcat(b.tags.(atagnames{i}), b.tags.(atagnames{i}));
        elseif ismember(atagnames{i}, btagnames)
            a.tags.(atagnames{i}) = vertcat(b.tags.(atagnames{i}), cell(vobs(c), 1));
        elseif ismember(atagnames{i}, ctagnames)
            a.tags.(atagnames{i}) = vertcat(cell(vobs(b), 1), c.tags.(atagnames{i}));
        else
            error('dseries::horzcat: This is a bug!')
        end
    end
end

if ~( d_nobs_flag(1) || d_init_flag(1) )
    a.data = [b.data,c.data];
    a.dates = b.dates;
else
    nobs_b = nobs(b);
    nobs_c = nobs(c);
    if firstdate(b)<=firstdate(c)
        if firstdate(b)<firstdate(c)
            c.data = [NaN(firstdate(c)-firstdate(b), vobs(c)); c.data];
        end
    else
        b.data = [NaN(firstdate(b)-firstdate(c), vobs(b)); b.data];
    end
    b_last_date = firstdate(b)+nobs_b;
    c_last_date = firstdate(c)+nobs_c;
    if b_last_date<c_last_date
        b.data = [b.data; NaN(c_last_date-b_last_date, vobs(b))];
    elseif b_last_date>c_last_date
        c.data = [c.data; NaN(b_last_date-c_last_date, vobs(c))];
    end

    fillerdates = dates();
    if max(c.dates) < min(b.dates)
        fillerdates = max(c.dates):min(b.dates);
    end
    if max(b.dates) < min(c.dates)
        fillerdates = max(b.dates):min(c.dates);
    end

    if isempty(fillerdates)
        hd = [b.dates, c.dates];
    else
        hd = [b.dates, fillerdates, c.dates];
    end

    a.data = [b.data, c.data];
    a.dates = sort(unique(hd));
end

%@test:1
%$ % Define a data set.
%$ A = [transpose(1:10),2*transpose(1:10)];
%$ B = [transpose(1:10),2*transpose(1:10)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define expected results.
%$ e.init = dates(1,1);
%$ e.freq = 1;
%$ e.name = {'A1';'A2';'B1';'B2'};
%$ e.data = [A,B];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,[],A_name,[]);
%$ ts2 = dseries(B,[],B_name,[]);
%$
%$ % Call the tested method.
%$ ts3 = [ts1,ts2];
%$
%$ % Check the results.
%$
%$ t(1) = dassert(ts3.init,e.init);
%$ t(2) = dassert(ts3.freq,e.freq);
%$ t(3) = dassert(ts3.data,e.data);
%$ t(4) = dassert(ts3.name,e.name);
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a data set.
%$ A = [transpose(1:10),2*transpose(1:10)];
%$ B = [transpose(5:12),2*transpose(5:12)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define initial date
%$ A_init = 2001;
%$ B_init = 2005;
%$
%$ % Define expected results.
%$ e.init = dates('2001Y');
%$ e.freq = 1;
%$ e.name = {'A1';'A2';'B1';'B2'};
%$ e.data = [ [A; NaN(2,2)], [NaN(4,2); B]];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,A_init,A_name,[]);
%$ ts2 = dseries(B,B_init,B_name,[]);
%$
%$ % Call the tested method.
%$ ts3 = [ts1,ts2];
%$
%$ % Check the results.
%$ t(1) = dassert(ts3.init,e.init);
%$ t(2) = dassert(ts3.freq,e.freq);
%$ t(3) = dassert(ts3.data,e.data);
%$ t(4) = dassert(ts3.name,e.name);
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define a data set.
%$ A = [transpose(1:7),2*transpose(1:7)];
%$ B = [transpose(5:11),2*transpose(5:11)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define initial date
%$ A_init = '1950Q1';
%$ B_init = '1950Q3';
%$
%$ % Define expected results.
%$ e.freq = 4;
%$ e.init = dates('1950Q1');
%$ e.name = {'A1';'A2';'B1';'B2'};
%$ e.data = [ [A; NaN(2,2)], [NaN(2,2); B]];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,A_init,A_name,[]);
%$ ts2 = dseries(B,B_init,B_name,[]);
%$
%$ % Call the tested method.
%$ ts3 = [ts1,ts2];
%$
%$ % Check the results.
%$ t(1) = dassert(ts3.init,e.init);
%$ t(2) = dassert(ts3.freq,e.freq);
%$ t(3) = dassert(ts3.data,e.data);
%$ t(4) = dassert(ts3.name,e.name);
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define a data set.
%$ A = [transpose(1:7),2*transpose(1:7)];
%$ B = [transpose(5:9),2*transpose(5:9)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define initial date
%$ A_init = '1950Q1';
%$ B_init = '1950Q3';
%$
%$ % Define expected results.
%$ e.init = dates(A_init);
%$ e.freq = 4;
%$ e.name = {'A1';'A2';'B1';'B2'};
%$ e.data = [ A, [NaN(2,2); B]];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,A_init,A_name,[]);
%$ ts2 = dseries(B,B_init,B_name,[]);
%$
%$ % Call the tested method.
%$ ts3 = [ts1,ts2];
%$
%$ % Check the results.
%$ t(1) = dassert(ts3.init,e.init);
%$ t(2) = dassert(ts3.freq,e.freq);
%$ t(3) = dassert(ts3.data,e.data);
%$ t(4) = dassert(ts3.name,e.name);
%$ T = all(t);
%@eof:4

%@test:5
%$ % Define a data set.
%$ A = [transpose(1:10),2*transpose(1:10)];
%$ B = [transpose(1:10),3*transpose(1:10)];
%$ C = [transpose(1:10),4*transpose(1:10)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'B1';'B2'};
%$ C_name = {'C1';'C2'};
%$
%$ % Define expected results.
%$ e.init = dates(1,1);
%$ e.freq = 1;
%$ e.name = {'A1';'A2';'B1';'B2';'C1';'C2'};
%$ e.data = [A,B,C];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,[],A_name,[]);
%$ ts2 = dseries(B,[],B_name,[]);
%$ ts3 = dseries(C,[],C_name,[]);
%$
%$ % Call the tested method.
%$ ts4 = [ts1,ts2,ts3];
%$
%$ % Check the results.
%$ t(1) = dassert(ts4.init,e.init);
%$ t(2) = dassert(ts4.freq,e.freq);
%$ t(3) = dassert(ts4.data,e.data);
%$ t(4) = dassert(ts4.name,e.name);
%$ T = all(t);
%@eof:5

%@test:6
%$ % Define a data set.
%$ A = [transpose(1:10),2*transpose(1:10)];
%$ B = [transpose(1:10),2*transpose(1:10)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'B1';'A2'};
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,[],A_name,[]);
%$ ts2 = dseries(B,[],B_name,[]);
%$
%$ % Call the tested method.
%$ try
%$   ts3 = [ts1,ts2];
%$   t = 0;
%$ catch
%$   t = 1;
%$ end
%$
%$ T = t;
%@eof:6

%@test:7
%$ % Define X
%$ X = randn(30,2);
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries();
%$ ts2 = dseries(randn(30,2),'1950Q2');
%$
%$ % Call the tested method.
%$ try
%$   ts3 = [ts1,ts2];
%$   t = 1;
%$ catch
%$   t = 0;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(ts3.freq,4);
%$   t(3) = dassert(ts3.data,X);
%$   t(4) = dassert(ts3.dates(1),dates('1950Q2'));
%$ end
%$
%$ T = t;
%@eof:7

%@test:8
%$ % Define a data set.
%$ A = [transpose(1:10),2*transpose(1:10)];
%$ B = [transpose(1:10),2*transpose(1:10)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'B1';'B2'};
%$
%$ % Define expected results.
%$ e.init = dates(1,1);
%$ e.freq = 1;
%$ e.name = {'A1';'A2';'B1';'B2'};
%$ e.data = [A,B];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,[],A_name,[]);
%$ ts2 = dseries(B,[],B_name,[]);
%$ ts1.tag('t1');
%$ ts1.tag('t1', 'A1', 'Stock');
%$ ts1.tag('t1', 'A2', 'Flow');
%$ ts2.tag('t2');
%$ ts2.tag('t2', 'B1', 0);
%$ ts2.tag('t2', 'B2', 1);
%$
%$ % Call the tested method.
%$ try
%$   ts3 = [ts1,ts2];
%$   t(1) = true;
%$ catch
%$   t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts3.init,e.init);
%$   t(3) = dassert(ts3.freq,e.freq);
%$   t(4) = dassert(ts3.data,e.data);
%$   t(5) = dassert(ts3.name,e.name);
%$   t(6) = dassert(ts3.tags.t1,{'Stock';'Flow';[];[]});
%$   t(7) = dassert(ts3.tags.t2,{[];[];0;1});
%$ end
%$ T = all(t);
%@eof:8
