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

%% LOAD DATA
%==========================================================================
% Load data 
[xlsdata, xlstext] = xlsread('GK2015_Data.xlsx','Sheet1');
dates = xlstext(3:end,1);
vnames_long = xlstext(1,2:end);
vnames = xlstext(2,2:end);
nvar = length(vnames);
data   = Num2NaN(xlsdata);
% Store variables in the structure DATA
for ii=1:length(vnames)
    DATA.(vnames{ii}) = data(:,ii);
end
% Convert the first date to numeric
year = str2double(xlstext{3,1}(1:4));
quarter = str2double(xlstext{3,1}(6));
% Observations
nobs = size(data,1);


%% VAR ESTIMATION
%==========================================================================
% Set endogenous
VARvnames_long = {'1yr rate';'CPI';'IP';'EBP';};
VARvnames      = {'gs1';'logcpi';'logip';'ebp';};
VARnvar        = length(VARvnames);

% Set IV
IVvnames_long = {'FF4';};
IVvnames      = {'ff4_tc'};
IVnvar        = length(IVvnames);

% VAR specification
VARnlags = 12; VARconst = 1;

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
VARopt.ident='short'; 
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
SaveFigure('GK_Replication',1);


















