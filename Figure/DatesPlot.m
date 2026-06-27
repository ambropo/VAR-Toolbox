function DatesPlot(fo,nobs,nticks,frequency)
% =======================================================================
% Adds date labels to the horizontal axis of a chart. Works with monthly,
% quarterly, and yearly data
% =======================================================================
% DatesPlot(fo,nobs,nticks,frequency)
% -----------------------------------------------------------------------
% INPUT
%   - fo      : date of first observation (e.g. 1987.00 = 1987Q1) [double]
%   - nobs    : number of observations [double]
%   - nticks  : number of tick marks on the horizontal axis [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - frequency: monthly ('m'), quarterly ('q') or annual ('y') [dflt = 'q']
% -----------------------------------------------------------------------
% EXAMPLE
%   X = rand(20,1);
%   [dates, datesnum] = DatesCreate(2000,20,'q',1);
%   plot(X)
%   DatesPlot(datesnum(1),20,5,'q')
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
if ~exist('frequency','var')
    frequency = 'q';
end
if ~(strcmp(frequency,'y') || strcmp(frequency,'q') || strcmp(frequency,'m'))
    error('DatesPlot: frequency must be ''y'', ''q'', or ''m''')
end

%% 2. ANNUAL DATA
% -----------------------------------------------------------------------
if strcmp(frequency,'y')
    % Compute the last observation date
    lo = fo + nobs - 1;
    % Build full label vector from fo to lo
    labyear = [fo:lo]';
    nobslabyear = length(labyear);
    % Compute tick spacing and the highest tick position
    tick = round(nobs/nticks);
    tick_max = floor(nticks)*tick;
    % Extend the label vector if tick_max exceeds the current last date
    lo_new = lo;
    for ii=1:tick_max-nobslabyear
        lo_new = lo_new + 1;
    end
    labyear = [fo:lo_new]';
    % Apply tick marks and labels to the current axes
    set(gca,'xTick',tick:tick:tick_max,'xTickLabel',labyear(tick:tick:tick_max),'xLim',[0 nobs+1],'Layer','bottom');

%% 3. QUARTERLY DATA
% -----------------------------------------------------------------------
elseif strcmp(frequency,'q')
    % Compute the last observation date by stepping 0.25 per period
    lo = fo;
    for ii=1:nobs-1
        lo = lo + 0.25;
    end
    % Identify the first full year and how many obs precede it.
    % fo_diff is the 1-based index of the first Q4 in the series.
    % Derivation: (fo-fo_year) gives the within-year offset (Q1=0, Q2=0.25,
    % Q3=0.50, Q4=0.75). abs((fo-fo_year)-0.75) is the distance to Q4 in
    % year units; dividing by 0.25 gives the number of quarter-steps back to
    % Q4, and adding 1 converts to a 1-based observation index.
    fo_year = floor(fo);
    fo_diff = abs(fo-fo_year-0.75)/0.25+1;
    % Identify the last year (roll over if final quarter is Q4)
    if lo-floor(lo)==0.75
        lo_year = floor(lo)+1;
    else
        lo_year = floor(lo);
    end
    % Build the year label at every quarterly step
    labyear = floor([fo:.25:lo])';
    nobslabyear = length(labyear);
    % Compute tick spacing in observation units (4 obs per year)
    nobs_year = lo_year - fo_year + 1;
    tick = round(nobs_year/nticks);
    if floor(nticks)==nticks
        tick_max = floor(nticks)*(tick*4);
    else
        tick_max = floor(nticks)*(tick*4)+(tick*4);
    end
    % Extend the label vector to cover tick_max positions
    lo_new = lo;
    for ii=1:tick_max-nobslabyear
        lo_new = lo_new + 0.25;
    end
    labyear_new = floor([lo+.25:.25:lo_new])';
    labyear = [labyear; labyear_new];
    % Apply tick marks and labels to the current axes
    set(gca,'xTick',fo_diff:tick*4:tick_max,'xTickLabel',labyear(fo_diff:tick*4:tick_max),'xLim',[0 nobs+1],'Layer','bottom');

%% 4. MONTHLY DATA
% -----------------------------------------------------------------------
elseif strcmp(frequency,'m')
    % Compute the last observation date using exact rational arithmetic.
    % Accumulating 0.0833 (≈ 1/12) can accumulate floating-point drift over
    % long series; fo + (nobs-1)/12 is exact.
    lo = fo + (nobs-1)/12;
    % Identify the first full year and how many obs precede it.
    % fo_diff is the 1-based index of the first M12 (December) in the series.
    % Using round() avoids floating-point misparse of the fractional part.
    fo_year = floor(fo);
    fo_diff = 12 - round(12*(fo - fo_year));
    % Identify the last year (roll over if final month is M12)
    if round(12*(lo - floor(lo))) == 11
        lo_year = floor(lo)+1;
    else
        lo_year = floor(lo);
    end
    % Build the year label at every monthly step using exact 1/12 steps
    labyear = floor(fo : 1/12 : lo)';
    nobslabyear = length(labyear);
    % Compute tick spacing in observation units (12 obs per year)
    nobs_year = lo_year - fo_year + 1;
    tick = round(nobs_year/nticks);
    if floor(nticks)==nticks
        tick_max = floor(nticks)*(tick*12);
    else
        tick_max = floor(nticks)*(tick*12)+(tick*12);
    end
    % Extend the label vector to cover tick_max positions using exact 1/12 steps
    lo_new = lo + (tick_max - nobslabyear)/12;
    labyear_new = floor(lo+1/12 : 1/12 : lo_new)';
    labyear = [labyear; labyear_new];
    % Apply tick marks and labels to the current axes
    set(gca,'xTick',fo_diff:tick*12:tick_max,'xTickLabel',labyear(fo_diff:tick*12:tick_max),'xLim',[0 nobs+1],'Layer','bottom');

end
