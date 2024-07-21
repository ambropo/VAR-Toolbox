function o = cumprod(varargin) % --*-- Unitary tests --*--

% Overloads matlab's cumprod function for dseries objects.
%
% INPUTS
% - A     dseries object [mandatory].
% - d     dates object [optional]
% - v     dseries object with one observation [optional]
%
% OUTPUTS
% - B     dseries object.

% Copyright (C) 2014-2017 Dynare Team
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
    o.cumprod_();
else
    if isoctave
        o = cumprod_(o, varargin{2:end});
    else
        o.cumprod_(varargin{2:end});
    end
end

%@test:1
%$ % Define a data set.
%$ A = 2*ones(4,1);
%$
%$ % Define names
%$ A_name = {'A1'};
%$
%$ % Instantiate a time series object.
%$ ts = dseries(A,[],A_name,[]);
%$
%$ % Call the tested method.
%$ try
%$     ds = cumprod(ts);
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(ds.data, cumprod(A));
%$     t(3) = isequal(ds.name{1}, 'A1');
%$     t(4) = isequal(ds.ops{1}, 'cumprod(A1)');
%$     t(5) = isequal(ts.data, A);
%$     t(6) = isequal(ts.name{1}, 'A1');
%$     t(7) = isempty(ts.ops{1});
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define a data set.
%$ A = 2*ones(7,1);
%$
%$ % Define names
%$ A_name = {'A1'};
%$
%$ % Instantiate a time series object.
%$ ts1 = dseries(A, [], A_name, []);
%$ ts2 = dseries(pi, [], A_name, []);
%$
%$ % Call the tested method.
%$ try
%$   ts3 = ts1.cumprod(dates('3Y'),ts2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ ts4 = dseries([.25; .5; 1; 2; 4; 8; 16]*pi, [], A_name, []);
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts3.data, ts4.data);
%$   t(3) = dassert(ts1.data, A);
%$ end
%$ T = all(t);
%@eof:2
