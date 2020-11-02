% This code compares the old and new sign restrictions procedures


%% PRELIMINARIES
%==========================================================================
clear all; clear session; close all; clc
warning off all

% Set endogenous
VARvnames_long = {'Policy rate';'CPI';'Industrial Production';'EBP'};
VARvnames      = {'gs1';'logcpi';'logip';'ebp'};
VARnvar        = length(VARvnames);

% Set IV
IVvnames_long = {'ff4_tc';};
IVvnames      = {'ff4_tc'};
IVnvar        = length(IVvnames);

% Rows and columns for charts
row = 2; col = 2;

%% LOAD GK DATA
%==========================================================================
% Load 
[xlsdata, xlstext] = xlsread('GK2015_Data.xlsx','VAR_data');
data   = Num2NaN(xlsdata(:,3:end));
vnames = xlstext(1,3:end);
for ii=1:length(vnames)
    DATA.(vnames{ii}) = data(:,ii);
end
year = xlsdata(1,1);
month = xlsdata(1,2);

% Observations
nobs = size(data,1);


%% VAR ESTIMATION
%==========================================================================
% VAR specification
VARnlags = 12; VARdet = 1; ident='oir'; VARtol=.9975; NOBStol=30; nsteps =48;
% Create matrices of variables for the VAR
ENDO = nan(nobs,VARnvar);
for ii=1:VARnvar
    ENDO(:,ii) = DATA.(VARvnames{ii});
end

% Create matrices of variables for the instrument
IV = nan(nobs,IVnvar);
for ii=1:IVnvar
    IV(:,ii) = DATA.(IVvnames{ii});
end


%% SR OLD
%==========================================================================
[SR_VAR, SR_VARopt] = VARmodel(ENDO,VARnlags,VARdet);
R(:,:,1) = [ 1     1     1    % Fed Fund
             1     1    -1    % CPI
             1     1    -1    % IP
             1     1     1];  % EBP
R(:,:,2) = [ 1     1     1    % Fed Fund
             1     1     1    % CPI
             1     1     1    % IP
             1     1    -1];  % EBP
R(:,:,3) = [ 1     1     0    % Fed Fund
             1     1    -1    % CPI
             1     1     1    % IP
             1     1     0];  % EBP
         
% % Set options for IRs and SR
% SR_VARopt.nsteps = nsteps;
% SR_VARopt.ndraws = 100;
% SR_VARopt.pctg = 68;
% SR_VARopt.snames = {'MonPol Shock';'Demand';'Supply'};
% SR_VARopt.vnames = VARvnames;
% SR_VARopt.figname = 'OLD'; 
% SR_VARopt.quality = 1;
% SRout = SR_OLD(SR_VAR,R,SR_VARopt);
% Plot
%SRirplot(SRout.IRFmed,SR_VARopt,SRout.IRFinf,SRout.IRFsup)
%SRvdplot(SRout.FEVDmed,SR_VARopt,SRout.FEVDinf,SRout.FEVDsup)
% SRhdplot(SRout.HDmed,SR_VARopt)


%% SR NEW
%==========================================================================
[SRNEW_VAR, SRNEW_VARopt] = VARmodel(ENDO,VARnlags,VARdet);
R =    [ 1     1     0    0    % Fed Fund
        -1     1    -1    0    % CPI
        -1     1     1    0    % IP
         1    -1     0    0];  % EBP
% Set options for IRs and SR
SRNEW_VARopt.nsteps = nsteps;
SRNEW_VARopt.ndraws = 100;
SRNEW_VARopt.pctg = 68;
SRNEW_VARopt.snames = {'MonPol Shock';'Demand';'Supply'};
SRNEW_VARopt.vnames = VARvnames;
SRNEW_VARopt.figname = 'NEW'; 
SRNEW_VARopt.quality = 1;
AGGopt.sr_mod = 1;
SRNEWout = SR(SRNEW_VAR,R,SRNEW_VARopt);
% Plot
%SRirplot(SRNEWout.IRmed,SRNEW_VARopt,SRNEWout.IRinf,SRNEWout.IRsup)
%SRvdplot(SRNEWout.VDmed,SRNEW_VARopt,SRNEWout.VDinf,SRNEWout.VDsup)
%SRhdplot(SRNEWout.HDmed,SRNEW_VARopt)



%% COMPARE using my codes
% MP
SRNEW_BAR = SRNEWout.IRmed(:,:,1);
SRNEW_INF = SRNEWout.IRinf(:,:,1);
SRNEW_SUP = SRNEWout.IRsup(:,:,1);
SR_BAR = SRout.IRFmed(:,:,1);
SR_INF = SRout.IRFinf(:,:,1);
SR_SUP = SRout.IRFsup(:,:,1);
FigSize
for ii=1:VARnvar
    subplot(row,col,ii)
    SRNEW_rescale = 0.25/SRNEW_BAR(1,1);
    PlotSwathe(SRNEW_rescale.*SRNEW_BAR(:,ii),[SRNEW_rescale.*SRNEW_INF(:,ii) SRNEW_rescale.*SRNEW_SUP(:,ii)],rgb('dark blue')); hold on
    % SR
    SR_rescale = 0.25/SR_BAR(1,1);
    plot(SR_rescale.*SR_BAR(:,ii),'-g','LineWidth',2); hold on; 
    plot(SR_rescale.*SR_INF(:,ii),'--g','LineWidth',1); hold on; 
    plot(SR_rescale.*SR_SUP(:,ii),'--g','LineWidth',1); hold on; 
    plot(zeros(nsteps,1),'-k','LineWidth',0.5)
    title(VARvnames_long{ii},'FontWeight','bold')
    set(gca,'Layer','top'); axis tight
end
SaveFigure('1',1)

% DEMAND
SRNEW_BAR = SRNEWout.IRmed(:,:,2);
SRNEW_INF = SRNEWout.IRinf(:,:,2);
SRNEW_SUP = SRNEWout.IRsup(:,:,2);
SR_BAR = SRout.IRFmed(:,:,2);
SR_INF = SRout.IRFinf(:,:,2);
SR_SUP = SRout.IRFsup(:,:,2);
FigSize
for ii=1:VARnvar
    subplot(row,col,ii)
    SRNEW_rescale = 0.25/SRNEW_BAR(1,1);
    PlotSwathe(SRNEW_rescale.*SRNEW_BAR(:,ii),[SRNEW_rescale.*SRNEW_INF(:,ii) SRNEW_rescale.*SRNEW_SUP(:,ii)],rgb('dark blue')); hold on
    % SR
    SR_rescale = 0.25/SR_BAR(1,1);
    plot(SR_rescale.*SR_BAR(:,ii),'-g','LineWidth',2); hold on; 
    plot(SR_rescale.*SR_INF(:,ii),'--g','LineWidth',1); hold on; 
    plot(SR_rescale.*SR_SUP(:,ii),'--g','LineWidth',1); hold on; 
    plot(zeros(nsteps,1),'-k','LineWidth',0.5)
    title(VARvnames_long{ii},'FontWeight','bold')
    set(gca,'Layer','top'); axis tight
end
SaveFigure('2',1)

% SUPPLY
SRNEW_BAR = SRNEWout.IRmed(:,:,3);
SRNEW_INF = SRNEWout.IRinf(:,:,3);
SRNEW_SUP = SRNEWout.IRsup(:,:,3);
SR_BAR = SRout.IRFmed(:,:,3);
SR_INF = SRout.IRFinf(:,:,3);
SR_SUP = SRout.IRFsup(:,:,3);
FigSize
for ii=1:VARnvar
    subplot(row,col,ii)
    SRNEW_rescale = -1/SRNEW_BAR(1,3);
    PlotSwathe(SRNEW_rescale.*SRNEW_BAR(:,ii),[SRNEW_rescale.*SRNEW_INF(:,ii) SRNEW_rescale.*SRNEW_SUP(:,ii)],rgb('dark blue')); hold on
    % SR
    SR_rescale = -1/SR_BAR(1,3);
    plot(SR_rescale.*SR_BAR(:,ii),'-g','LineWidth',2); hold on; 
    plot(SR_rescale.*SR_INF(:,ii),'--g','LineWidth',1); hold on; 
    plot(SR_rescale.*SR_SUP(:,ii),'--g','LineWidth',1); hold on; 
    plot(zeros(nsteps,1),'-k','LineWidth',0.5)
    title(VARvnames_long{ii},'FontWeight','bold')
    set(gca,'Layer','top'); axis tight
end
SaveFigure('3',1)