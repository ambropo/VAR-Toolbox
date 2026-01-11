function [OUT, lags] = CrossCorrelation(X,Y,lag,do_plot,Yname)
% =======================================================================
% Computes the cross-correlation between the vector X (Tx1) and each 
% column of the matrix Y (TxN). If specified, it plots it
% =======================================================================
% [OUT lags] = CrossCorrelation(X,Y,lag,chart,row,col,)
% -----------------------------------------------------------------------
% INPUT
%   - X   = vector (Tx1) of interest [double]
%   - Y   = matrix (TxN) to correlate X with [double]
%   - lag = length of lags to consider [double]
% -----------------------------------------------------------------------
% OPTIONAL INPUT:
%   - do_plot = 1 for plot           [dflt 0]
%   - Yname = array (1xN) name of Y  [dflt Y#]
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT  = matrix (2*lag+1,N) of cross-correlations, where every column
%           is a variable [double]
%   - lags = vector of lags used [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   X = rand(50,1);
%   Y = rand(50,2);
%   [OUT lags] = CrossCorrelation(X,Y,5,1,{'Consumption','Investment'})
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% Check inputs
%==========================================================================
[a, b] = size(X);
[c, d] = size(Y);
if a ~= c
    disp('Error: vectors must have the same lenght')
    return
elseif b > 1
    disp('Error: X must be a Tx1 vector')
    return
elseif lag >= a-2
    disp('Error: too few observations. Reduce the number of lags')
    return
end
if exist('do_plot','var')==0
    do_plot = 0;
else
end

%% Compute the cross correlation with the max amount of observations
%==========================================================================
% Lead corr(Xt-1,Yt)
m = 1;
for jj=1:lag
    for ii=1:d
        OUT(m,ii) = corr(X(1:end-lag-1+jj),Y(1+lag+1-jj:end,ii));
    end
    m = m+1;
end

% Contemporaneous correlation
for ii=1:d
    OUT(m,ii) = corr(X,Y(:,ii));
end
m = m+1;

% Lag correlation corr(Xt+1,Yt)
for jj=1:lag
    for ii=1:d
        OUT(m,ii) = corr(X(1+jj:end),Y(1:end-jj,ii));
    end
    m = m+1;
end

lags = -lag:1:lag;

%% Plot an istogram with the cross correlations
%==========================================================================
if do_plot
    
    % If there are no Yname, create Yname (Y1, Y2,...)
    if ~exist('Yname','var')
        aux1 = 'Y';
        Yname(1,d) = {[]}; 
        for ii=1:d
            Yname(1,ii) = {[aux1 num2str(ii)]};
        end
        clear aux1 
    end
   
    % Dimension of the matrix to plot
    dim=size(OUT);
    ntotlags = dim(1);
    ntotvars = dim(2);
    row = round(sqrt(ntotvars));
    col = ceil(sqrt(ntotvars));
    
    % Plot
    for jj=1:row*col
        if jj>ntotvars; break; end
        subplot(row,col,jj);
        stem(lags,OUT(:,jj),'*k','fill','LineWidth',1)
        grid off;
        title(Yname(jj));
        set(gca, 'XTick', -lag:lag); % set the number of ticks
    end
end
 
