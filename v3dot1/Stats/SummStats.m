function [STATS, TABLE] = SummStats(DATA,p,vnames)
% =======================================================================
% Computes descriptive stats of a time series (or a matrix of time series)
% =======================================================================
% [stats, TABLE] = SummStats(TEMP,p)
% -----------------------------------------------------------------------
% INPUT
%   - TEMP  : T obs (rows) x N series (columns)
%   - p = order of time polynomial in the ADF null-hypothesis.
%         p ~exist, does not perform ADF test 
%         p = -1, no deterministic part
%         p =  0, for constant term
%         p =  1, for constant plus time-trend
%         p >  1, for higher order polynomial
% -----------------------------------------------------------------------
% OUTPUT
%   - stats: [Obs, mean, median, max, min, StDev, AutoCorr, Skew, Kurt,
%       ADF(4), ADF(4) Conf, ADF(8), ADF(8) Conf]
%   - TABLE: cell, matrix with the names of the stats & the stats
% -----------------------------------------------------------------------
% EXAMPLE:
%   DATA = rand(50,4);
%   [STATS, TABLE] = SummStats(DATA,2,{'Y','G','I','C'})
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% INITIALIZE VARIABLES
if ~exist('vnames','var')
    vnames = [];
else
    if size(vnames,1)>1
        vnames=vnames';
    end
end
[~, c] = size(DATA);

%% Compute summary statistics NaN are not considered (like in Excel)
mean    = nanmean(DATA);
median  = nanmedian(DATA);
max     = nanmax(DATA);	
min     = nanmin(DATA);	
StDev   = nanstd(DATA);
CV      = StDev./mean;

% Compute autocorrelation coefficient AutoCorr on the maximum number of
% observation available per series
for i=1:c
    X = DATA(:,i);
    if isnan(X)==1
        Obs(1,i)  = NaN;
        AutoCorr(1,i)  = NaN;
        Skew(1,i) = NaN;
        Kurt(1,i) = NaN;
        ADF4(1,i) = NaN;
        ADF4conf(1,i) = NaN;
        ADF8(1,i) = NaN;
        ADF8conf(1,i) = NaN;
    else
        X(any(isnan(X),2),:) = [];
        size_X    = size(X);
        Obs(1,i)  = size_X(1);
        AutoCorr(1,i)  = corr(X(2:end),X(1:end-1));
        Skew(1,i) = skewness(X);
        Kurt(1,i) = kurtosis(X);
        % If less than 20 observations don't do ADF4
        if length(X)<20 || ~exist('p','var')
            ADF4(1,i) = NaN;
            ADF4conf(1,i) = NaN;
        else
            test = adf(X,p,4);
            ADF4(1,i) = test.adf;
            if test.adf<test.crit(1)    % cannot reject the null of I(1)
                ADF4conf(1,i) = 0.01; 
            elseif test.adf<test.crit(2)
                ADF4conf(1,i) = 0.05;
            elseif test.adf<test.crit(3)
                ADF4conf(1,i) = 0.10;
            else                        % reject the null of I(1) --> I(0)
                ADF4conf(1,i) = NaN;
            end
        end
        % If less than 40 observations don't do ADF8
        if length(X)<40 || ~exist('p','var')
            ADF8(1,i) = NaN;
            ADF8conf(1,i) = NaN;
        else
            test = adf(X,p,8);
            ADF8(1,i) = test.adf;
            if test.adf<test.crit(1)
                ADF8conf(1,i) = 0.01;
            elseif test.adf<test.crit(2)
                ADF8conf(1,i) = 0.05;
            elseif test.adf<test.crit(3)
                ADF8conf(1,i) = 0.10;
            else
                ADF8conf(1,i) = NaN;
            end
        end
    end
end

% Create matrix with all summary stats
STATS = [Obs; mean; median; max; min; StDev; AutoCorr; Skew; Kurt; ADF4; ADF4conf; ADF8; ADF8conf; CV];

% Create titles
titles ={'Obs'; 'Mean'; 'Median'; 'Max'; 'Min'; 'St. Dev.'; 'Auto Corr.'; 'Skew.'; 'Kurt.'; 'ADF(4)'; 'ADF(4) Conf.'; 'ADF(8)'; 'ADF(8) Conf.'; 'Coeff. Variation'};

% Create cell 
TABLE = TabPrint(STATS,vnames,titles,4);


