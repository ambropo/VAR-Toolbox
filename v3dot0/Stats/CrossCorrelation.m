function [OUT, lags] = CrossCorrelation(X,Y,lag,chart,row,col,title_Y,title_X,name)
% =========================================================================
% Computes the cross-correlation between X_t+lag and Y_t. If specified, it
% plots it
% =========================================================================
% [OUT lags] = CrossCorrelation(X,Y,lag,chart,row,col,title_Y,title_X,name)
% -------------------------------------------------------------------------
% INPUT
%   - X   = vector (Tx1) to compute the correlation at different lead/lags
%   - Y   = matrix (TxN) of series
%   - lag = scalar of the length of lags
% -------------------------------------------------------------------------
% OPTIONAL INPUT:
%   - chart   = string: 'plot' to plot charts      (default 'no_plot')
%   - row     = scalar number of row in subplot    (default 2)
%   - col     = scalar number of col in subplot    (default 3)
%   - title_Y = cell (1xN) titles of Y             (default 'series #')
%   - title_X = cell (1x1) title of X for suptitle (default no suptitle)
%   - name    = string, file name to be saved      (default 'CrossCorr')
% -------------------------------------------------------------------------
% OUTPUT
%   - OUT  = matrix (2*lag+1,N) of cross-corr (every column is a variable)
%   - lags = vector of lags used (useful for plots)
% =========================================================================
% Example
% X = rand(50,1);
% Y = rand(50,6);
% [OUT lags] = CrossCorrelation(X,Y,5,'plot')
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015


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

if exist('chart','var')==0
    chart = 'no_plot';
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

% Contenporaneous correlation
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
if strmatch(chart,'plot') == 1
    
    % If there are no title_Y, create title_Y (series1, series2,...)
    if exist('title_Y','var') == 0
        aux1 = 'series';
        title_Y(1,d) = {[]}; 
        for ii=1:d
            title_Y(1,ii) = {[aux1 num2str(ii)]};
        end
        clear aux1 
    else
    end
   
    % Some parameters for the charts
    font_size = 12;

    % Dimension of the matrix to plot
    dim=size(OUT);
    last = dim(1);
    NumTotVar   = dim(2);
    Xaxis       = zeros(last,1);

    if exist('row','var')==0 && exist('col','var')==0
        row = 2; 
        col = 3;
    end

    % Determine how many figures are produced
    NumGraphXPage = row*col;
    p = floor(NumTotVar./NumGraphXPage);
    q = (NumTotVar./NumGraphXPage);
    if NumGraphXPage>=NumTotVar
        NumTotFigures=1;
    elseif p==q
        NumTotFigures=p;
    else
        NumTotFigures=p+1;
        rest = NumTotVar-(NumTotFigures-1)*NumGraphXPage;
    end
    clear p q

    % Store in is_empty the NaN column in the plot matrices (if any)
    is_empty = isnan(OUT(:,:));

    % Plot
    jj=1;
    for n=1:NumTotFigures;
        for j=1:NumGraphXPage;
            if jj>NumTotVar % to solve if I put more NumGraphXPage 
                subplot(row,col,j)
                plot(1:10,'LineStyle','none')
                axis off
            else
                if is_empty(1,jj)==1
                    jj=jj+1;
                else
                    subplot(row,col, j);
    %                 bar(lags,OUT(:,jj),'b');
                    stem(lags,OUT(:,jj),'*k','fill','LineWidth',1)
    %                 plot(lags,Xaxis,'k-');
                    grid off;
                    message=strcat(title_Y(:,jj));
                    title(message,'FontSize',font_size);
                    set( gca,'FontSize',font_size-3   );
                    set( gca, 'Box','off'           );
    %                 set(gca, 'XTick', 0:last/NumTicks:last); % set the number of ticks
    %                 xlabel('Lags','Fontsize',font_size-3)
    %                 ylabel('Correlation','Fontsize',font_size-3)
                    jj=jj+1;
                end
            end
        end

        % Save the image
        if exist('name','var') == 1
            figname = name;
        else
            figname = 'CrossCorr';
        end
        if NumTotFigures > 1
            figname = [figname num2str(n)];
        end
        
        set(gcf, 'Color', 'w');
        export_fig(figname,'-pdf','-png')
        clf('reset');
    end
    close all
end
 
