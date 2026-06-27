function [OUT, lags] = CrossCorrelation(X,Y,lag,do_plot,Yname)
% =======================================================================
% Computes the cross-correlation between the vector X (Tx1) and each
% column of the matrix Y (TxN). If specified, it plots it
% =======================================================================
% [OUT, lags] = CrossCorrelation(X,Y,lag,do_plot,Yname)
% -----------------------------------------------------------------------
% INPUT
%   - X      : vector (Tx1) of interest [double]
%   - Y      : matrix (TxN) to correlate X with [double]
%   - lag    : number of leads and lags to compute [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - do_plot: 1 to produce a stem plot of cross-correlations [dflt = 0]
%   - Yname  : array (1xN) of variable names for plot titles [dflt = Y1,Y2,...]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT  : matrix (2*lag+1 x N) of cross-correlations; each column is
%            one variable in Y, ordered from -lag to +lag.
%            Negative index: X leads Y (X is earlier in time);
%            zero: contemporaneous; positive: X lags behind Y. [double]
%   - lags : vector (-lag:lag) of lag indices; sign convention as above [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(50,1);
%   Y = randn(50,3);
%   [OUT, lags] = CrossCorrelation(X,Y,5);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate required inputs, check dimension compatibility, and set defaults
% for optional arguments.
if nargin < 3
    error('CrossCorrelation: X, Y, and lag are required inputs.')
end
[a, b] = size(X);
[c, d] = size(Y);
if a ~= c
    error('CrossCorrelation: X and Y must have the same number of rows.')
elseif b > 1
    error('CrossCorrelation: X must be a Tx1 column vector.')
elseif lag >= a-2
    error('CrossCorrelation: too few observations for the requested lag length.')
end

% Default: suppress plot output
if ~exist('do_plot','var')
    do_plot = 0;
end

%% 2. COMPUTE CROSS-CORRELATIONS
% -----------------------------------------------------------------------
% OUT has 2*lag+1 rows: rows 1..lag are leads (X leads Y), row lag+1 is
% contemporaneous, rows lag+2..2*lag+1 are lags (X lags Y).
% Window sizes: a shift of k periods (lead or lag) uses T-k observations
% (the maximum available), so lead and lag window sizes are symmetric.
% Row 1 corresponds to lags(1) = -lag (X leads Y by 'lag' periods).
OUT = nan(2*lag+1, d);

% Lead correlations: corr(X_{t-jj}, Y_t), jj = 1..lag
m = 1;
for jj=1:lag
    for ii=1:d
        OUT(m,ii) = corr(X(1:end-lag-1+jj), Y(1+lag+1-jj:end,ii));
    end
    m = m+1;
end

% Contemporaneous correlation: corr(X_t, Y_t)
for ii=1:d
    OUT(m,ii) = corr(X, Y(:,ii));
end
m = m+1;

% Lag correlations: corr(X_{t+jj}, Y_t), jj = 1..lag
for jj=1:lag
    for ii=1:d
        OUT(m,ii) = corr(X(1+jj:end), Y(1:end-jj,ii));
    end
    m = m+1;
end

% Build lag index vector
lags = -lag:1:lag;

%% 3. PLOT STEM CHART OF CROSS-CORRELATIONS
% -----------------------------------------------------------------------
% Produces one stem panel per Y variable in a near-square subplot grid,
% with lead/lag indices on the x-axis and correlations on the y-axis.
if do_plot

    % Build default variable names Y1, Y2, ... if none provided
    if ~exist('Yname','var')
        Yname = cell(1,d);
        for ii=1:d
            Yname{1,ii} = ['Y' num2str(ii)];
        end
    end

    % Arrange subplots in a near-square grid
    ntotvars = d;
    row = round(sqrt(ntotvars));
    col = ceil(sqrt(ntotvars));

    % One stem panel per variable
    for jj=1:row*col
        if jj>ntotvars; break; end
        subplot(row,col,jj);
        stem(lags, OUT(:,jj), '*k', 'fill', 'LineWidth', 1)
        grid off;
        title(Yname(jj));
        set(gca, 'XTick', -lag:lag);
    end
end
