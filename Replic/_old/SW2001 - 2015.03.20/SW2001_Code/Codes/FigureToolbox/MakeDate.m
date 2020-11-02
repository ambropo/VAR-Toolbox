function [dates, dates_short] = MakeDate(year,quarter,nobs)
% =======================================================================
% Create a timeline (cell array) of the type 1999Q1. Can be used as an
% input for PlotOption, for the field opt.timeline
% =======================================================================
% dates = MakeDate(year,quarter,nobs)
% -----------------------------------------------------------------------
% INPUTS 
%	- year    : initial year of the timeline
%	- quarter : initial quarter of the timeline
%	- nobs    : number of quarters
%
% =========================================================================
% Ambrogio Cesa Bianchi, February 2012
% ambrogio.cesabianchi@gmail.com

% Set the index for the quarter (i.e. "incr") to the initial quarter
incr = quarter;

% Create the timeline
for ii=1:nobs
    if incr==5 % when incr=5 set it back to 1 and increase the year counter
        incr=1;
        year = year + 1;
    end
    dates(ii,1) = {[num2str(year) 'Q' num2str(incr)]};
    incr = incr + 1;
end

for kk = 1:nobs
    aux = char(dates(kk,1));
    dates_short(kk,1) = {[aux(1:4)]};
end