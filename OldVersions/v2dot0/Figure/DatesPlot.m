function DatesPlot(fo,nobs,nticks,frequency)
% =======================================================================
% Adds dates to the horizontal axis of a chart. Works with quarterly and
% yearly data
% =======================================================================
% DatesPlot(fo,nobs,nticks,frequency)
% -----------------------------------------------------------------------
% INPUT
%   - fo: date of first observation (convention: 1987.00 = 1987Q1)
%   - nobs: number of observations
%   - tick: number ticks
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency : quarterly ('q') or annual ('y') frequency. Default: 'q'
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% INITIALIZE VARIABLES
if ~exist('frequency','var')
    frequency = 'q';
end


%% ANNUAL DATA
if strcmp(frequency,'y')
    % Compute last observation
    lo = fo+nobs-1;
    % Create vector of dates from "fo" to "lo"
    labyear = [fo:lo]';
    % Compute the ticks
    tick = round(nobs/nticks);
    tick_max = floor(nticks)*tick;
    % Set the labels
    set(gca,'xTick',tick:tick:tick_max,'xTickLabel',labyear(tick:tick:tick_max),'xLim',[0 nobs+1],'Layer','top');
   
%% QUARTERLY DATA
elseif strcmp(frequency,'q')
    % Compute last observation
    lo = fo;
    for ii=1:nobs-1
        lo = lo + 0.25;
    end 
    % Compute the first year and # of observations to get there
    fo_year = floor(fo);
    fo_diff = abs(fo-fo_year-0.75)/0.25+1;
    % Compute the last year # of observations after that 
    if lo-floor(lo)==0.75
        lo_year = floor(lo)+1;
    else
        lo_year = floor(lo);
    end
    % Create vector of dates from "fo" to "lo"
    labyear = floor([fo:.25:lo])';
    nobslabyear = length(labyear);
    % Compute the ticks
    nobs_year = lo_year - fo_year +1;
    tick = round(nobs_year/nticks);
    if floor(nticks)==nticks
        tick_max = floor(nticks)*(tick*4);
    else
        tick_max = floor(nticks)*(tick*4)+(tick*4);
    end
    % Compute new last observation
    lo_new = lo;
    for ii=1:tick_max-nobslabyear
        lo_new = lo_new + 0.25;
    end 
    labyear_new = floor([lo+.25:.25:lo_new])';
    labyear = [labyear; labyear_new];

    set(gca,'xTick',fo_diff:tick*4:tick_max,'xTickLabel',labyear(fo_diff:tick*4:tick_max),'xLim',[0 nobs+1],'Layer','top');
end   
