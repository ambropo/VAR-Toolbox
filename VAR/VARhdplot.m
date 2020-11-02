function VARhdplot(HD,VARopt)
% =======================================================================
% Plot the HD shocks computed with VARhd
% =======================================================================
% VARhdplot(HD,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - HD: structure from VARhd
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2020
% ambrogio.cesabianchi@gmail.com


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


%% Check inputs Define some parameters
%==========================================================================
filename = [VARopt.figname 'HD_'];
quality = VARopt.quality;
suptitle = VARopt.suptitle;
pick = VARopt.pick;

% Initialize HD matrix
[nsteps, nvars, nshocks] = size(HD.shock);

% If one shock is chosen, set the right value for nshocks
if pick<0 || pick>nvars
    error('The selected shock is non valid')
else
    if pick==0
        pick=1;
    else
        nshocks = pick;
    end
end


%% Plot
%==========================================================================
FigSize(VARopt.FigSize(1),VARopt.FigSize(2))
for ii=pick:nvars                
    colormap winter
    H = AreaPlot(squeeze(HD.shock(:,:,ii))); hold on; 
    h = plot(sum(squeeze(HD.shock(:,:,ii)),2),'-k','LineWidth',2);
    if ~isempty(VARopt.firstdate); DatesPlot(VARopt.firstdate,nsteps,8,VARopt.frequency); end
    xlim([1 nsteps]);
	set(gca,'Layer','top');
    title([vnames{ii}], 'FontWeight','bold','FontSize',10); 
    % Save
    FigName = [filename num2str(ii)];
    if quality 
        if suptitle==1
            Alphabet = char('a'+(1:nvars)-1);
            SupTitle([Alphabet(jj) ') HD of '  vnames{ii}])
        end
        opt = LegOption; opt.handle = [H(1,:) h];
        LegSubplot([vnames {'Data'}],opt);
        set(gcf, 'Color', 'w');
        export_fig(FigName,'-pdf','-painters')
    else
        legend([H(1,:) h],[vnames {'Data'}])
        print('-dpdf','-r100',FigName);
    end
    clf('reset');
end

close all