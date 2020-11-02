% Replication of the bivariate VAR in Blanchard and Quah (1989, AER).
% Figure 2, pag. 662
%
% The VAR Toolbox 2.0 is required to run this code. To get the 
% latest version of the toolboxes visit: 
% 
%       https://sites.google.com/site/ambropo/MatlabCodes
% 
% =======================================================================
% Ambrogio Cesa Bianchi, March 2017
% ambrogio.cesabianchi@gmail.com


%% PRELIMINARIES
% =======================================================================
clear all; clear session; close all; clc
warning off all

% Load data
[xlsdata, xlstext] = xlsread('BQ1989_Data.xls','Sheet1');
% Define and transform (if needed)
X = xlsdata;
vnames = xlstext(1,2:end);


%% VAR ESTIMATION
% =======================================================================
% Define number of variables and of observations
[nobs, nvar] = size(X);
% Set deterministics for the VAR
det = 1;
% Set number of nlags
nlags = 8;
% Estimate VAR
[VAR, VARopt] = VARmodel(X,nlags,det);


%% COMPUTE IRF AND FEVD
% =======================================================================
% Set options some options for IRF calculation
VARopt.nsteps = 40;
VARopt.ident = 'bq';
VARopt.vnames = vnames;
% Compute IRF
[IRF, VAR] = VARir(VAR,VARopt);
% Compute error bands
[IRFINF,IRFSUP,IRFMED] = VARirband(VAR,VARopt);
% Plot
VARirplot(IRFMED,VARopt,IRFINF,IRFSUP);

% Compute FEVD
[FEVD, VAR] = VARfevd(VAR,VARopt);
% Compute error bands
[FEVDINF,FEVDSUP,FEVDMED] = VARfevdband(VAR,VARopt);
% Plot
VARfevdplot(FEVDMED,VARopt,FEVDINF,FEVDSUP);



%% GET FIGURE 1 AS IN BLANCHARD AND QUAH
% =======================================================================
% Note that, when using Blanchard Quah identification, the code VARir 
% assumes that u2 has no effect on y1, that is shock 2 is the demand shock

% In their paper BQ assumes that u1 has no effect on y1. Therefore our 
% responses for shock 2 are flipped

subplot(1,2,1)
plot(cumsum(IRF(:,1,1)),'LineWidth',2)
hold on
plot(IRF(:,2,1),'--r','LineWidth',2)
hold on
plot(zeros(VARopt.nsteps),'-k')
title('Supply shock')
legend({'GDP Level';'Unemployment'})

subplot(1,2,2)
plot(cumsum(-IRF(:,1,2)),'LineWidth',2)
hold on
plot(-IRF(:,2,2),'--r','LineWidth',2)
hold on
plot(zeros(VARopt.nsteps),'-k')
title('Demand shock')
legend({'GDP Level';'Unemployment'})
print('-dpdf','-r100','Figure1');

close all