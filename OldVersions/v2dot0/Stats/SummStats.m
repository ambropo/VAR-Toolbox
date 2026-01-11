function [stats, TABLE] = SummStats(TEMP,p)
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
%   - stats: [Obs, mean, median, max, min, StDev, AutoCorr, Skew, Kurt,...
%       ADF(4), ADF(4) Conf, ADF(8), ADF(8) Conf]
%   - TABLE: cell, matrix with the names of the stats & the stats
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015

[~, c] = size(TEMP);

% Compute summary statistics NaN are not considered (like in Excel)
mean    = nanmean(TEMP);
median  = nanmedian(TEMP);
max     = nanmax(TEMP);	
min     = nanmin(TEMP);	
StDev   = nanstd(TEMP);
CV      = StDev./mean;

% Compute autocorrelation coefficient AutoCorr on the maximum number of
% observation available per series
for i=1:c
    X = TEMP(:,i);
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
            if test.adf<test.crit(1)    % cannot reject the null of I(0)
                ADF4conf(1,i) = 0.01; 
            elseif test.adf<test.crit(2)
                ADF4conf(1,i) = 0.05;
            elseif test.adf<test.crit(3)
                ADF4conf(1,i) = 0.10;
            else                        % reject the null of I(0) => I(1)
                ADF4conf(1,i) = 0;
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
                ADF8conf(1,i) = 0;
            end
        end
    end
end

% Create matrix with all summary stats
stats = [Obs; mean; median; max; min; StDev; AutoCorr; Skew; Kurt; ADF4; ADF4conf; ADF8; ADF8conf; CV];

% Create titles
titles ={'Obs'; 'Mean'; 'Median'; 'Max'; 'Min'; 'St. Dev.'; 'Auto Corr.'; 'Skew.'; 'Kurt.'; 'ADF(4)'; 'ADF(4) Conf.'; 'ADF(8)'; 'ADF(8) Conf.'; 'Coeff. Variation'};

% Create cell 
TABLE = TabPrint(stats,[],titles);


