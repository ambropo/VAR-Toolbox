function H = PlotSwathe(bar,swathe,col,nticks,Y,Q,datelabel,transp)
% =========================================================================
% Plot a line with a shaded swathe
% =========================================================================
% H = PlotSwathe(bar,swathe,col,nticks,transp,Y,Q,datelabel)
% -------------------------------------------------------------------------
% INPUT
%   - bar   : line to plot
%   - swathe: if a vector, draws symmetric errorbars. If it has a size of 
%             [2 x T] draws asymmetric error bars with row 1 being the 
%             upper bar and row 2 being the lower bar
%
% OPTIONAL INPUT
%   - col      : color of the line/patch, can be rgb number (e.g. [1 0 0 ]
%                or string (e.g. 'blue')
%   - nticks   : number of ticks for smart label
%   - Y        : year of the first observation
%   - Q        : quarter of the first observation
%   - datelabel: 'short' for 99, 'long' for 1999. Default is 'long'
%   - transp   : 'transparent' for transparency, [empty] otherwise. Default
%                is [empty]
%--------------------------------------------------------------------------
% OUPUT
%   - H.bar    : handle for the median
%   - H.patch  : handle for the patch
%   - H.swathe : H.swathe(1) handle for upp , H.swathe(2) handle for low
%   - H.ax     : hande for the axis
%   - H.nobs   : number of observations
% =========================================================================
% EXAMPLE
% year = 1980;
% quarter = 1;
% x = 3*sin(1:50);
% PlotSwathe(x,1,'dark blue',6,1970,1,'long','transparent');
% hold on
% y = cos(1:50);
% PlotSwathe(y,1,'light red',6,1970,1,'long','transparent');
% =========================================================================
% Ambrogio Cesa Bianchi, August 2013
% ambrogio.cesabianchi@gmail.com



%% INITIALIZE VARIABLES
if ~exist('col','var')
    colrgb = rgb('dark grey');
else
    if isnumeric(col) % in case user provides already the rgb code
        colrgb = col;
    else % otherwise use rgb to get the code
        colrgb = rgb(col);
    end
end

if ~exist('nticks','var')
    nticks = 5;
end

if ~exist('transp','var')
    transp = '';
end

if ~exist('datelabel','var')
    datelabel = 'long';
end

% Number of observations
nobs = length(bar); H.nobs = nobs;

% Make sure data is row-vector
if size(bar,1)>1
    bar =bar';
end

% Check if swathe is vector and set error bands
if isvector(swathe)
    % Check if i has the right dimension [1 x T]
    if size(swathe,1)>1
        swathe = swathe';
        low = bar - swathe;
        upp = bar + swathe;
    else
        low = bar - swathe;
        upp = bar + swathe;
    end
else
    % Check if i has the right dimension [2 x T]
    if size(swathe,1)>2
        swathe = swathe';
        upp = swathe(1,:);
        low = swathe(2,:);
    else
        upp = swathe(1,:);
        low = swathe(2,:);
    end
end
    
% Create the x axis
xaxis = 1:nobs;

%% SET THE SMART LABELS
% Determine number of observations per tick 
nobsXtick  = ceil(nobs/nticks);
check = 0; 
while check ==0 % this is to make nobsXtick a multiple of 4
    aux = nobsXtick/4;
    if aux ~= floor(aux)
        nobsXtick = nobsXtick+1;
    else
        check =1;
    end
end

% Determine the number of observation for the label
nobs_label  = nticks*nobsXtick;

% If a starting date is provided, compute dates vector
if ~exist('Y','var')
    do_dates = 0;
else
    if ~exist('Q','var')
        error('You have to provide a starting value for the Q');
    else
        do_dates = 1;
        [~, dates] = MakeDate(Y,1,nobs_label+4);
        if strcmp(datelabel,'short')  
            for ii=1:length(dates)
                aux = dates{ii,1};
                dates(ii,1) = {aux(3:4)};
            end
        end
    end
end



%% PLOT
% Initialize patch 
edgeColor = colrgb+(1-colrgb)*0.55;
patchSaturation = 0.15; %How de-saturated or transp to make the patch
if strcmp(transp,'transparent')==1
    faceAlpha = patchSaturation;
    patchColor = colrgb;
    set(gcf,'renderer','openGL')
else
    faceAlpha = 1;
    patchColor = colrgb+(1-colrgb)*(1-patchSaturation);
    set(gcf,'renderer','painters')
end

% Plot the median
H.bar = plot(xaxis,bar,'LineWidth',2,'Color',colrgb);

%Add the error-bar plot elements
holdStatus = ishold;
if ~holdStatus, hold on,  end

% Make the cordinats for the patch
yP = [low,fliplr(upp)];
xP = [xaxis,fliplr(xaxis)];

% Remove any nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];
H.patch=patch(xP,yP,1,'facecolor',patchColor,'edgecolor','none','facealpha',faceAlpha);

%Make nice edges around the patch. 
H.swathe(1)=plot(xaxis,low,'-','color',edgeColor);
H.swathe(2)=plot(xaxis,upp,'-','color',edgeColor);
delete(H.bar)
H.bar=plot(xaxis,bar,'LineWidth',2,'Color',colrgb);
if ~holdStatus, hold off, end

% Make smart x labels
if do_dates==1
    set(gca,'xLim',[-Q+1 -Q+1+nobs_label])
    set(gca,'xTick',-Q+1:nobsXtick:-Q+1+nobs_label)
    set(gca,'xTickLabel',dates(1:nobsXtick:nobs_label+1))
end
set(gca,'xLim',[0 nobs+1])
H.ax = gca;
