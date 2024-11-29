function OUT = Date2Cell(dates,frequency)
% =========================================================================
% Convert a double array of dates into a cell array. The first period of 
% the year is coded as a round number. 
% =======================================================================
% OUT = Date2Cell(DATA)
% -----------------------------------------------------------------------
% INPUTS 
%	- DATA: a (T x 1) vector with dates in double format 
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency : monthly ('m'), quarterly ('q') [dflt] or annual ('y') 
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT:  a (T x 1) vector with dates in string format
% -----------------------------------------------------------------------
% EXAMPLE 
% 	dates = [1992; 1992.25; 1992.5'; 1992.75; 1993];
% 	OUT = Date2Cell(dates,'q')
% -----------------------------------------------------------------------
% RELATED
%   - Dates2Num, DatesCreate, DatesCount
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% August 2021
% -----------------------------------------------------------------------

% Stops Matlab from showing exponentials
format long g

% Check inputs
if ~exist('frequency','var')
    frequency = 'q';
end
[r,c] = size(dates);

% Convert cell array into double array
if strcmp(frequency,'q')
    OUT = {};
    for i=1:r
        for j=1:c
            year = floor(dates(i,j));
            period = 4*(dates(i,j)-year)+1;
            OUT{i,j} = [num2str(year) 'Q' num2str(period)];
        end
    end
elseif strcmp(frequency,'m')
    OUT = {};
    for i=1:r
        for j=1:c
            year = floor(dates(i,j));
            period = 12*(dates(i,j)-year)+1;
            OUT{i,j} = [num2str(year) 'M' num2str(period)];
        end
    end
end