% Example of the bivariate VAR in Blanchard and Quah (1989, AER).
% Figure 2, pag. 662
%
% The 'Codes' folder includes two subfolders with the Matlab routines to 
% run this code, namely 
%
%  - VAR Toolbox
%  - Figure Toolbox 
% 
% To get the last version of the toolboxes go to: 
% https://sites.google.com/site/ambropo/MatlabCodes
% =======================================================================
% Ambrogio Cesa Bianchi, November 2012
% ambrogio.cesabianchi@gmail.com

% Clean up
clear all; close all; clc;

% Add needed toolboxes
addpath('Codes\VARToolbox')
addpath('Codes\FigureToolbox')
addpath('Codes\FigureToolbox\ExportFig')

% Set font
set(0,'DefaultTextFontName','Palatino')
set(0,'DefaultAxesFontName','Palatino')

% Load data on real gdp and unemployment
[Y, label] = xlsread('BQ1989_Data.xls','Sheet1');
unit=0;

% Labels
labels = {'Real GDP','Unemployment'};

% Estimate the VAR
VARout = VARmodel(Y,8);
VARprint(VARout,labels);
disp(' ')
junk = input('Press enter to continue');

% Compute IRFs and error bands
[IRF, IRF_opt] = VARir(VARout,40,'bq');
[IRFinf, IRFsup, IRFmed] = VARirband(VARout,IRF_opt);
VARirplot(IRFmed,0,labels,'irf',IRFinf,IRFsup)

% Compute FEVDs and error bands
[FEVD, FEVD_opt] = VARfevd(VARout,40,'bq');
[FEVDinf,FEVDsup,FEVDmed] = VARfevdband(VARout,FEVD_opt);
VARfevdplot(FEVDmed,0,labels,'fevd',FEVDinf,FEVDsup)



%% To get Figure 1 as in Blanchard and Quah (1989, AER)
% Notice that, when using Blanchard Quah identification, the code VARir 
% assumes that u2 has no effect on y1, that is shock 2 is the demand shock

% In their paper BQ assumes that u1 has no effect on y1. Therefore our 
% responses for shock 2 are flipped

subplot(1,2,1)
plot(cumsum(IRF(:,1,1)))
hold on
plot(IRF(:,2,1),'--r')
title('Supply shock')
legend({'GDP Level';'Unemployment'})

subplot(1,2,2)
plot(cumsum(-IRF(:,1,2)))
hold on
plot(-IRF(:,2,2),'--r')
title('Demand shock')
legend({'GDP Level';'Unemployment'})
