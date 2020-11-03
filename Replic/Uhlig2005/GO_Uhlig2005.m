% Replication of the monetary VAR in Uhligh (2005, JME).
% Figure 6, page 397.
%==========================================================================
% The VAR Toolbox 3.0 is required to run this code. To get the 
% latest version of the toolboxes visit: 
% https://github.com/ambropo/VAR-Toolbox
%==========================================================================
% Ambrogio Cesa Bianchi, November 2020
% ambrogio.cesabianchi@gmail.com


%% PRELIMINARIES
% =======================================================================
clear all; clear session; close all; clc
warning off all

% Load data
[xlsdata, xlstext] = xlsread('Uhlig2005_Data.xls','Sheet1');

% Define and transform (if needed)
dates = xlstext(2:end,1);
vnames = xlstext(1,2:end);
X(:,1:3) = log(xlsdata(:,1:3))*100;
X(:,4)   = xlsdata(:,4);
X(:,5:6) = log(xlsdata(:,5:6))*100;
VARnvar = size(X,2);

%% VAR ESTIMATION
% =======================================================================
% Define number of variables and of observations
[nobs, nvar] = size(X);
% Set deterministics for the VAR
det = 0;
% Set number of nlags
nlags = 12;
% Estimate VAR
[VAR, VARopt] = VARmodel(X,nlags,det);


%% SIGN RESTRICTIONS
% =======================================================================
% Set options for IRFs and SR
VARopt.nsteps = 60;
VARopt.ndraws = 500;
VARopt.snames = {'MonPol Shock'};
VARopt.vnames = vnames;


% Define sign restrictions : positive 1, negative -1, unrestricted 0
SIGN = [ 0,0,0,0,0,0;  % Real GDP
        -1,0,0,0,0,0;  % CPI
        -1,0,0,0,0,0;  % Commodity Price
         1,0,0,0,0,0;  % Fed Fund
        -1,0,0,0,0,0;  % NonBorr. Reserves
         0,0,0,0,0,0]; % Total Reserves
     

% Define the number of steps the restrictions are imposed for:
VARopt.sr_hor = 6;
VARopt.sr_mod = 0;

% Set options the credible intervals
VARopt.pctg = 68;


% Run sign restrictions routine
SRout = SR(VAR,SIGN,VARopt);

% Plot
for ii=1:VARnvar
    subplot(2,3,ii)
    plot(SRout.IRmed(:,ii,1),'-k','LineWidth',2); hold on; 
    plot(SRout.IRinf(:,ii,1),'--k','LineWidth',1); hold on; 
    plot(SRout.IRsup(:,ii,1),'--k','LineWidth',1); hold on; 
    plot(zeros(VARopt.nsteps),'-k')
    title(vnames{ii},'FontWeight','bold')
    axis tight
end