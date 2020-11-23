function SRhdplot(HD,VARopt)
% =======================================================================
% Plot the HD shocks computed with SR (sign restriction procedure)
% =======================================================================
% SRhdplot(HD,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - HD: structure from SR
%   - VARopt: options of the VAR (from VARmodel and SR)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% Check inputs
%================================================
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


%% Check inputs Define some parameters
%===============================================
filename = [VARopt.figname 'HD_SR_'];
quality = VARopt.quality;
suptitle = VARopt.suptitle;
pick = VARopt.pick;

% Initialize HD matrix
nshocks = length(snames); [nsteps, nvars, ~] = size(HD);

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
%================================================
FigSize
for ii=pick:nvars                
    colormap(parula)
    BarPlot(HD(:,1:nshocks,ii));
    xlim([1 nsteps]);
    title([vnames{ii}], 'FontWeight','bold','FontSize',10); 
    % Save
    FigName = [filename num2str(ii)];
    if quality 
        if suptitle==1
            Alphabet = char('a'+(1:nvars)-1);
            SupTitle([Alphabet(jj) ') HD of '  vnames{ii}])
        end
        opt = LegOption; LegSubplot(vnames,opt);
        set(gcf, 'Color', 'w');
        export_fig(FigName,'-pdf','-png','-painters')
    else
        legend(snames)
        print('-dpng','-r100',FigName);
        print('-dpdf','-r100',FigName);
    end
    clf('reset');
end

close all
