function o = cumsum(varargin) % --*-- Unitary tests --*--

% Overloads matlab's cumsum function for dseries objects.
%
% INPUTS
% - o     dseries object [mandatory].
% - d     dates object [optional]
% - v     dseries object with one observation [optional]
%
% OUTPUTS
% - o     dseries object.

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

o = copy(varargin{1});

if nargin<2
    o.cumsum_();
else
    if isoctave()
        o = cumsum_(o, varargin{2:end});
    else
        o.cumsum_(varargin{2:end});
    end
end

%@test:1
%$ % Define a data set.
%$ A = ones(10,1);
%$
%$ % Define names
%$ A_name = {'A1'};
%$
%$ % Instantiate a time series object.
%$ ts1 = dseries(A,[],A_name,[]);
%$
%$ % Call the tested method.
%$ try
%$   ts3 = cumsum(ts1);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ ts2 = dseries(transpose(1:10), [], A_name, []);
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts3.data, ts2.data);
%$   t(3) = dassert(ts1.data, A);
%$ end
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a data set.
%$ A = ones(10,1);
%$
%$ % Define names
%$ A_name = {'A1'};
%$
%$ % Instantiate a time series object.
%$ ts1 = dseries(A,[],A_name,[]);
%$ ts2 = dseries(pi, [], A_name, []);
%$
%$ % Call the tested method.
%$ try
%$   ts3 = ts1.cumsum(dates('3Y'),ts2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ ts4 = dseries([-2; -1; 0; 1; 2; 3; 4; 5; 6; 7]+pi, [], A_name, []);
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts3.data, ts4.data);
%$   t(3) = dassert(ts1.data, A);
%$ end
%$ T = all(t);
%@eof:2