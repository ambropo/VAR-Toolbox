function o = vertcat(varargin) % --*-- Unitary tests --*--

% Overloads the vertcat method for dates objects.
%
% INPUTS
% - varargin [dates]
%
% OUTPUTS
% - o [dates] object containing dates defined in varargin{:}
%
% EXAMPLE 1
%  If A, B and C are dates object the following syntax:
%
%    D = [A; B; C] ;
%
%  Defines a dates object D containing the dates appearing in A, B and C.

% Copyright (C) 2013-2021 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if ~all(cellfun(@isdates, varargin))
    error('dates:vertcat:ArgCheck', 'All input arguments must be dates objects.')
end

o = horzcat(varargin{:});

%@test:1
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$ B5 = '2009Q2';
%$
%$ % Define expected results.
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
%$ e.freq = 4;
%$
%$ % Call the tested routine.
%$ d = dates(B4,B3,B2);
%$ try
%$     d = [d; dates(B1); dates(B5)];
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ % Check the results.
%$ if t(1)
%$     t(2) = dassert(d.time,e.time);
%$     t(3) = dassert(d.freq,e.freq);
%$     t(4) = size(e.time,1)==d.ndat();
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define some dates
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$
%$ % Call the tested routine.
%$ d = dates(B4,B3,B2);
%$ try
%$     d = [d; 1];
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:2
