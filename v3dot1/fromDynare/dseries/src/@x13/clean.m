function clean(o) % --*-- Unitary tests --*--

% Erase generated files if any.

% Copyright (C) 2017 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dseries submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if ~isempty(o.results)
    basename = o.results.name;
    delete(sprintf('%s.*', basename))
end

%@test:1
%$ try
%$     series = dseries(rand(100,1),'1999M1');
%$     o = x13(series);
%$     o.x11('save','(d11)');
%$     o.run();
%$     o.clean();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ T = all(t);
%@eof:1