function VARirplot(IRF,pick,vnames,filename,INF,SUP,PanelTitle,FontSize)
% =======================================================================
% Plot the IRFs computed with VARir
% =======================================================================
% VARirplot(IRF,pick,vnames,filename,INF,SUP)
% -----------------------------------------------------------------------
% INPUT
%   IRF(:,:,:) : matrix with periods, variable, shock
%
% OPTIONAL INPUT
%   pick     : a scalar for the position of selected shock [default 0 = all]. 
%              The routine will plot responses of all variables to chosen
%              shocks
%   vnames   : name of the variables ordered as in the VAR
%   filename : name for file saving
%   INF      : lower error band
%   SUP      : upper error band
%   PanelTitle: write a title on top of each chart if set to 1 (default = 0)
%   FontSize : set the size of the font in the chart (default = 14)
% =======================================================================
% Ambrogio Cesa Bianchi, May 2012
% ambrogio.cesabianchi@gmail.com


%% Check optional inputs & Define some parameters
%================================================
if ~exist('filename','var') 
    filename = 'IRF_';
end

if ~exist('FontSize','var') 
    FontSize = 14;
end

if ~exist('PanelTitle','var') 
    PanelTitle = 0;
end

% Initialize IRF matrix
[nsteps, nvars, nshocks] = size(IRF);

% If one shock is chosen, set the right value for nshocks
if ~exist('pick','var') 
    pick = 1;
else
    if pick<0 || pick>nvars
        error('The selected shock is non valid')
    else
        if pick==0
            pick=1;
        else
            nshocks = pick;
        end
    end
end

% Define the rows and columns for the subplots
row = round(sqrt(nvars));
col = ceil(sqrt(nvars));

% Define a timeline
steps = 1:1:nsteps;
x_axis = zeros(1,nsteps);


%% Plot
%=========
FigSize(8*col,8*col*.5)
for jj=pick:nshocks                
    for ii=1:nvars
        subplot(row,col,ii);
        plot(steps,IRF(:,ii,jj),'LineStyle','-','Color',rgb('dark blue'),'LineWidth',2);
        hold on
        plot(x_axis,'k','LineWidth',0.5)
        if exist('INF','var') && exist('SUP','var')
            plot(steps,INF(:,ii,jj),'LineStyle',':','Color',rgb('light blue'),'LineWidth',1.5);
            hold on
            plot(steps,SUP(:,ii,jj),'LineStyle',':','Color',rgb('light blue'),'LineWidth',1.5);
        end
        xlim([1 nsteps]);
        if exist('vnames','var') 
            title([vnames{ii} ' to ' vnames{jj}], 'FontWeight','bold','FontSize',10); 
        end
%         xlabel('Place your label here');
%         ylabel('Place your label here');
        FigFont(FontSize);
    end
    if PanelTitle==1
        Alphabet = char('a'+(1:nshocks)-1);
        SupTitle([Alphabet(jj) ') IRF to a shock to '  vnames{jj}])
    end
    % Save
    set(gcf, 'Color', 'w');
    FigName = [filename num2str(jj)];
    export_fig(FigName,'-pdf','-png','-painters')
    clf('reset');
end

close all
