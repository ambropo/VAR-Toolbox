function H = PlotSwathe(bar,swathe,SwatheOpt)
% =======================================================================
% Plot a line with a shaded swathe (e.g for impulse responses, etc)
% =======================================================================
% H = PlotSwathe(bar,swathe,SwatheOpt)
% -----------------------------------------------------------------------
% INPUT
%   - bar: line to plot
%   - swathe: if a vector, draws symmetric swathe around bar. Otherwise 
%       draws asymmetric swathe, with first columnn being the upper limit 
%       and second column being the lower limit
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - SwatheOpt.linecol: color of line, can be rgb number or string, e.g. 
%       'blue'
%   - SwatheOpt.swathecol: color of swathe (can be rgb number or string, 
%       e.g 'blue')
%   - SwatheOpt.transp: 1 for transparency (dflt=0)
%   - nticks: number ticks on the horizontal axis
%   - fo: first observation (convention: 1987.00 = 1987Q1)
%   - SwatheOpt.frequency: quarterly ('q') or annual ('y') [dflt='q']
%   - SwatheOpt.swatheonly: set to 1 to plot only the swathe (dflt=0)
% -----------------------------------------------------------------------
% OUPUT
%   - H.bar: handle for the median
%   - H.patch: handle for the patch
%   - H.swathe: H.swathe(1) handle for upp , H.swathe(2) handle for low
%   - H.ax: hande for the axis
%   - H.nobs: number of observations
% -----------------------------------------------------------------------
% EXAMPLE
% x = 3*(1:50);
% swathe = [1*(1:50);4*(1:50)];
% PlotSwathe(x,swathe)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------


if ~exist('SwatheOpt','var')
    SwatheOpt = PlotSwatheOption;
end

% Get the color of line 
if isnumeric(SwatheOpt.linecol) % in case user provides already the rgb code
    linecol = SwatheOpt.linecol;
else % otherwise use rgb to get the code
    linecol = rgb(SwatheOpt.linecol);
end

% Get the color of swathe
if isnumeric(SwatheOpt.swathecol) % in case user provides already the rgb code
    swathecol = SwatheOpt.swathecol;
else % otherwise use rgb to get the code
    swathecol = rgb(SwatheOpt.swathecol);
end

% Number of observations
nobs = length(bar); H.nobs = nobs;

% Make sure data is row-vector
if size(bar,1)>1
    bar =bar';
end

% Check if swathe is vector and set error bands

if isvector(swathe)
    % Check if swathe has the right dimension [1 x T]
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

%% PLOT
% Initialize patch 
edgeColor = swathecol+(1-swathecol)*0.55;
% Set saturation
swathealpha = SwatheOpt.alpha; 
% SwatheOpt.transp to make the patch
if SwatheOpt.transp==1
    faceAlpha = swathealpha;
    patchColor = swathecol;
    set(gcf,'renderer','openGL')
else
    faceAlpha = 1;
    patchColor = swathecol+(1-swathecol)*(1-swathealpha);
    set(gcf,'renderer','painters')
end

% Plot the 'bar' line
if SwatheOpt.swatheonly==0
    H.bar = plot(xaxis,bar,'LineWidth',SwatheOpt.linewidth,'Color',linecol,'Marker',SwatheOpt.marker);
end

% Add the error-bar plot elements
holdStatus = ishold;
if ~holdStatus, hold on,  end

% Make the coordinates for the patch
yP = [low,fliplr(upp)];
xP = [xaxis,fliplr(xaxis)];

% Remove any nans otherwise patch won't work
xP(isnan(yP))=[];
yP(isnan(yP))=[];
H.patch=patch(xP,yP,1,'facecolor',patchColor,'edgecolor','none','facealpha',faceAlpha);

% Make nice edges around the patch. 
H.swathe(1)=plot(xaxis,low,'-','Color',edgeColor);
H.swathe(2)=plot(xaxis,upp,'-','Color',edgeColor);
if SwatheOpt.swatheonly==0
    delete(H.bar)
end
if SwatheOpt.swatheonly==0
    H.bar=plot(xaxis,bar,'LineWidth',SwatheOpt.linewidth,'Color',linecol,'Marker',SwatheOpt.marker);
end
if ~holdStatus, hold off, end

% Make smart x labels
if SwatheOpt.do_dates==1
    DatesPlot(fo,nobs,nticks,SwatheOpt.frequency)
end
H.ax = gca;
