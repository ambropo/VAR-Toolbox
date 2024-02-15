function o = vertcat(varargin) % --*-- Unitary tests --*--

% Overloads vertcat method for dseries objects.
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
%  If o1, o2 and o3 are dseries objects containing the same variables over different samples, the following syntax:
%
%    o = [o1; o2; o3] ;
%
%  merges the samples.

% Copyright (C) 2013-2017 Dynare Team
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

if nargin==0
    o = dseries();
elseif nargin == 1
    o = copy(varargin{1});
elseif nargin>1
    o = copy(varargin{1});
    for i=2:nargin
        o = vertcat_(o, varargin{i});
    end
end

function d = vertcat_(b, c)
d = NaN;
if ~isequal(frequency(b), frequency(c))
    error('dseries::vertcat: Frequencies must be common!')
end
if ~isequal(vobs(b), vobs(c))
    error('dseries::vertcat: Number of variables must be common!')
end
reorder_variables_in_c = false;
if ~isequal(b.name, c.name)
    [t, idx] = ismember(b.name, c.name);
    if all(t)
        reorder_variables_in_c = true;
    else
        error('dseries::vertcat: Variables must be common!')
    end
end
d = b;
if reorder_variables_in_c
    d.data = [b.data; c.data(:,idx)];
else
    d.data = [b.data; c.data];
end
d.dates = [b.dates; c.dates];

%@test:1
%$ % Define a data set.
%$ A = [transpose(1:10),2*transpose(1:10)];
%$ B = [transpose(1:10),2*transpose(1:10)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'A1';'A2'};
%$
%$ % Define expected results.
%$ e.init = dates(1,1);
%$ e.freq = 1;
%$ e.name = {'A1';'A2'};
%$ e.data = [A;B];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,[],A_name,[]);
%$ ts2 = dseries(B,[],B_name,[]);
%$
%$ % Call the tested method.
%$ try
%$   ts3 = [ts1;ts2];
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts3.init,e.init);
%$   t(3) = dassert(ts3.freq,e.freq);
%$   t(4) = dassert(ts3.data,e.data);
%$   t(5) = dassert(ts3.name,e.name);
%$   t(6) = dassert(ts3.nobs,20);
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a data set.
%$ A = [transpose(1:10),2*transpose(1:10)];
%$ B = [transpose(1:10),2*transpose(1:10)];
%$ C = [transpose(1:10),3*transpose(1:10)];
%$
%$ % Define names
%$ A_name = {'A1';'A2'};
%$ B_name = {'A1';'A2'};
%$ C_name = {'A1';'A2'};
%$
%$ % Define expected results.
%$ e.init = dates(1,1);
%$ e.freq = 1;
%$ e.name = {'A1';'A2'};
%$ e.data = [A;B;C];
%$
%$ % Instantiate two time series objects.
%$ ts1 = dseries(A,[],A_name,[]);
%$ ts2 = dseries(B,[],B_name,[]);
%$ ts3 = dseries(C,[],C_name,[]);
%$
%$ % Call the tested method.
%$ try
%$   ts4 = [ts1; ts2; ts3];
%£   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts4.init,e.init);
%$   t(3) = dassert(ts4.freq,e.freq);
%$   t(4) = dassert(ts4.data,e.data);
%$   t(5) = dassert(ts4.name,e.name);
%$   t(6) = dassert(ts4.nobs,30);
%$ end
%$ T = all(t);
%@eof:2

%@test:3
%$ A = dseries([ones(5,1), 2*ones(5,1)],'1938Q4',{'A1', 'A2'});
%$ B = dseries([2*ones(2,1), ones(2,1)],'1945Q3',{'A2', 'A1'});
%$
%$ try
%$    C = [A; B];
%$    t(1) = true;
%$ catch
%$    t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$    t(2) = dassert(C.data,[ones(7,1), 2*ones(7,1)]);
%$ end
%$ T = all(t);
%@eof:3

%@test:4
%$ A = dseries(ones(3, 1), '1990Q1');
%$ B = dseries(2*ones(3, 1), '1990Q4');
%$
%$ try
%$    C = [A; B];
%$    t(1) = true;
%$ catch
%$    t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$    t(2) = dassert(C.data, [ones(3,1); 2*ones(3,1)]);
%$    t(3) = dassert(A.data, ones(3,1));
%$    t(4) = dassert(B.data, 2*ones(3,1));
%$ end
%$ T = all(t);
%@eof:4
