function OUT = Date2Cell(dates,frequency)
% =======================================================================
% Convert a double array of dates into a cell array of string labels.
% The first period of the year is coded as a round number.
% =======================================================================
% OUT = Date2Cell(dates,frequency)
% -----------------------------------------------------------------------
% INPUT
%   - dates: vector of dates in double format [T x 1]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency: monthly ('m'), quarterly ('q') [dflt = 'q'], or annual ('y')
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: cell array of date strings (e.g. '1992q2') [T x 1]
% -----------------------------------------------------------------------
% EXAMPLE
%   dates = [1992; 1992.25; 1992.5; 1992.75; 1993];
%   OUT = Date2Cell(dates,'q')
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: August 2021. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Default frequency is quarterly.
if ~exist('frequency','var')
    frequency = 'q';
end
if ~(strcmp(frequency,'y') || strcmp(frequency,'q') || strcmp(frequency,'m'))
    error('Date2Cell: frequency must be ''y'', ''q'', or ''m''')
end
[r,c] = size(dates);

%% 2. CONVERT NUMERIC DATES TO STRING LABELS
% -----------------------------------------------------------------------
% Numeric date convention: 1992Q1 = 1992.00, 1992Q2 = 1992.25, etc.
% The fractional part encodes the within-year period:
%   period = freq * (date - year) + 1
% where freq is 4 (quarterly) or 12 (monthly). Adding 1 shifts from
% zero-based to one-based period numbering.

% Dispatch on frequency and build the string label for each element
if strcmp(frequency,'q')
    OUT = {};
    for i=1:r
        for j=1:c
            year   = floor(dates(i,j));
            period = round(4*(dates(i,j)-year)) + 1;
            OUT{i,j} = [num2str(year) 'q' num2str(period)];
        end
    end
elseif strcmp(frequency,'m')
    OUT = {};
    for i=1:r
        for j=1:c
            year   = floor(dates(i,j));
            period = round(12*(dates(i,j)-year)) + 1;
            OUT{i,j} = [num2str(year) 'm' num2str(period)];
        end
    end
elseif strcmp(frequency,'y')
    OUT = {};
    for i=1:r
        for j=1:c
            OUT{i,j} = num2str(floor(dates(i,j)));
        end
    end
end
