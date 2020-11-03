% Replication of the VAR in Gerlter and Karadi (2015, AEJ:M).
% Figure 1, pag. 61
%==========================================================================
% The VAR Toolbox 3.0 is required to run this code. To get the 
% latest version of the toolboxes visit: 
% https://github.com/ambropo/VAR-Toolbox
%==========================================================================
% Ambrogio Cesa Bianchi, November 2020
% ambrogio.cesabianchi@gmail.com


%% PRELIMINARIES
%==========================================================================
clear all; clear session; close all; clc
warning off all

% Set endogenous
VARvnames_long = {'1yr rate';'CPI';'IP';'EBP';};
VARvnames      = {'gs1';'logcpi';'logip';'ebp';};
VARnvar        = length(VARvnames);

% Set IV
IVvnames_long = {'FF4';};
IVvnames      = {'ff4_tc'};
IVnvar        = length(IVvnames);


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

[xlsdata, xlstext] = xlsread('GK2015_Data.xlsx','IV_data');
dataIV   = Num2NaN(xlsdata(:,3:end));
vnamesIV = xlstext(1,3:end);
for ii=1:length(vnamesIV)
    DATA.(vnamesIV{ii}) = dataIV(:,ii);
end

% Observations
nobs = size(data,1);


%% VAR ESTIMATION
%==========================================================================
% VAR specification
VARnlags = 12; VARconst = 1; ident='oir'; VARtol=.9975; NOBStol=30;

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
[VAR, VARopt] = VARmodel(ENDO,VARnlags,VARconst);
VAR.IV = IV;

%% CHOLESKY IDENTIFICATION
%==========================================================================
disp('Estimate Cholesky IRFs and error bands')
VARopt.method = 'wild';
VARopt.nsteps = 48;
VARopt.ndraws = 200;
[IR, VAR] = VARir(VAR,VARopt);
[INF,SUP,MED,BAR] = VARirband(VAR,VARopt);

% Plot
FigSize(20,20)
idx = 1;
for ii=1:VARnvar
    subplot(4,2,idx)
    plot(BAR(:,ii),'-r','LineWidth',2); hold on; 
    plot(INF(:,ii),'--r','LineWidth',1); hold on; 
    plot(SUP(:,ii),'--r','LineWidth',1); hold on; 
    plot(zeros(VARopt.nsteps),'-k')
    title(VARvnames_long{ii},'FontWeight','bold')
    axis tight
    idx = idx + 2;
end
legend('Cholesky')


%% IV IDENTIFICATION
%==========================================================================
disp('Estimate IV IRFs and error bands')
VARopt.ident = 'iv';
VARopt.method = 'wild';
[IRiv, VARiv] = VARir(VAR,VARopt);
[INFiv,SUPiv,MEDiv,BARiv] = VARirband(VAR,VARopt);

% Plot
% Note that the routine VARivir normalizes the size of the shock to 1.
% Therefore, to replicate Figure 1, I premultiply the impulse responses by
% the size of the shock in teh original paper, namely ~0.2
idx = 2;
for ii=1:VARnvar
    subplot(4,2,idx)
    plot(BARiv(:,ii),'-k','LineWidth',2); hold on; 
    plot(INFiv(:,ii),'--k','LineWidth',1); hold on; 
    plot(SUPiv(:,ii),'--k','LineWidth',1); hold on; 
    plot(zeros(VARopt.nsteps),'-k')
    title(VARvnames_long{ii},'FontWeight','bold')
    axis tight
    idx = idx + 2;
end
legend('IV')

%% SAVE
%==========================================================================
SaveFigure('IR',1);


















