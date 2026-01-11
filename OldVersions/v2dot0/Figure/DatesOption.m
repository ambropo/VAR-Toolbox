function out = DatesOption(fo_year,lo_year,frequency,fo_period,lo_period)
% =======================================================================
% For given initial observation, final observation and frequency this 
% function computes the number of observations between them and creates a
% cell aray with the dates (of the type 1979M2).
% =======================================================================
% out = DatesOption(fo_year,lo_year,frequency,fo_period,lo_period)
% -----------------------------------------------------------------------
% INPUT
%	- fo_year: initial year of the timeline
%	- lo_year: final year of the timeline
%	- frequency: quarterly 'q' [def], monthly 'm', yearly 'y'
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - fo_period: initial quarter/month of the timeline (not for 
%       yearly frequency)
%   - lo_period: last quarter/month of the timeline (not for yearly 
%       frequency)
% ----------------------------------------------------------------------- 
% OUTPUT
%	- out: structuree with all info
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% Check inputs
if ~exist('frequency','var')
    frequency = 'q';
end

if strcmp(frequency,'m')
    if ~exist('fo_period','var'), error('You need to provide first period'), end
    if ~exist('lo_period','var'), error('You need to provide last period'), end
    fo = fo_year + fo_period*(1/12);
    lo = lo_year + lo_period*(1/12);
    aux = fo:(1/12):lo;
    nobs = length(aux);
elseif strcmp(frequency,'q')
    if ~exist('fo_period','var'), error('You need to provide first period'), end
    if ~exist('lo_period','var'), error('You need to provide last period'), end
    fo = fo_year + fo_period*(1/4);
    lo = lo_year + lo_period*(1/4);
    aux = fo:(1/4):lo;
    nobs = length(aux);
elseif strcmp(frequency,'y')
    fo = fo_year;
    lo = lo_year;
    aux = fo:lo;
    nobs = length(aux);
end

% Get first
if strcmp(frequency,'y')
    [out.dates, out.dates_short] = DatesCreate(fo_year,nobs,frequency);
else
    [out.dates, out.dates_short] = DatesCreate(fo_year,nobs,frequency,fo_period);
end

out.nobs = nobs;
out.fo_year = fo_year;
out.lo_year = lo_year;
out.frequency = frequency;
out.fo_period = fo_period;
out.lo_period = lo_period;

