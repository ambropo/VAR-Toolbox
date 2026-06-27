function OUT = Date2Num(dates,frequency)
% =======================================================================
% Convert a cell array of date strings into a double array. The first
% period of the year is coded as a round number. For quarterly data the
% step is 0.25, so 1984q2 => 1984.25; for monthly data the step is
% 1/12, so 1984m2 => 1984.0833.
% =======================================================================
% OUT = Date2Num(dates,frequency)
% -----------------------------------------------------------------------
% INPUT
%   - dates: cell array of date strings (e.g. '1984q2') [T x 1]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency: monthly ('m'), quarterly ('q') [dflt = 'q'], or annual ('y')
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: vector of dates in numeric format [T x 1]
% -----------------------------------------------------------------------
% EXAMPLE
%   dates = {'1992m1';'1992m2';'1992m3';'1992m4';'1992m5'};
%   OUT = Date2Num(dates,'m')
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Default frequency is quarterly. Expected date string format: 'yyyyqp'
% for quarterly (e.g. '1984q2'), 'yyyympp' for monthly (e.g. '1984m11').
% Malformed strings will silently misparse; no format validation is performed.
if ~exist('frequency','var')
    frequency = 'q';
end
if ~(strcmp(frequency,'y') || strcmp(frequency,'q') || strcmp(frequency,'m'))
    error('Date2Num: frequency must be ''y'', ''q'', or ''m''')
end
[n,c] = size(dates);

%% 2. CONVERT STRING LABELS TO NUMERIC DATES
% -----------------------------------------------------------------------
% Numeric date convention: period 1 of any year maps to a round integer.
%   quarterly: 1984Q1 = 1984.00, 1984Q2 = 1984.25, ...
%     formula: year + period/4 - 0.25  (subtracting 1/freq shifts period 1 to 0)
%   monthly:   1984M1 = 1984.00, 1984M2 = 1984.0833, ...
%     formula: year + period/12 - 1/12
if strcmp(frequency,'q')
    OUT = nan(n,c);
    for i=1:n
        for j=1:c
            aux    = dates{i,j};
            year   = str2double(aux(1:4));
            period = str2double(aux(6));      % single character: Q1..Q4
            OUT(i,j) = year + period/4 - 0.25;
        end
    end
elseif strcmp(frequency,'m')
    OUT = nan(n,c);
    for i=1:n
        for j=1:c
            aux    = dates{i,j};
            year   = str2double(aux(1:4));
            period = str2double(aux(6:end));  % one or two characters: M1..M12
            OUT(i,j) = year + period/12 - 1/12;
        end
    end
elseif strcmp(frequency,'y')
    OUT = nan(n,c);
    for i=1:n
        for j=1:c
            OUT(i,j) = str2double(dates{i,j});
        end
    end
end
