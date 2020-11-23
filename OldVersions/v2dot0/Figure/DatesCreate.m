function [dates, dates_short] = DatesCreate(year,nobs,frequency,fo_period)
% =======================================================================
% Create a timeline (cell array) of the type 1999Q1. Can be used as an
% input for PlotOption, for the field opt.timeline
% =======================================================================
% [dates, dates_short] = DatesCreate(year,nobs,frequency,fo_period)
% -----------------------------------------------------------------------
% INPUT
%	- year: initial year of the timeline
%	- nobs: number of observations
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency: quarterly 'q' [def], monthly 'm', yearly 'y'
%	- fo_period : initial quarter/month of the timeline (not for yearly frequency)
% ----------------------------------------------------------------------- 
% OUTPUT
%	- dates: vector of dates
%	- dates_short: vector of dates only year
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% Check inputs
if ~exist('frequency','var')
    frequency = 'q';
end

% Set the first observation, eg first quarter, second month, etc
incr = fo_period;

% Create the timeline
if strcmp(frequency,'q')
    if ~exist('fo_period','var'), error('You need to provide first period'), end
    for ii=1:nobs
        if incr==5 % when incr=5 set it back to 1 and increase the year counter
            incr=1;
            year = year + 1;
        end
        dates(ii,1) = {[num2str(year) 'q' num2str(incr)]};
        incr = incr + 1;
    end
elseif strcmp(frequency,'m')
    if ~exist('fo_period','var'), error('You need to provide first period'), end
    for ii=1:nobs
        if incr==13 % when incr=5 set it back to 1 and increase the year counter
            incr=1;
            year = year + 1;
        end
        dates(ii,1) = {[num2str(year) 'm' num2str(incr)]};
        incr = incr + 1;
    end
elseif strcmp(frequency,'y')
    for ii=1:nobs
        dates(ii,1) = {num2str(year)};
        year = year + 1;
    end
end

% Create the short vector
for kk = 1:nobs
    aux = char(dates(kk,1));
    dates_short(kk,1) = {[aux(1:4)]};
end