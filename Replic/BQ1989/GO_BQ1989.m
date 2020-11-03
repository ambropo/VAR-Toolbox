% Replication of the bivariate VAR in Blanchard and Quah (1989, AER).
% Figure 2, pag. 662
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
VARopt.FigSize = [26,12];

% Compute IR
[IR, VAR] = VARir(VAR,VARopt);
% Compute error bands
[IRinf,IRsup,IRmed,IRbar] = VARirband(VAR,VARopt);
% Plot
VARirplot(IRbar,VARopt,IRinf,IRsup);

% Compute VD
[VD, VAR] = VARvd(VAR,VARopt);
% Compute error bands
[VDinf,VDsup,VDmed,VDbar] = VARvdband(VAR,VARopt);
% Plot
VARvdplot(VDbar,VARopt);


%% REPLICATE FIGURE 1 OF BLANCHARD AND QUAH
% =======================================================================
% Note that, when using Blanchard Quah identification, the code VARir 
% assumes that u2 has no effect on y1, that is shock 2 is the demand shock

% Differently, Blanchard Quah assume that u1 has no effect on y1. 
% Therefore our responses for shock 2 are flipped

FigSize(26,12)

subplot(1,2,1)
plot(cumsum(IR(:,1,1)),'LineWidth',2.5,'Color',cmap(1))
hold on
plot(IR(:,2,1),'LineWidth',2.5,'Color',cmap(2))
hold on
plot(zeros(VARopt.nsteps),'--k')
title('Supply shock')
legend({'GDP Level';'Unemployment'})

subplot(1,2,2)
plot(cumsum(-IR(:,1,2)),'LineWidth',2.5,'Color',cmap(1))
hold on
plot(-IR(:,2,2),'LineWidth',2.5,'Color',cmap(2))
hold on
plot(zeros(VARopt.nsteps),'-k')
title('Demand shock')
legend({'GDP Level';'Unemployment'})

SaveFigure('Figure1');
