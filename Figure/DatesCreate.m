function [dates, datesnum] = DatesCreate(year,nobs,frequency,first)
% =======================================================================
% Create a vector of dates of the type 1999q2 [cell] and 1997.25 [double]
% =======================================================================
% [dates, datesnum] = DatesCreate(year,nobs,frequency,first)
% -----------------------------------------------------------------------
% INPUT
%   - year: initial year of the timeline [double]
%   - nobs: number of observations [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency: quarterly 'q' [dflt], monthly 'm', yearly 'y'
%   - first: initial quarter/month of the timeline [dflt = 1]
%       (not applicable for yearly frequency)
% -----------------------------------------------------------------------
% OUTPUT
%   - dates   : cell vector of date labels (e.g. '1997q2') [nobs x 1]
%   - datesnum: numeric vector of dates (convention 1997q2 = 1997.25) [nobs x 1]
% -----------------------------------------------------------------------
% EXAMPLE
%   [dates, datesnum] = DatesCreate(1996,40,'q',3)
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Set defaults for optional arguments: quarterly frequency and first
% period equal to 1.
if ~exist('frequency','var')
    frequency = 'q';
end
if ~exist('first','var')
    first = 1;
end

% Validate frequency string
if ~(strcmp(frequency,'y') || strcmp(frequency,'q') || strcmp(frequency,'m'))
    error('DatesCreate: frequency must be ''y'', ''q'', or ''m''')
end

%% 2. BUILD TIMELINE
% -----------------------------------------------------------------------
% period is the current within-year period number (1–4 for quarterly,
% 1–12 for monthly). When it exceeds the number of periods per year it
% wraps back to 1 and the year counter is incremented.
% datesnum follows the convention: period 1 of year Y = Y.00.
period = first;

% Iterate over observations and build date label and numeric date vectors
if strcmp(frequency,'q')
    for ii=1:nobs
        if period==5  % wrap: Q4 was just stored, move to Q1 of the next year
            period = 1;
            year = year + 1;
        end
        dates(ii,1)    = {[num2str(year) 'q' num2str(period)]};
        datesnum(ii,1) = year + period/4 - 0.25;  % Q1=year.00, Q2=year.25, ...
        period = period + 1;
    end
elseif strcmp(frequency,'m')
    for ii=1:nobs
        if period==13  % wrap: M12 was just stored, move to M1 of the next year
            period = 1;
            year = year + 1;
        end
        dates(ii,1)    = {[num2str(year) 'm' num2str(period)]};
        datesnum(ii,1) = year + period/12 - 1/12;  % M1=year.00, M2=year.0833, ...
        period = period + 1;
    end
elseif strcmp(frequency,'y')
    for ii=1:nobs
        dates(ii,1)    = {num2str(year)};
        datesnum(ii,1) = year;
        year = year + 1;
    end
end
