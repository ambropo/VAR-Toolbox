function VARfevdplot(FEVD,pick,vnames,filename,INF,SUP,PanelTitle,FontSize)
% =======================================================================
% Plot the FEVDs computed with VARfevd
% =======================================================================
% VARfevdplot(FEVD,pick,vnames,filename,INF,SUP)
% -----------------------------------------------------------------------
% INPUT
%   FEVD(:,:,:) : matrix with periods, variable, shock
%
% OPTIONAL INPUT
%   pick     : a scalar for the position of selected variable [default 0 = all]. 
%              The routine will plot FEVD of selected variable to all
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


%% Check optional inputs
%=========================
if ~exist('filename','var') 
    filename = 'FEVD_';
end

if ~exist('FontSize','var') 
    FontSize = 14;
end

if ~exist('PanelTitle','var') 
    PanelTitle = 0;
end

% Initialize FEVD matrix
[nsteps, nvars, nshocks] = size(FEVD);

% If one variable is chosen, set the right value for nvars
if ~exist('pick','var') 
    pick = 1;
else
    if pick<0 || pick>nvars
        error('The selected variable is non valid')
    else
        if pick==0
            pick=1;
        else
            nvars = pick;
        end
    end
end


% Define the rows and columns for the subplots
row = round(sqrt(nshocks));
col = ceil(sqrt(nshocks));

% Define a timeline
steps = 1:1:nsteps;
x_axis = zeros(1,nsteps);



%% Plot
%=========
FigSize(8*col,8*col*.5)
for ii=pick:nvars
    for jj=1:nshocks
        subplot(row,col,jj);
        plot(steps,FEVD(:,jj,ii),'LineStyle','-','Color',rgb('dark blue'),'LineWidth',2);
        hold on
        plot(x_axis,'k','LineWidth',0.5)
        if exist('INF','var') && exist('SUP','var')
            plot(steps,INF(:,jj,ii),'LineStyle',':','Color',rgb('light blue'),'LineWidth',1.5);
            hold on
            plot(steps,SUP(:,jj,ii),'LineStyle',':','Color',rgb('light blue'),'LineWidth',1.5);
        end
        xlim([1 nsteps]); ylim([0 1]);
        if exist('vnames','var') 
            title([vnames{ii} ' to ' vnames{jj}], 'FontWeight','bold','FontSize',10); 
        end
%         xlabel('Place your label here');
%         ylabel('Place your label here');
        FigFont(FontSize);
    end
    if PanelTitle==1
        Alphabet = char('a'+(1:nvars)-1);
        SupTitle([Alphabet(ii) ') FEVD of '  vnames{ii}])
    end
    % Save
    set(gcf, 'Color', 'w');
    FigName = [filename num2str(ii)];
    export_fig(FigName,'-pdf','-png','-painters')
    clf('reset');
end

close all
