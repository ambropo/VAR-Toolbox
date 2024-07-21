function o = set_names(o, varargin) % --*-- Unitary tests --*--

% Specifies names of the variables in a dseries object (in place modification).
%
% INPUTS
% - o                 [dseries]
% - s1, s2, s3, ...   [string]
%
% OUTPUTS
% - o                 [dseries]

% Copyright (C) 2017 Dynare Team
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

n = nargin-1;

if ~isdseries(o)
    if isempty(inputname(1))
        error(['dseries::set_names: First input must be a dseries object!'])
    else
        error(['dseries::set_names: ' inputname(1) ' must be a dseries object!'])
    end
end

if ~isequal(vobs(o), n)
    if isempty(inputname(1))
        error(['dseries::set_names: The number of variables in first input does not match the number of declared names!'])
    else
        error(['dseries::set_names: The number of variables in ' inputname(1) ' does not match the number of declared names!'])
    end
end

for i=1:vobs(o)
    if ~isempty(varargin{i})
        o.name(i) = { varargin{i} };
    end
end

%@test:1
%$ % Define a datasets.
%$ A = rand(10,3);
%$
%$ % Define names
%$ A_name = {'A1';'Variable_2';'A3'};
%$
%$ t = zeros(4,1);
%$
%$ % Instantiate a time series object.
%$ try
%$    ts1 = dseries(A,[],[],[]);
%$    ts1.set_names('A1',[],'A3');
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if length(t)>1
%$    t(2) = dassert(ts1.vobs,3);
%$    t(3) = dassert(ts1.nobs,10);
%$    t(4) = dassert(ts1.name,A_name);
%$ end
%$ T = all(t);
%@eof:1