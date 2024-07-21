function o = pop_(o, p) % --*-- Unitary tests --*--

% pop method for dates class (in place modification).
%
% INPUTS
% - o [dates]
% - p [dates] object with one element, string which can be interpreted as a date or integer scalar.
%
% OUTPUTS
% - o [dates]
%
% REMARKS
% 1. If a is a date appearing more than once in o, then only the last occurence is removed. If one wants to
%    remove all the occurences of p in o, the remove method should be used instead.
%
% See also remove, setdiff.

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

if o.isempty()
    return
end

if nargin<2
    % Remove last date
    o.time = o.time(1:end-1);
    return
end

if ~( isdates(p) || isdate(p) || (isscalar(p) && isint(p)) )
    error('dates:pop', 'Input argument %s has to be a dates object with a single element, a string (which can be interpreted as a date) or an integer!',inputname(2))
end

if ischar(p)
    p = dates(p);
end

if isnumeric(p)
    idx = find(transpose(1:o.ndat())~=p);
    o.time = o.time(idx);
else
    if ~isequal(o.freq, p.freq)
        error('dates:pop', 'Inputs must have common frequency!')
    end
    if p.length()>1
        error('dates:pop', 'dates to be removed must have one element!')
    end
    if isempty(p)
        return
    end
    idx = find(o==p);
    jdx = find(transpose(1:o.ndat())~=idx(end));
    o.time = o.time(jdx);
end

%@test:1
%$ % Define some dates
%$ B1 = '1953Q4';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$ B5 = '2009Q2';
%$
%$ % Define expected results
%$ e.time = [1945*4+3; 1950*4+1; 1950*4+2; 1953*4+4; 2009*4+2];
%$ e.freq = 4;
%$
%$ % Call the tested routine
%$ d = dates(B4,B3,B2,B1);
%$ d.append_(dates(B5));
%$ try
%$     d.pop_();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(d.time,e.time(1:end-1,:));
%$     t(3) = dassert(d.freq,e.freq);
%$     t(4) = dassert(size(e.time,1)-1,d.ndat());
%$     f = copy(d);
%$     try
%$         d.pop_(B1);
%$         t(5) = true;
%$     catch
%$         t(5) = false;
%$     end
%$     if t(5)
%$         t(6) = dassert(d.time,[1945*4+3; 1950*4+1; 1950*4+2]);
%$         t(7) = dassert(d.freq,e.freq);
%$         t(8) = dassert(size(e.time,1)-2, d.ndat());
%$         try
%$             f.pop_(dates(B1));
%$             t(9) = true;
%$         catch
%$             t(9) = false;
%$         end
%$        if t(9)
%$            t(10) = dassert(f.time,[1945*4+3; 1950*4+1; 1950*4+2]);
%$            t(11) = dassert(f.freq,e.freq);
%$            t(12) = dassert(size(e.time,1)-2, f.ndat());
%$        end
%$     end
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ % Define some dates
%$ B1 = '1950Q1';
%$ B2 = '1950Q2';
%$ B3 = '1950Q1';
%$ B4 = '1945Q3';
%$ B5 = '2009Q2';
%$
%$ % Call the tested routine
%$ d = dates(B1,B2,B3,B4);
%$ d.append_(dates(B5));
%$ try
%$     d.pop_();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(d,dates(B1,B2,B3,B4));
%$     try
%$         d.pop_(B1);
%$         t(3) = true;
%$     catch
%$         t(3) = false;
%$     end
%$     if t(3)
%$         t(4) = dassert(d,dates(B1,B2,B4));
%$         try
%$             d.pop_(1);
%$             t(5) = true;
%$         catch
%$             t(5) = false;
%$         end
%$         if t(5)
%$             t(6) =  dassert(d,dates(B2,B4));
%$         end
%$     end
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ % Define some dates
%$ B1 = '1950Q1';
%$ B2 = '1950Q2';
%$ B3 = '1950Q3';
%$ d = dates(B1,B2,B3);
%$
%$ % Call the tested routine
%$ try
%$     d.pop_();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(d,dates(B1,B2));
%$     try
%$         d.pop_(B1);
%$         t(3) = true;
%$     catch
%$         t(3) = false;
%$     end
%$     if t(3)
%$         t(4) = dassert(d,dates(B2));
%$         try
%$             d.pop_(1);
%$             t(5) = true;
%$         catch
%$             t(5) = false;
%$         end
%$         if t(5)
%$             t(6) = isempty(d);
%$         end
%$     end
%$ end
%$ T = all(t);
%@eof:3

%@test:4
%$ % Define some dates
%$ B = '1950Q1';
%$ d = dates();
%$
%$ % Call the tested routine
%$ try
%$     d.pop_(B);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isempty(d);
%$ end
%$ T = all(t);
%@eof:4

%@test:5
%$ % Define some dates
%$ d = dates();
%$
%$ % Call the tested routine
%$ try
%$     d.pop_();
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = isempty(d);
%$ end
%$ T = all(t);
%@eof:5
