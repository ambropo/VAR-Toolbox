function VARvdplot(VD,VARopt)
% =======================================================================
% Plot the VDs computed with VARvd
% =======================================================================
% VARvdplot(VD,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - VD(:,:,:): matrix with 't' steps, the VD due to 'j' shock for 
%       'k' variable
%	- VARopt: options of the VDs (see VARoption)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - INF: lower error band
%   - SUP: upper error band
% -----------------------------------------------------------------------
% EXAMPLE
%   - See VARToolbox_Code.m in "../Primer/"
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% Check inputs
%==========================================================================
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end
% If there is VARopt check that vnames is not empty
vnames = VARopt.vnames;
if isempty(vnames)
    error('You need to add label for endogenous variables in VARopt');
end


%% Retrieve and initialize variables 
%==========================================================================
filename = [VARopt.figname 'VD'];
quality = VARopt.quality;
suptitle = VARopt.suptitle;
pick = VARopt.pick;

% Initialize VD matrix
[nsteps, nvars, nshocks] = size(VD);

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
%==========================================================================
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
        Alphabet = char('a'+(1:nshocks)-1);
        SupTitle([Alphabet(ii) ') VD of '  vnames{ii}])
    end
    opt = LegOption; opt.handle = H(1,:);
    LegSubplot(vnames,opt);
    set(gcf, 'Color', 'w');
    export_fig(FigName,'-pdf','-painters')
else
    legend(H(1,:),vnames)
    print('-dpdf','-r100',FigName);
end

close all
