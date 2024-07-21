function o = cumsum_(varargin) % --*-- Unitary tests --*--

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

% Get the firt observation number where all the variables are observed (ie without NaNs)
idx = find(all(~isnan(varargin{1}.data), 2),1);
if isempty(idx)
    idx = 0;
end

% Is the first period where variables are observed common?
common_first_period_witout_nan = true;
if ~idx
    if any(~isnan(varargin{1}.data(:)))
        common_first_period_witout_nan = false;
    end
else
    if idx>1
        if any(any(~isnan(varargin{1}.data(1:idx-1,:))))
            common_first_period_witout_nan = false;
        end
    end
end

switch nargin
  case 1
    % Initialize the output.
    o = varargin{1};
    % Perform the cumulated sum
    if isequal(idx, 1)
        o.data = cumsum(o.data);
    else
        if common_first_period_witout_nan
            o.data(idx:end,:) = cumsum(o.data(idx:end,:));
        else
            o.data = cumsumnan(o.data);
        end
    end
    for i=1:vobs(o)
        if isempty(o.ops{i})
            o.ops(i) = {['cumsum(' o.name{i} ')']};
        else
            o.ops(i) = {['cumsum(' o.ops{i} ')']};
        end
    end
  case 2
    if isdseries(varargin{2})
        if ~isequal(vobs(varargin{1}), vobs(varargin{2}))
            error('dseries::cumsum: First and second input arguments must be dseries objects with the same number of variables!')
        end
        if ~isequal(varargin{1}.name, varargin{2}.name)
            warning('dseries::cumsum: First and second input arguments must be dseries objects do not have the same variables!')
        end
        if ~isequal(nobs(varargin{2}),1)
            error('dseries::cumsum: Second input argument must be a dseries object with only one observation!')
        end
        o = cumsum_(varargin{1});
        o.data = bsxfun(@plus,o.data,varargin{2}.data);
    elseif isdates(varargin{2})
        o = cumsum_(varargin{1});
        t = find(o.dates==varargin{2});
        if isempty(t)
            if varargin{2}==(firstdate(o)-1)
                return
            else
                error(['dseries::cumsum: date ' date2string(varargin{2}) ' is not in the sample!'])
            end
        end
        o.data = bsxfun(@minus,o.data,o.data(t,:));
    else
        error('dseries::cumsum: Second input argument must be a dseries object or a dates object!')
    end
  case 3
    if ~isdates(varargin{2})
        error('dseries::cumsum: Second input argument must be a dates object!')
    end
    if ~isdseries(varargin{3})
        error('dseries::cumsum: Third input argument must be a dseries object!')
    end
    if ~isequal(vobs(varargin{1}), vobs(varargin{3}))
        error('dseries::cumsum: First and third input arguments must be dseries objects with the same number of variables!')
    end
    if ~isequal(varargin{1}.name, varargin{3}.name)
        warning('dseries::cumsum: First and third input arguments must be dseries objects do not have the same variables!')
    end
    if ~isequal(nobs(varargin{3}),1)
        error('dseries::cumsum: Third input argument must be a dseries object with only one observation!')
    end
    o = cumsum_(varargin{1});
    t = find(o.dates==varargin{2});
    if isempty(t)
        if varargin{2}==(firstdate(o)-1)
            o.data = bsxfun(@plus, o.data, varargin{3}.data);
            return
        else
            error(['dseries::cumsum: date ' date2string(varargin{2}) ' is not in the sample!'])
        end
    end
    o.data = bsxfun(@plus, o.data,varargin{3}.data-o.data(t,:));
  otherwise
    error('dseries::cumsum: Wrong number of input arguments!')
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
%$   ts1.cumsum_();
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
%$   t(2) = dassert(ts1.data, ts2.data);
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
%$
%$ % Call the tested method.
%$ try
%$   cumsum_(ts1);
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
%$   t(2) = dassert(ts1.data, ts2.data);
%$ end
%$ T = all(t);
%@eof:2

%@test:3
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
%$   ts1.cumsum_(dates('3Y'));
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ ts2 = dseries([-2; -1; 0; 1; 2; 3; 4; 5; 6; 7], [], A_name, []);
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts1.data, ts2.data);
%$ end
%$ T = all(t);
%@eof:3

%@test:4
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
%$   ts1.cumsum_(dates('3Y'), ts2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ ts3 = dseries([-2; -1; 0; 1; 2; 3; 4; 5; 6; 7]+pi, [], A_name, []);
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts1.data, ts3.data);
%$ end
%$ T = all(t);
%@eof:4

%@test:5
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
%$   ts1.cumsum_(dates('3Y'), ts2);
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ ts3 = dseries([-2; -1; 0; 1; 2; 3; 4; 5; 6; 7]+pi, [], A_name, []);
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts1.data, ts3.data);
%$ end
%$ T = all(t);
%@eof:5

%@test:6
%$ % Define a data set.
%$ A = [NaN, NaN; 1 NaN; 1 1; 1 1; 1 NaN];
%$
%$ % Instantiate a time series object.
%$ ts0 = dseries(A);
%$
%$ % Call the tested method.
%$ try
%$   ts0.cumsum_();
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ A = [NaN   NaN; 1   NaN; 2     1; 3     2; 4   NaN];
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts0.data, A);
%$ end
%$ T = all(t);
%@eof:6