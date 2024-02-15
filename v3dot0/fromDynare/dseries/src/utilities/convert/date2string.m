function s = date2string(varargin) % --*-- Unitary tests --*--

% Returns date as a string.
%
% INPUTS
% - varargin{1}     [dates]       scalar, if nargin==1.
%                   [integer]     scalar, if nargin==2.
% - varargin{2}     [integer]     scalar, frequency (1, 2, 4, 12, or 365).
%
% OUTPUTS
% - s               [char]        1×n array.

% Copyright © 2013-2021 Dynare Team
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

if isequal(nargin, 1)
    if ~(isa(varargin{1}, 'dates') && isequal(length(varargin{1}), 1))
        error(['dates::format: Input argument ' inputname(1) ' has to be a dates object with one element!'])
    else
        time = varargin{1}.time;
        freq = varargin{1}.freq;
    end
end

if isequal(nargin, 2)
    if ~isscalar(varargin{2}) || ~isint(varargin{2}) || ~ismember(varargin{2}, [1 2 4 12 365])
        error('Second input argument must be an integer scalar equal to 1, 2, 4, 12, or 365 (frequency).')
    end
    freq = varargin{2};
    if ~isnumeric(varargin{1}) || ~isscalar(varargin{1}) || ~isint(varargin{1})
        error('First input must be a scalar integer.')
    end
    time = varargin{1};
end

if freq==365
    s = datestr(time(1), 'yyyy-mm-dd');
elseif freq==1
    s = sprintf('%iY', time);
else
    year = floor((time-1)/freq);
    subperiod = time-year*freq;
    s = sprintf('%i%s%i', year, freq2string(freq), subperiod);
end

return

%@test:1
try
    str = date2string(dates('1938Q4'));
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str, '1938Q4');
end

T = all(t);
%@eof:1

%@test:2
try
    str = date2string(dates('1938Q4','1945Q3'));
    t(1) = false;
catch
    t(1) = true;
end

T = all(t);
%@eof:2

%@test:3
try
    str = date2string(1938*12+11, 12);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str, '1938M11');
end

T = all(t);
%@eof:3

%@test:4
try
    str = date2string(1938*4+11, 4);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str, '1940Q3');
end

T = all(t);
%@eof:4

%@test:5
try
    str = date2string(1938*2+2, 2);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str, '1938S2');
end

T = all(t);
%@eof:5

%@test:6
try
    str = date2string(707852, 365);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(str, '1938-01-12');
end

T = all(t);
%@eof:6