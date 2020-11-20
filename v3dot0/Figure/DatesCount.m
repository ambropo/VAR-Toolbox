function dates = DatesCount(fo_year,lo_year,frequency,fo_period,lo_period)
% =======================================================================
% Create a timeline (cell array) of the type 1999Q1 for a given initial 
% observation, final observation and frequency. To do that,the function
% uses DatesCreate
% =======================================================================
% opt = DatesCount(fo_year,lo_year,frequency,fo_period,lo_period)
% -----------------------------------------------------------------------
% INPUT
%	- fo_year: initial year of the timeline
%	- lo_year: final year of the timeline
%	- frequency: quarterly 'q' [default], monthly 'm', yearly 'y'
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - fo_period: initial quarter/month of the timeline [default = 1]
%       (not for yearly frequency)
%   - lo_period: last quarter/month of the timeline 
% ----------------------------------------------------------------------- 
% OUTPUT
%	- dates: cell array of dates
%	- nobs: number of observations
% =======================================================================
% EXAMPLE 
%   - Create a monthly cell array from 1999M6 to 2012M12:
%       [dates, nobs] = DatesCount(1999,2012,'m',6,12)
% RELATED
%   - DatesCreate, Date2Num
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

dates = DatesCreate(fo_year,nobs,frequency,fo_period);