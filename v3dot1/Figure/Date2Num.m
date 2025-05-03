function OUT = Date2Num(dates,frequency)
% =========================================================================
% Convert a cell array of dates into a double array. The first period of 
% the year is coded as a round number. For quarterly data the step change 
% is 0.25, so that 1984Q2 => 1984.25; For  monthly data the step change 
% is 0.833, so that 1984M2 => 1984.0833.
% =======================================================================
% OUT = Date2Num(DATA)
% -----------------------------------------------------------------------
% INPUTS 
%	- DATA: a (T x 1) vector with dates in cell format 
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency : monthly ('m'), quarterly ('q') [dflt] or annual ('y') 
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT:  a (T x 1) vector with dates in numeric format
% -----------------------------------------------------------------------
% EXAMPLE 
% 	dates = {'1992M1';'1992M2';'1992M3';'1992M4';'1992M5';};
%   OUT = Date2Num(dates,'m')
% -----------------------------------------------------------------------
% RELATED
%   - DatesCreate, DatesCount
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------


format long 
% Check inputs
if ~exist('frequency','var')
    frequency = 'q';
end
[n,c] = size(dates);

% Convert cell array into double array
if strcmp(frequency,'q')
    OUT = nan(n,c);
    for i=1:n
        for j=1:c
            aux = dates{i,j};
            year = str2double(aux(1:4));
            period = str2double(aux(6));
            OUT(i,j) = year + period/4 -0.25;
        end
    end
elseif strcmp(frequency,'m')
    OUT = nan(n,c);
    for i=1:n
        for j=1:c
            aux = dates{i,j};
            year = str2double(aux(1:4));
            period = str2double(aux(6:end));
            OUT(i,j) = year + period/12 -0.08333333333333333333333333333333;
        end
    end
end