function [dates, datesnum] = DatesCreate(year,nobs,frequency,first)
% =======================================================================
% Create a vector of dates of the type 1999Q2 [cell] and 1997.25 [double]
% =======================================================================
% [dates, datesnum] = DatesCreate(year,nobs,frequency,first)
% -----------------------------------------------------------------------
% INPUT
%	- year: initial year of the timeline
%	- nobs: number of observations
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency: quarterly 'q' [dflt], monthly 'm', yearly 'y'
%   - first: initial quarter/month of the timeline [dflt = 1]
%       (not for yearly frequency)
% ----------------------------------------------------------------------- 
% OUTPUT
%	- dates: vector of dates (1997Q2)
%	- datesnum: vector of dates (convention 1997Q2 = 1997.25)
% -----------------------------------------------------------------------
% EXAMPLE 
% 	dates = DatesCreate(1996,40,'q',3)
%
% RELATED
%   - DatesCount, Date2Num
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------


% Check inputs
if ~exist('frequency','var')
    frequency = 'q';
end

if ~(strcmp(frequency,'y') || strcmp(frequency,'q') || strcmp(frequency,'m'))
    error('Frequency should be either ''y'', ''q'', or ''m''')
end

% Set the first observation, eg first quarter, second month, etc
incr = first;

% Create the timeline
if strcmp(frequency,'q')
    if ~exist('first','var'); first=1; end
    for ii=1:nobs
        if incr==5 % when incr=5 set it back to 1 and increase the year counter
            incr=1;
            year = year + 1;
        end
        dates(ii,1) = {[num2str(year) 'q' num2str(incr)]};
        datesnum(ii,1) = year+incr/4;
        incr = incr + 1;
    end
elseif strcmp(frequency,'m')
    if ~exist('first','var'); first=1; end
    for ii=1:nobs
        if incr==13 % when incr=13 set it back to 1 and increase the year counter
            incr=1;
            year = year + 1;
        end
        dates(ii,1) = {[num2str(year) 'm' num2str(incr)]};
        datesnum(ii,1) = year+incr/12;
        incr = incr + 1;
    end
elseif strcmp(frequency,'y')
    for ii=1:nobs
        dates(ii,1) = {num2str(year)};
        datesnum(ii,1) = year;
        year = year + 1;
    end
end