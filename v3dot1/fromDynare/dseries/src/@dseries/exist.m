function l = exist(o, varname) % --*-- Unitary tests --*--

% Tests if a variable exists in dseries object o.
%
% INPUTS
%  - o       [dseries], dseries object.
%  - varname [string],  name of a variable.
%
% OUTPUTS
%  - l       [logical], equal to 1 (true) iff varname is a variable in dseries object o.

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

if ~ischar(varname)
    if isempty(inputname(2))
        error(['dseries::exist: Input argument (variable name) has to be string!'])
    else
        error(['dseries::exist: Second input argument ''' inputname(2) ''' has to be string!'])
    end
end

l = ~isempty(strmatch(varname, o.name, 'exact'));

%@test:1
%$ % Define a datasets.
%$ data = randn(10,4);
%$
%$ % Define names
%$ names = {'Noddy';'Jumbo';'Sly';'Gobbo'};
%$ t = zeros(4,1);
%$
%$ % Instantiate a time series object and compute the absolute value.
%$ try
%$    ts = dseries(data,[],names,[]);
%$    t(1) = 1;
%$ catch
%$    t = 0;
%$ end
%$
%$ if t(1)
%$    t(2) = dassert(ts.exist('Noddy'),true);
%$    t(3) = dassert(ts.exist('noddy'),false);
%$    t(4) = dassert(ts.exist('Boots'),false);
%$ end
%$ T = all(t);
%@eof:1
