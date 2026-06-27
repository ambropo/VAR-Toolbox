function [STATS, TABLE] = SummStats(DATA,p,vnames)
% =======================================================================
% Compute descriptive statistics for a matrix of time series, including
% moments, autocorrelation, and ADF unit-root tests at 4 and 8 lags.
% =======================================================================
% [STATS, TABLE] = SummStats(DATA,p,vnames)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: T obs (rows) x N series (columns) [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - p     : order of time polynomial in the ADF null hypothesis;
%             required to run ADF tests [dflt = no ADF test]
%               p = -1: no deterministic part
%               p =  0: constant term
%               p =  1: constant plus time-trend
%               p >  1: higher-order polynomial
%   - vnames: cell array (1xN) of series names [dflt = empty]
% -----------------------------------------------------------------------
% OUTPUT
%   - STATS: 14 x N matrix with rows [Obs, Mean, Median, Max, Min,
%            StDev, AutoCorr, Skew, Kurt, ADF(4), ADF(4) Conf, ADF(8),
%            ADF(8) Conf, Coeff. Variation] [double]
%   - TABLE: cell array with row/column labels and formatted stat values
%            [cell]
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = randn(100,4);
%   [STATS, TABLE] = SummStats(DATA, 0, {'Y','G','I','C'});
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS AND INITIALISE
% -----------------------------------------------------------------------
% Validate required input and resolve optional arguments.
if nargin < 1
    error('SummStats: DATA is a required input.')
end
if ~exist('vnames','var')
    vnames = [];
else
    % Ensure variable names are a row cell array
    if size(vnames,1) > 1
        vnames = vnames';
    end
end
[~, c] = size(DATA);

%% 2. COMPUTE SUMMARY STATISTICS
% -----------------------------------------------------------------------
% NaN values are ignored throughout (equivalent to Excel behaviour).
% Variable names mean/median/max/min are avoided to prevent shadowing
% MATLAB built-ins.
xmean   = mean(DATA,   'omitnan');
xmedian = median(DATA, 'omitnan');
xmax    = max(DATA, [], 'omitnan');
xmin    = min(DATA, [], 'omitnan');
xStDev  = std(DATA,    'omitnan');
xCV     = xStDev ./ xmean;

% Preallocate per-series stat vectors
Obs      = nan(1,c);
AutoCorr = nan(1,c);
Skew     = nan(1,c);
Kurt     = nan(1,c);
ADF4     = nan(1,c);
ADF4conf = nan(1,c);
ADF8     = nan(1,c);
ADF8conf = nan(1,c);

% Compute per-series statistics that require NaN removal
for i=1:c
    X = DATA(:,i);
    if all(isnan(X))
        % Entirely missing series: fill all stats with NaN
        Obs(1,i)      = NaN;
        AutoCorr(1,i) = NaN;
        Skew(1,i)     = NaN;
        Kurt(1,i)     = NaN;
        ADF4(1,i)     = NaN;
        ADF4conf(1,i) = NaN;
        ADF8(1,i)     = NaN;
        ADF8conf(1,i) = NaN;
    else
        % Drop NaN rows before computing autocorrelation and ADF tests
        X(any(isnan(X),2),:) = [];
        size_X        = size(X);
        Obs(1,i)      = size_X(1);
        AutoCorr(1,i) = corr(X(2:end), X(1:end-1)); % lag-1 autocorrelation
        Skew(1,i)     = skewness(X);
        Kurt(1,i)     = kurtosis(X);

        % ADF with 4 lags: require at least 20 observations
        if length(X)<20 || ~exist('p','var')
            ADF4(1,i)     = NaN;
            ADF4conf(1,i) = NaN;
        else
            test = adf(X,p,4);
            ADF4(1,i) = test.adf;
            if test.adf < test.crit(1)       % reject at 1%: series is I(0)
                ADF4conf(1,i) = 0.01;
            elseif test.adf < test.crit(2)   % reject at 5%
                ADF4conf(1,i) = 0.05;
            elseif test.adf < test.crit(3)   % reject at 10%
                ADF4conf(1,i) = 0.10;
            else                             % cannot reject I(1) null
                ADF4conf(1,i) = NaN;
            end
        end

        % ADF with 8 lags: require at least 40 observations
        if length(X)<40 || ~exist('p','var')
            ADF8(1,i)     = NaN;
            ADF8conf(1,i) = NaN;
        else
            test = adf(X,p,8);
            ADF8(1,i) = test.adf;
            if test.adf < test.crit(1)
                ADF8conf(1,i) = 0.01;
            elseif test.adf < test.crit(2)
                ADF8conf(1,i) = 0.05;
            elseif test.adf < test.crit(3)
                ADF8conf(1,i) = 0.10;
            else
                ADF8conf(1,i) = NaN;
            end
        end
    end
end

% Assemble all statistics into a single matrix (14 rows x N columns)
STATS = [Obs; xmean; xmedian; xmax; xmin; xStDev; AutoCorr; Skew; Kurt; ...
         ADF4; ADF4conf; ADF8; ADF8conf; xCV];

% Row labels matching STATS row order
titles = {'Obs'; 'Mean'; 'Median'; 'Max'; 'Min'; 'St. Dev.'; 'Auto Corr.'; ...
          'Skew.'; 'Kurt.'; 'ADF(4)'; 'ADF(4) Conf.'; 'ADF(8)'; ...
          'ADF(8) Conf.'; 'Coeff. Variation'};

% Format as a labelled cell table
TABLE = TabPrint(STATS, vnames, titles, 4);
