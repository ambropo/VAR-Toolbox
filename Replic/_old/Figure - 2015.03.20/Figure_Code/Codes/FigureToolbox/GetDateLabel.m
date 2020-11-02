function label = GetDateLabel(opt)
% =======================================================================
% Create a vector of dates to be used as x label for a plot (used by
% lineplot.m)
% =======================================================================
% label = GetDateLabel(opt)
% -----------------------------------------------------------------------
% INPUT
%   - opt.timeline       : a cell array of the type 1999Q1
%   - opt.YearLabel   : 'short' for 99, 'long' for 1999
%   - opt.QuarterLabel: 'no' for 99, 'yes' for 99Q1
% OUTPUT
%   - label           : a cell array of dates
% =======================================================================
% Ambrogio Cesa Bianchi, February 2012
% ambrogio.cesabianchi@gmail.com


[r, ~] = size(opt.timeline);
label{r,1} = [];

for jj=1:r
    
    temp = char(opt.timeline(jj,1));
    
    if strcmp(opt.YearLabel,'short')
        
        if strcmp(opt.QuarterLabel,'no')
            label{jj,1} = temp(3:4);
        else
            label{jj,1} = temp(3:6);
        end
        
    elseif strcmp(opt.YearLabel,'long')
    
        if strcmp(opt.QuarterLabel,'no')
            label{jj,1} = temp(1:4);
        else
            label{jj,1} = temp(1:6);
        end
        
    end
end