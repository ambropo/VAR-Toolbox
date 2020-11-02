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

spec = 'GK'; % CHOL/GK/SR
row = 2; col = 2;

%% LOAD DATA
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
VARnlags = 12; VARdet = 1; ident='oir'; VARtol=.9975; NOBStol=30; nsteps =48; ndraws = 200;
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

% Estimate VAR

%% IV
%==========================================================================
[IV_VAR, IV_VARopt] = VARmodel(ENDO,VARnlags,VARdet);
IV_VARopt.nsteps = nsteps;
IV_VARopt.ndraws = ndraws;
IV_VARopt.method = 'wild';
IV_VARopt.quality = 1;
[IV_IRF, IVout] = VARiriv(IV_VAR,IV_VARopt,IV);
[IV_INF,IV_SUP,IV_BAR] = VARirbandiv(IV_VAR,IV_VARopt,IV);

%% CHOLESKY
%==========================================================================
[CHOL_VAR, CHOL_VARopt] = VARmodel(ENDO,VARnlags,VARdet);
CHOL_VARopt.nsteps = nsteps;
CHOL_VARopt.ndraws = ndraws;
CHOL_VARopt.quality = 1;
[CHOL_IRF, CHOL_VAR] = VARir(CHOL_VAR,CHOL_VARopt);
[CHOL_INF,CHOL_SUP,CHOL_MED,CHOL_BAR] = VARirband(CHOL_VAR,CHOL_VARopt);
CHOL_INF = CHOL_INF(:,:,1); CHOL_SUP = CHOL_SUP(:,:,1); CHOL_MED = CHOL_MED(:,:,1); CHOL_BAR = CHOL_BAR(:,:,1);

%% LP (error bands do not work)
%==========================================================================
% Prefilter
for ii=1:VARnvar
    out = OLSmodel(ENDO(:,ii),[],VARdet);
    LPdata(:,ii) = out.resid;
end 
deltai=double(ismember(VARvnames,VARvnames(1))); %finds position of shock name
nw=VARnlags+nsteps; 
out=LPir(LPdata,VARnlags,nsteps-1,nw,deltai,0);
LP_BAR = out.irfs;

%% SR 
%==========================================================================
[SR_VAR, SR_VARopt] = VARmodel(ENDO,VARnlags,VARdet);
R(:,:,1) = [ 1     1     1    % Fed Fund
             1     1    -1    % CPI
             1     1    -1    % IP
             1     1     1];  % EBP

% Set options for IRs and SR
SR_VARopt.nsteps = nsteps;
SR_VARopt.ndraws = ndraws;
SR_VARopt.pctg = 68;
SR_VARopt.snames = {'MonPol Shock'};
SR_VARopt.vnames = VARvnames;
SR_VARopt.quality = 1;
SRout = SR(SR_VAR,R,SR_VARopt);
SR_INF = SRout.IRinf(:,:,1); SR_SUP = SRout.IRsup(:,:,1); SR_MED = SRout.IRmed(:,:,1);

%% Plot
FigSize
for ii=1:VARnvar
    subplot(row,col,ii)
    % IV
    IV_rescale = 0.25/IV_BAR(1,1);
    PlotSwathe(IV_rescale.*IV_BAR(:,ii),[IV_rescale.*IV_INF(:,ii) IV_rescale.*IV_SUP(:,ii)],cmap(1),'transparent'); hold on
    % CHOL
    CHOL_rescale = 0.25/CHOL_BAR(1,1);
    plot(CHOL_rescale.*CHOL_BAR(:,ii),'-r','LineWidth',1); hold on; 
    plot(CHOL_rescale.*CHOL_INF(:,ii),'-.r','LineWidth',1); hold on; 
    plot(CHOL_rescale.*CHOL_SUP(:,ii),'-.r','LineWidth',1); hold on; 
    % SR
    SR_rescale = 0.25/SR_MED(1,1);
    PlotSwathe(SR_rescale.*SR_MED(:,ii),[SR_rescale.*SR_INF(:,ii) SR_rescale.*SR_SUP(:,ii)],rgb('dark grey'),'transparent'); hold on
    % LP
    % LP_rescale = 0.25/LP_BAR(1,1);
    % plot(LP_rescale.*LP_BAR(:,ii),'-y','LineWidth',2); hold on; 
    % OTHER
    plot(zeros(nsteps,1),'-k','LineWidth',0.5)
    title(VARvnames_long{ii},'FontWeight','bold')
    set(gca,'Layer','top'); axis tight
end
SaveFigure('MPshock',1)










