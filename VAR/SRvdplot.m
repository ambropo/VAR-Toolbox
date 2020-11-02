function SRvdplot(VD,VARopt)
% =======================================================================
% Plot the VDs computed with SR (sign restriction procedure)
% =======================================================================
% SRfevdplot(VD,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - VD(:,:,:): matrix with 't' steps, the VD due to 'j' shock for 
%       'k' variable
%   - VARopt: options of the VAR (from VARmodel and SR)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - INF: lower error band
%   - SUP: upper error band
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa Bianchi, March 2020
% ambrogio.cesabianchi@gmail.com
% -----------------------------------------------------------------------


%% Check inputs
%===============================================
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end
% If there is VARopt check that vnames and snames are not empty
vnames = VARopt.vnames;
snames = VARopt.snames;
if isempty(vnames)
    error('You need to add label for endogenous variables in VARopt');
end
if isempty(snames)
    error('You need to add label for shocks in VARopt');
end


%% Define some parameters
%===============================================
filename = [VARopt.figname 'VD'];
quality = VARopt.quality;
suptitle = VARopt.suptitle;
pick = VARopt.pick;

% Initialize VD matrix
nshocks = length(snames); [nsteps, nvars, ~] = size(VD);

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
%=========
% Area plot
FigSize(VARopt.FigSize(1),VARopt.FigSize(2))
for ii=1:nvars
    subplot(row,col,ii);
    H = AreaPlot(VD(:,:,ii));
    xlim([1 nsteps]); ylim([0 100]);
    title(vnames{ii}, 'FontWeight','bold','FontSize',10); 
    set(gca, 'Layer', 'top');
end
% Save
FigName = [filename];
if quality 
    if suptitle==1
        SupTitle('Variance Decomposition')
    end
    opt = LegOption; opt.handle = [H(1,:)];
    LegSubplot(snames,opt);
    set(gcf, 'Color', 'w');
    export_fig(FigName,'-pdf','-painters')
else
    legend(H(1,:),snames)
    print('-dpdf','-r100',FigName);
end

close all
