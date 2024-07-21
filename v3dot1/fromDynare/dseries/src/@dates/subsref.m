function B = subsref(A,S) % --*-- Unitary tests --*--

% Overloads the subsref method for dates objects.
%
% INPUTS
% - A [dates]
% - S [structure]
%
% OUTPUTS
% - B [*]
%
% REMARKS
% 1. The type of the returned argument depends on the content of S.
% 2. See the matlab's documentation about the subsref method.

% Copyright © 2011-2021 Dynare Team
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

switch S(1).type
  case '.'
    switch S(1).subs
      case {'time','freq'}% Access public members.
        if length(S)>1 && isequal(S(2).type,'()') && isempty(S(2).subs)
            error(['dates::subsref: ' S(1).subs ' is not a method but a member!'])
        end
        B = builtin('subsref', A, S(1));
      case {'sort','sort_','unique','unique_','double','isempty','length','char','ndat','year','subperiod', 'strings'}% Public methods (without input arguments)
        B = feval(S(1).subs,A);
        if length(S)>1 && isequal(S(2).type,'()') && isempty(S(2).subs)
            S = shiftS(S,1);
        end
      case {'append','append_','pop','pop_','remove','remove_'}% Public methods (with arguments).
        if isequal(S(2).type,'()')
            B = feval(S(1).subs,A,S(2).subs{:});
            S = shiftS(S,1);
        else
            error('dates::subsref: Something is wrong in your syntax!')
        end
      case {'disp'}
        feval(S(1).subs,A);
        return
      otherwise
        error('dates::subsref: Unknown public member or method!')
    end
  case '()'
    if isempty(A)
        if isempty(A.freq)
            % Populate an empty dates object with time member (freq is not specified). Needs two, three or four inputs. First input is an integer
            % scalar specifying the frequency. Second input is either the time member (a n*2 array of integers) or a column vector with n
            % elements (the first column of the time member --> years). If the the second input is a row vector and if A.freq~=1 a third input
            % is necessary. The third input is n*1 vector of integers between 1 and A.freq (or 31 in case of daily data) (second column of the time member --> subperiods).
            % The fourth input is only necessary in case of daily data, it is n*1 vector of integers between 1 and 12.
            B = dates();
            % First input is the frequency.
            if isfreq(S(1).subs{1})
                if ischar(S(1).subs{1})
                    B.freq = string2freq(S(1).subs{1});
                else
                    B.freq = S(1).subs{1};
                end
            else
                error('dates::subsref: First input must be a frequency.')
            end
            if isequal(length(S(1).subs), 2)
                % If two inputs are provided, the second input argument must be a
                %  - n*1 array for annual dates,
                %  - n*2 array for bi-annual, quarterly and monthly dates,
                %  - n*3 array for daily dates.
                m = size(S(1).subs{2}, 2);
                if isequal(B.freq, 365) && ~isequal(m, 3)
                    error('dates::subsref: With daily dates the second argument must be a n*3 array of integers.')
                end
                if ismember(B.freq, [2, 4, 12]) && ~isequal(m, 2)
                    switch B.freq
                      case 2
                        serror = 'bi-annual';
                      case 4
                        serror = 'quarterly';
                      case 12
                        serror = 'monthly';
                      otherwise
                        error('dates::subsref: Unknown frequency.')
                    end
                    error('dates::subsref: With %s dates the second argument must be a n*2 array of integers.', serror)
                end
                if isequal(B.freq, 1) && ~isequal(m, 1)
                    error('dates::subsref: Second argument has to be a n*1 array for annual dates.')
                end
                if ~all(all(isint(S(1).subs{2})))
                    error('dates::subsref: Second argument has be an array of intergers!')
                end
                if isequal(m, 2) && ~issubperiod(S(1).subs{2}(:,2), B.freq)
                    error('dates::subsref: Elements in the second column of the first input argument are not legal subperiods (should be integers betwwen 1 and %i.', B.freq)
                end
                if isequal(m, 3)
                    if ~all(S(1).subs{2}(:,2)>=1 & S(1).subs{2}(:,2)<=12)
                        error('dates::subsref: Second column of the second argument should be composed of integers between 1 and 12 (months).')
                    end
                    if ~all(S(1).subs{2}(:,3)>=1 & S(1).subs{2}(:,3)<=31)
                        error('dates::subsref: Third column of the second argument should be composed of integers between 1 and 31 (days).')
                    end
                end
                switch B.freq
                  case 1
                    B.time = S(1).subs{2};
                  case {2,4,12}
                    B.time = S(1).subs{2}(:,1)*B.freq+S(1).subs{2}(:,2);
                  case 365
                    B.time = datenum(S(1).subs{2}(:,1), S(1).subs{2}(:,2), S(1).subs{2}(:,3));
                  otherwise
                    error('dates::subsref: Unknown frequency.')
                end
            elseif isequal(length(S(1).subs), 3)
                if isequal(B.freq, 365)
                    error('dates::subsref: With daily dates four input arguments are required.')
                end
                % If three inputs are provided, the second and third inputs are column vectors of integers (years and subperiods).
                if ~iscolumn(S(1).subs{2}) && ~all(isint(S(1).subs{2}))
                    error('dates::subsref: Second input argument must be a column vector of integers!')
                end
                n1 = size(S(1).subs{2}, 1);
                if ~iscolumn(S(1).subs{3}) && ~issubperiod(S(1).subs{3}, B.freq)
                    error('dates::subsref: Third input argument must be a column vector of subperiods (integers between 1 and %i).', B.freq)
                end
                n2 = size(S(1).subs{3}, 1);
                if ~isequal(n1, n2)
                    error('dates::subsref: Second and third input arguments must have the same number of elements.')
                end
                B.time = S(1).subs{2}*B.freq+S(1).subs{3};
            elseif isequal(length(S(1).subs), 4)
                if ~isequal(B.freq, 365)
                    error('dates::subsref: Four arguments is only allowed for daily dates.')
                end
                % If four inputs are provided, the second, third and fourth inputs are column vectors of integers (years, months and days).
                if ~iscolumn(S(1).subs{2}) && ~all(isint(S(1).subs{2}))
                    error('dates::subsref: Second input argument must be a column vector of integers.')
                end
                n1 = size(S(1).subs{2}, 1);
                if ~iscolumn(S(1).subs{3}) && ~all(S(1).subs{2}>=1) && ~all(S(1).subs{2}<=12)
                    error('dates::subsref: Third input argument must be a column vector of subperiods (integers between 1 and 12).')
                end
                n2 = size(S(1).subs{3}, 1);
                if ~iscolumn(S(1).subs{4}) && ~all(S(1).subs{2}>=1) && ~all(S(1).subs{2}<=31)
                    error('dates::subsref: Fourth input argument must be a column vector of subperiods (integers between 1 and 31).')
                end
                n3 = size(S(1).subs{4}, 1);
                if ~isequal(n1, n2, n3)
                    error('dates::subsref: Second, third and fourth input arguments must have the same number of elements.')
                end
                % Check that the provided inputs form a valid date
                for i=1:length(S(1).subs{1})
                    if ~isvalidday([S(1).subs{1}(i), S(1).subs{2}(i), S(1).subs{3}(i)])
                        error('Triplet (%u, %u, %u) is not a valid date for a day.', S(1).subs{1}(i), S(1).subs{2}(i), S(1).subs{3}(i))
                    end
                end
                B.time = datenum([S(1).subs{1}, S(1).subs{2}, S(1).subs{3}]);
            else
                error('dates::subsref: Wrong calling sequence!')
            end
        else
            % Populate an empty dates object with time member (freq is already specified).
            % Needs one (time), two or three (first, second and third columns of time for years and subperiods (months and days when freq is 365)) inputs.
            B = copy(A);
            if isequal(length(S(1).subs), 2) && ~isequal(B.freq, 365)
                if ~iscolumn(S(1).subs{1}) && ~all(isint(S(1).subs{1}))
                    error('dates::subsref: First argument has to be a column vector of integers.')
                end
                n1 = size(S(1).subs{1}, 1);
                if ~iscolumn(S(1).subs{2}) && ~issubperiod(S(1).subs{2}, B.freq)
                    error('dates::subsref: Second argument has to be a column vector of subperiods (integers between 1 and %u).', B.freq)
                end
                n2 = size(S(1).subs{2}, 1);
                if ~isequal(n2, n1)
                    error('dates::subsref: First and second argument must have the same number of rows.')
                end
                B.time = S(1).subs{1}*B.freq+S(1).subs{2};
            elseif isequal(length(S(1).subs), 1) && ~isequal(B.freq, 365)
                m = size(S(1).subs{1}, 2);
                if ~isequal(m, 2) && ~isequal(B.freq, 1)
                    error('dates::subsref: First argument has to be a n*2 array.')
                end
                if ~all(isint(S(1).subs{1}(:,1)))
                    error('dates::subsref: First column of the first argument has to be a column vector of integers.')
                end
                if m>1 && issubperiod(S(1).subs{1}(:,1), B.freq)
                    error('dates::subsref: The second column of the first input argument has to be a column  vector of subperiods (integers between 1 and %u).', B.freq)
                end
                if isequal(m, 2)
                    B.time = S(1).subs{1}(:,1)*B.freq+S(1).subs{1}(:,2);
                elseif isequal(m, 1) && isequal(B.freq, 1)
                    B.time = S(1).subs{1};
                else
                    error('dates::subsref: This is a bug!')
                end
            elseif isequal(length(S(1).subs), 3) && isequal(B.freq, 365)
                if ~iscolumn(S(1).subs{1}) && ~all(isint(S(1).subs{1}))
                    error('dates::subsref: First argument has to be a column vector of integers.')
                end
                n1 = size(S(1).subs{1},1);
                if ~iscolumn(S(1).subs{2}) && ~all(S(1).subs{2}>=1) && ~all(S(1).subs{2}<=12)
                    error('dates::subsref: Second argument has to be a column vector of subperiods (integers between 1 and 12).')
                end
                n2 = size(S(1).subs{2},1);
                if ~iscolumn(S(1).subs{3}) && ~all(S(1).subs{2}>=1) && ~all(S(1).subs{2}<=31)
                    error('dates::subsref: Third argument has to be a column vector of subperiods (integers between 1 and 31).')
                end
                n3 = size(S(1).subs{3},1);
                if ~isequal(n3,n2,n1)
                    error('dates::subsref: All arguments must have the same number of rows.')
                end
                % Check that the provided inputs form a valid date
                for i=1:length(S(1).subs{1})
                    if ~isvalidday([S(1).subs{1}(i), S(1).subs{2}(i), S(1).subs{3}(i)])
                        error('Triplet (%u, %u, %u) is not a valid date for a day.', S(1).subs{1}(i), S(1).subs{2}(i), S(1).subs{3}(i))
                    end
                end
                B.time = datenum([S(1).subs{1}, S(1).subs{2}, S(1).subs{3}]);
            else
                error('dates::subsref: Wrong number of inputs!')
            end
        end
    else
        % dates object A is not empty. We extract some dates
        if ismatrix(S(1).subs{1}) && isempty(S(1).subs{1})
            B = dates(A.freq);
        elseif isvector(S(1).subs{1}) && all(isint(S(1).subs{1})) && all(S(1).subs{1}>0) && all(S(1).subs{1}<=A.ndat())
            B = dates();
            B.freq = A.freq;
            B.time = A.time(S(1).subs{1});
        else
            error(['dates::subsref: indices has to be a vector of positive integers less than or equal to ' int2str(A.ndat()) '!'])
        end
    end
  otherwise
    error('dates::subsref: Something is wrong in your syntax!')
end

S = shiftS(S,1);
if ~isempty(S)
    B = subsref(B, S);
end

return

%@test:1
% Define a dates object
B = dates('1950Q1','1950Q2','1950Q3','1950Q4','1951Q1');

% Try to extract a sub-dates object.
try
    d = B(2:3);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(d.freq, B.freq);
    t(3) = isequal(d.time, [1950*4+2; 1950*4+3]);
    t(4) = isequal(d.ndat(), 2);
end
T = all(t);
%@eof:1

%@test:2
% Define a dates object
B = dates('1950Q1'):dates('1960Q3');

% Try to extract a sub-dates object and apply a method
try
    d = B(2:3).sort;
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(d.freq,B.freq);
    t(3) = isequal(d.time,[1950*4+2; 1950*4+3]);
    t(4) = isequal(d.ndat(),2);
end
T = all(t);
%@eof:2

%@test:3
% Define a dates object
B = dates('1950Q1'):dates('1960Q3');

% Try to extract a sub-dates object and apply a method
try
    d = B(2:3).sort();
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(d.freq,B.freq);
    t(3) = isequal(d.time,[1950*4+2; 1950*4+3]);
    t(4) = isequal(d.ndat(),2);
end
T = all(t);
%@eof:3

%@test:4
% Define a dates object
B = dates('1950Q1','1950Q2','1950Q3','1950Q4','1951Q1');

% Try to extract a sub-dates object.
try
    d = B(2);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(d.freq,B.freq);
    t(3) = isequal(d.time,1950*4+2);
    t(4) = isequal(d.ndat(),1);
end
T = all(t);
%@eof:4

%@test:5
% Define an empty dates object with quaterly frequency.
qq = dates('Q');

% Define a ranges of dates using qq.
try
    r1 = qq(1950,1):qq(1950,3);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    try
        r2 = qq([1950, 1; 1950, 2; 1950, 3]);
        t(2) = true;
    catch
        t(2) = false;
    end
end
if t(1) && t(2)
    try
        r3 = qq(1950*ones(3,1), transpose(1:3));
        t(3) = true;
    catch
        t(3) = false;
    end
end

if t(1) && t(2) && t(3)
    t(4) = isequal(r1,r2);
    t(5) = isequal(r1,r3);
end
T = all(t);
%@eof:5

%@test:6
% Define an empty dates object with quaterly frequency.
date = dates();

% Define a ranges of dates using qq.
try
    r1 = date(4,1950,1):date(4,[1950, 3]);
    t(1) = true;
catch
    t(1) = false;
end
if t(1)
    try
        r2 = date(4,[1950, 1; 1950, 2; 1950, 3]);
        t(2) = true;
    catch
        t(2) = false;
    end
end
if t(1) && t(2)
    try
        r3 = date(4,1950*ones(3,1), transpose(1:3));
        t(3) = true;
    catch
        t(3) = false;
    end
end

if t(1) && t(2) && t(3)
    t(4) = isequal(r1, r2);
    t(5) = isequal(r1, r3);
end
T = all(t);
%@eof:6

%@test:7
% Define a dates object
B = dates('1950Q1','1950Q2','1950Q3','1950Q4','1951Q1');

% Try to extract a sub-dates object.
try
    d = B([]);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(isa(d,'dates'), true);
    t(3) = isequal(isempty(d), true);
end
T = all(t);
%@eof:7

%@test:8
% Define a dates object
B = dates('1950-11-15','1950-11-16','1950-11-17','1950-11-18');

% Try to extract a sub-dates object.
try
    d = B([]);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(isa(d,'dates'), true);
    t(3) = isequal(isempty(d), true);
end
T = all(t);
%@eof:8

%@test:9
% Define a dates object
B = dates('1950-11-15','1950-11-16','1950-11-17','1950-11-18');

% Try to extract a sub-dates object.
try
    d = B(2);
    t(1) = true;
catch
    t(1) = false;
end

if t(1)
    t(2) = isequal(d.freq,B.freq);
    t(3) = isequal(d.time(1), 712543);
    t(4) = isequal(d.ndat(),1);
end
T = all(t);
%@eof:9