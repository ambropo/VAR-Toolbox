function [m, f]  = double(o) % --*-- Unitary tests --*--

% Returns a vector of doubles with the fractional part corresponding
% to the subperiod. Used for plots and to store dates in a matrix.
%
% INPUTS
% - o [dates]
%
% OUTPUTS
% - m [double] o.ndat*1 vector of doubles.
% - f [integer] scalar, the frequency (1, 2, 4, or 12).
%
% REMARKS
%  Obviously the frequency is lost during the conversion.

% Copyright © 2013-2021 Dynare Team
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

if o.freq==365
    error('This method is not implemented for daily frequency.')
    % Would need to find a way to deal with leap years
end

if o.freq == 1
    m = o.time;
else
    years = floor((o.time-1)/o.freq);
    subperiods = o.time-years*o.freq;
    m = years+(subperiods-1)/o.freq;
end

if nargout>1
    f = o.freq;
end

return

%@test:1
% Define a dates object
B = dates('1950Q1'):dates('1951Q1');

% Call the tested routine.
try
    C = double(B);
    t(1) = 1;
catch
    t(1) = 0;
end

% Define expected results.
E = [ones(4,1)*1950; 1951];
E = E + [(transpose(1:4)-1)/4; 0];
if t(1)
    t(2) = isequal(C,E);
end
T = all(t);
%@eof:1

%@test:2
% Call the tested routine.
try
    C = NaN(2,1);
    C(1) = double(dates('1950Q1'));
    C(2) = double(dates('1950Q2'));
    t(1) = 1;
catch
    t(1) = 0;
end

% Define expected results.
E = ones(2,1)*1950;
E = E + [0; .25];
if t(1)
    t(2) = isequal(C,E);
end
T = all(t);
%@eof:2

%@test:3
% Regression test for dseries#47
B = dates('1950Y'):dates('1952Y');

% Call the tested routine.
try
    C = double(B);
    t(1) = 1;
catch
    t(1) = 0;
end

% Define expected results.
E = [1950; 1951; 1952];
if t(1)
    t(2) = isequal(C,E);
end
T = all(t);
%@eof:3
