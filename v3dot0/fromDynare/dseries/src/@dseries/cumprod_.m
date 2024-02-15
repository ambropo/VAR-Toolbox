function o = cumprod_(varargin) % --*-- Unitary tests --*--

% Overloads matlab's cumprod function for dseries objects.
%
% INPUTS
% - o     dseries object [mandatory].
% - d     dates object [optional]
% - v     dseries object with one observation [optional]
%
% OUTPUTS
% - o     dseries object.

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
        o.data = cumprod(o.data);
    else
        if common_first_period_witout_nan
            o.data(idx:end,:) = cumprod(o.data(idx:end,:));
        else
            o.data = cumprodnan(o.data);
        end
    end
    for i=1:vobs(o)
        if isempty(o.ops{i})
            o.ops(i) = {['cumprod(' o.name{i} ')']};
        else
            o.ops(i) = {['cumprod(' o.ops{i} ')']};
        end
    end
  case 2
    if isdseries(varargin{2})
        if ~isequal(vobs(varargin{1}), vobs(varargin{2}))
            error('dseries::cumprod: First and second input arguments must be dseries objects with the same number of variables!')
        end
        if ~isequal(varargin{1}.name, varargin{2}.name)
            warning('dseries::cumprod: First and second input arguments must be dseries objects do not have the same variables!')
        end
        if ~isequal(nobs(varargin{2}),1)
            error('dseries::cumprod: Second input argument must be a dseries object with only one observation!')
        end
        o = cumprod_(varargin{1});
        o.data = bsxfun(@rdivide, o.data, o.data(1,:));
        o.data = bsxfun(@times, o.data, varargin{2}.data);
    elseif isdates(varargin{2})
        o = cumprod_(varargin{1});
        t = find(o.dates==varargin{2});
        if isempty(t)
            if varargin{2}==(firstdate(o)-1)
                return
            else
                error(['dseries::cumprod: date ' date2string(varargin{2}) ' is not in the sample!'])
            end
        end
        o.data = bsxfun(@rdivide, o.data, o.data(t,:));
    else
        error('dseries::cumprod: Second input argument must be a dseries object or a dates object!')
    end
  case 3
    if ~isdates(varargin{2})
        error('dseries::cumprod: Second input argument must be a dates object!')
    end
    if ~isdseries(varargin{3})
        error('dseries::cumprod: Third input argument must be a dseries object!')
    end
    if ~isequal(vobs(varargin{1}), vobs(varargin{3}))
        error('dseries::cumprod: First and third input arguments must be dseries objects with the same number of variables!')
    end
    if ~isequal(varargin{1}.name, varargin{3}.name)
        warning('dseries::cumprod: First and third input arguments must be dseries objects do not have the same variables!')
    end
    if ~isequal(nobs(varargin{3}),1)
        error('dseries::cumprod: Third input argument must be a dseries object with only one observation!')
    end
    o = cumprod_(varargin{1});
    t = find(o.dates==varargin{2});
    if isempty(t)
        if varargin{2}==(firstdate(o)-1)
            o.data = bsxfun(@times, o.data, varargin{3}.data);
            return
        else
            error(['dseries::cumprod: date ' date2string(varargin{2}) ' is not in the sample!'])
        end
    end
    o.data = bsxfun(@rdivide, o.data, o.data(t,:));
    o.data = bsxfun(@times, o.data, varargin{3}.data);
  otherwise
    error('dseries::cumprod: Wrong number of input arguments!')
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
%$     ts.cumprod_();
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(ts.data, cumprod(A));
%$     t(3) = isequal(ts.name{1}, 'A1');
%$     t(4) = isequal(ts.ops{1}, 'cumprod(A1)');
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
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
%$     cumprod_(ts);
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(ts.data, cumprod(A));
%$     t(3) = isequal(ts.name{1},'A1');
%$     t(4) = isequal(ts.ops{1}, 'cumprod(A1)');
%$ end
%$
%$ T = all(t);
%@eof:2


%@test:3
%$ % Define a data set.
%$ A = 2*ones(7,1);
%$
%$ % Define names
%$ A_name = {'A1'};
%$
%$ % Instantiate a time series object.
%$ ts = dseries(A,[],A_name,[]);
%$
%$ % Call the tested method.
%$ try
%$   ts.cumprod_(dates('3Y'));
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Expected results.
%$ ds = dseries([.25; .5; 1; 2; 4; 8; 16], [], A_name, []);
%$
%$ % Check the results.
%$ t(1) = dassert(ts.data, ds.data);
%$ T = all(t);
%@eof:3

%@test:4
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
%$   ts3 = ts1.cumprod_(dates('3Y'), ts2);
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
%$   t(2) = dassert(ts3.data,ts4.data);
%$   t(3) = dassert(ts1.data,ts4.data);
%$ end
%$ T = all(t);
%@eof:4

%@test:5
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
%$   ts3 = ts1.cumprod_(dates('3Y'),ts2);
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
%$   t(3) = dassert(ts1.data, ts4.data);
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
%$   ts0.cumprod_();
%$   t(1) = 1;
%$ catch
%$   t(1) = 0;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$   t(2) = dassert(ts0.data, A);
%$ end
%$ T = all(t);
%@eof:6