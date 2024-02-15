classdef dates<handle % --*-- Unitary tests --*--

% Copyright (C) 2014-2021 Dynare Team
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

properties
    freq = []; % Frequency (integer scalar)
    time = []; % One dimensional array of integers (counts subperiods since year 0)
end

methods
    function o = dates(varargin)
        if ~nargin
            % Returns empty dates object.
            o.freq = NaN(0);
            o.time = NaN(0,1);
            return
        end
        if all(cellfun(@isdates, varargin))
            % Concatenates dates objects in a dates object.
            o = horzcat(varargin{:});
            return
        end
        if all(cellfun(@isstringdate, varargin))
            % Concatenates dates in a dates object.
            tmp = cellfun(@string2date, varargin);
            if all([tmp.freq]-tmp(1).freq==0)
                o.freq = tmp(1).freq;
            else
                error('dates:ArgCheck', 'All dates passed as inputs must have the same frequency!')
            end
            o.time = transpose([tmp.time]);
            return
        end
        if isequal(nargin,1) && isfreq(varargin{1})
            % Instantiate an empty dates object (only set frequency)
            o.time = NaN(0,1);
            if ischar(varargin{1})
                o.freq = string2freq(varargin{1});
            else
                o.freq = varargin{1};
            end
            return
        end
        if isequal(nargin, 3) && isfreq(varargin{1})
            o.time = NaN(0, 1);
            if ischar(varargin{1})
                o.freq = string2freq(varargin{1});
            else
                o.freq = varargin{1};
            end
            if o.freq==365
                error('dates:ArgCheck', 'Requires four inputs for daily dates.')
            end
            if (isnumeric(varargin{2}) && isvector(varargin{2}) && all(isint(varargin{2})))
                if isnumeric(varargin{3}) && isvector(varargin{3}) && all(isint(varargin{3}))
                    if all(varargin{3}>=1) && all(varargin{3}<=o.freq)
                        o.time = varargin{2}(:)*o.freq+varargin{3}(:);
                    else
                        error('dates:ArgCheck', 'Third input must contain integers between 1 and %i.', o.freq)
                    end
                else
                    error('dates:ArgCheck', 'Third input must be a vector of integers.')
                end
            else
                error('dates:ArgCheck', 'Second input must be a vector of integers.')
            end
            return
        end
        if isequal(nargin,2) && isfreq(varargin{1})
            o.time = NaN(0, 1);
            if ischar(varargin{1})
                o.freq = string2freq(varargin{1});
            else
                o.freq = varargin{1};
            end
            if isequal(o.freq, 1)
                if (isnumeric(varargin{2}) && isvector(varargin{2}) && all(isint(varargin{2})))
                    o.time = varargin{2}(:);
                    return
                else
                    error('dates:ArgCheck','Second input must be a vector of integers.')
                end
            elseif ismember(o.freq, [2,4,12])
                if isequal(size(varargin{2}, 2), 2)
                    if all(all(isint(varargin{2})))
                        if all(varargin{2}(:,2)>=1) && all(varargin{2}(:,2)<=o.freq)
                            o.time = varargin{2}(:,1)*o.freq+varargin{2}(:,2);
                        else
                            error('dates:ArgCheck', 'Second column of the last input must contain integers between 1 and %i.', o.freq)
                        end
                    else
                        error('dates:ArgCheck', 'Second input argument must be an array of integers.')
                    end
                else
                    error('dates:ArgCheck', 'The second input must be a n*2 array of integers.')
                end
            elseif isequal(o.freq, 365)
                if isequal(size(varargin{2}, 2), 3)
                    if all(all(isint(varargin{2})))
                        if all(varargin{2}(:,2)>=1) && all(varargin{2}(:,2)<=12)
                            if all(varargin{2}(:,3)>=1) && all(varargin{2}(:,2)<=31)
                                o.time = datenum(varargin{2}(:,1), varargin{2}(:,2), varargin{2}(:,3));
                            else
                                error('dates:ArgCheck', 'Third column of the last input must contain integers between 1 and 31 (days).')
                            end
                        else
                            error('dates:ArgCheck', 'Second column of the last input must contain integers between 1 and 12 (months).')
                        end
                    else
                        error('dates:ArgCheck', 'Second input argument must be an array of integers.')
                    end
                else
                    error('dates:ArgCheck', 'For daily dates the second input must be a n*3 array of integers.')
                end
            end
            return
        end
        if isequal(nargin,4) && isfreq(varargin{1}) && ( isequal(varargin{1}, 365) || strcmpi(varargin{1}, 'D'))
            o.time = NaN(0,1);
            if ischar(varargin{1})
                o.freq = string2freq(varargin{1});
            else
                o.freq = varargin{1};
            end
            if (isnumeric(varargin{2}) && isvector(varargin{2}) && all(isint(varargin{2})))
                if isnumeric(varargin{3}) && isvector(varargin{3}) && all(isint(varargin{3}))
                    if isnumeric(varargin{4}) && isvector(varargin{4}) && all(isint(varargin{4}))
                        if all(varargin{3}>=1) && all(varargin{3}<=12)
                            if all(varargin{4}>=1) && all(varargin{3}<=31)
                                if length(varargin{2})==length(varargin{3}) && length(varargin{2})==length(varargin{4})
                                    o.time = datenum(varargin{2}(:), varargin{3}(:), varargin{4}(:));
                                else
                                    error('dates:ArgCheck', 'Vectors passed as second, third, and fourth arguments must have the same number of elements.')
                                end
                            else
                                error('dates:ArgCheck', 'Fourth input must contain integers between 1 and 31 (days).')
                            end
                        else
                            error('dates:ArgCheck', 'Third input must contain integers between 1 and 12 (days).')
                        end
                    else
                        error('dates:ArgCheck','Fourth input must be a vector of integers.')
                    end
                else
                    error('dates:ArgCheck','Third input must be a vector of integers.')
                end
            else
                error('dates:ArgCheck','Second input must be a vector of integers.')
            end
            return
        end
        error('dates:ArgCheck','The input cannot be interpreted as a date. You should first read the manual!')
    end % dates constructor.
        % Other methods
    p = sort(o);
    o = sort_(o);
    p = unique(o);
    o = unique_(o);
    p = append(o, d);
    o = append_(o, d);
    p = pop(o, d);
    o = pop_(o, d);
    p = remove(o, d);
    o = remove_(o, d);
    s = char(o);
    a = double(o);
    n = ndat(o);
    n = length(o);
end % methods
end % classdef


%@test:1
%$ % Define some dates
%$ B1 = '1945Q3';
%$ B2 = '1950Q2';
%$ B3 = '1950q1';
%$ B4 = '1953Q4';
%$
%$ % Define expected results.
%$ e.time = [1945*4+3; 1950*4+2; 1950*4+1; 1953*4+4];
%$ e.freq = 4;
%$
%$ % Call the tested routine.
%$ d = dates(B1,B2,B3,B4);
%$
%$ % Check the results.
%$ t(1) = isequal(d.time, e.time);
%$ t(2) = isequal(d.freq, e.freq);
%$ t(3) = isequal(d.ndat(), size(e.time, 1));
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define some dates
%$ B1 = '1945M3';
%$ B2 = '1950M2';
%$ B3 = '1950M10';
%$ B4 = '1953M12';
%$
%$ % Define expected results.
%$ e.time = [1945*12+3; 1950*12+2; 1950*12+10; 1953*12+12];
%$ e.freq = 12;
%$
%$ % Call the tested routine.
%$ d = dates(B1,B2,B3,B4);
%$
%$ % Check the results.
%$ t(1) = isequal(d.time,e.time);
%$ t(2) = isequal(d.freq,e.freq);
%$ t(3) = isequal(d.ndat(), size(e.time, 1));
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define some dates
%$ B1 = '1945H1';
%$ B2 = '1950S2';
%$ B3 = '1950h1';
%$ B4 = '1953s2';
%$
%$ % Define expected results.
%$ e.time = [1945*2+1; 1950*2+2; 1950*2+1; 1953*2+2];
%$ e.freq = 2;
%$
%$ % Call the tested routine.
%$ d = dates(B1,B2,B3,B4);
%$
%$ % Check the results.
%$ t(1) = isequal(d.time,e.time);
%$ t(2) = isequal(d.freq,e.freq);
%$ t(3) = isequal(d.ndat(), size(e.time, 1));
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define some dates
%$ B1 = '1945y';
%$ B2 = '1950Y';
%$ B3 = '1950a';
%$ B4 = '1953A';
%$
%$ % Define expected results.
%$ e.time = [1945; 1950; 1950; 1953];
%$ e.freq = 1;
%$
%$ % Call the tested routine.
%$ d = dates(B1,B2,B3,B4);
%$
%$ % Check the results.
%$ t(1) = isequal(d.time, e.time);
%$ t(2) = isequal(d.freq, e.freq);
%$ t(3) = isequal(d.ndat(), size(e.time, 1));
%$ T = all(t);
%@eof:4

%@test:5
%$ % Define a dates object
%$ B = dates('1950H1'):dates('1960H2');
%$
%$
%$ % Call the tested routine.
%$ d = B(2);
%$ if isa(d,'dates')
%$     t(1) = true;
%$ else
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(d.freq,B.freq);
%$     t(3) = isequal(d.time,1950*2+2);
%$ end
%$ T = all(t);
%@eof:5

%@test:6
%$ % Define a dates object
%$ B = dates('1950Q1'):dates('1960Q3');
%$
%$
%$ % Call the tested routine.
%$ d = B(2);
%$ if isa(d,'dates')
%$     t(1) = true;
%$ else
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(d.freq,B.freq);
%$     t(3) = isequal(d.time,1950*4+2);
%$ end
%$ T = all(t);
%@eof:6

%@test:7
%$ % Define a dates object
%$ B = dates(4,1950,1):dates(4,1960,3);
%$
%$ % Call the tested routine.
%$ d = B(2);
%$ if isa(d,'dates')
%$     t(1) = true;
%$ else
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(d.freq,B.freq);
%$     t(3) = isequal(d.time,1950*4+2);
%$ end
%$ T = all(t);
%@eof:7

%@test:8
%$ % Define a dates object
%$ B = dates(4,[1950 1]):dates(4,[1960 3]);
%$
%$ % Call the tested routine.
%$ d = B(2);
%$ if isa(d,'dates')
%$     t(1) = true;
%$ else
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isequal(d.freq,B.freq);
%$     t(3) = isequal(d.time,1950*4+2);
%$ end
%$ T = all(t);
%@eof:8

%@test:9
%$ try
%$   B = dates(4,[1950; 1950], [1; 2]);
%$   t = true;
%$ catch
%$   t = false;
%$ end
%$
%$ T = all(t);
%@eof:9

%@test:10
%$ try
%$   B = dates(365,[1956; 1956], [1; 1], [12; 13]);
%$   t = true;
%$ catch
%$   t = false;
%$ end
%$
%$ T = all(t);
%@eof:10