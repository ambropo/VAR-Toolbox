function VARfevdplot(FEVD,VARopt,INF,SUP)
% =======================================================================
% Plot the FEVDs computed with VARfevd
% =======================================================================
% VARfevdplot(FEVD,VARopt,vnames,INF,SUP)
% -----------------------------------------------------------------------
% INPUT
%   - FEVD(:,:,:): matrix with 't' steps, the FEVD due to 'j' shock for 
%       'k' variable
%	- VARopt: options of the FEVDs (see VARoption)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - INF: lower error band
%   - SUP: upper error band
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% Check inputs
%================================================
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end
% If there is VARopt check that vnames is not empty
vnames = VARopt.vnames;
if isempty(vnames)
    error('You need to add label for endogenous variables in VARopt');
end


%% Retrieve and initialize variables 
%================================================
filename = [VARopt.figname 'FEVD_'];
quality = VARopt.quality;
suptitle = VARopt.suptitle;
pick = VARopt.pick;

% Initialize FEVD matrix
[nsteps, nvars, nshocks] = size(FEVD);

% If one variable is chosen, set the right value for nvars
if pick<0 || pick>nvars
    error('The selected variable is non valid')
else
    if pick==0
        pick=1;
    else
        nvars = pick;
    end
end

% Define the rows and columns for the subplots
row = round(sqrt(nshocks));
col = ceil(sqrt(nshocks));

% Define a timeline
steps = 1:1:nsteps;
x_axis = zeros(1,nsteps);



%% Plot
%================================================
FigSize
for ii=pick:nvars
    for jj=1:nshocks
        subplot(row,col,jj);
        plot(steps,FEVD(:,jj,ii),'LineStyle','-','Color',[0.01 0.09 0.44],'LineWidth',2);
        hold on
        plot(x_axis,'k','LineWidth',0.5)
        if exist('INF','var') && exist('SUP','var')
            plot(steps,INF(:,jj,ii),'LineStyle',':','Color',[0.39 0.58 0.93],'LineWidth',1.5);
            hold on
            plot(steps,SUP(:,jj,ii),'LineStyle',':','Color',[0.39 0.58 0.93],'LineWidth',1.5);
        end
        xlim([1 nsteps]); ylim([0 1]);
        title([vnames{ii} ' to ' vnames{jj}], 'FontWeight','bold','FontSize',10); 
    end
    % Save
    FigName = [filename num2str(ii)];
    if quality 
        if suptitle==1
            Alphabet = char('a'+(1:nvars)-1);
            SupTitle([Alphabet(ii) ') FEVD of '  vnames{ii}])
        end
        set(gcf, 'Color', 'w');
        export_fig(FigName,'-pdf','-png','-painters')
    else
        print('-dpng','-r100',FigName);
        print('-dpdf','-r100',FigName);
    end
    clf('reset');
end

close all
