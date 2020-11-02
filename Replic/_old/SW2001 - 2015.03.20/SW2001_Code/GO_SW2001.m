% Replication of the trivariate VAR in Stock and Watson (2001, JEP) 
% Figure 1 and Table 1.B
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
% Ambrogio Cesa Bianchi, February 2013
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

% Load data
[Y, labels] = xlsread('SW2001_Data.xlsx','Sheet1');
[nobs, nvars] = size(Y);
labels = labels(1,2:end);

% Estimate the VAR
VARout = VARmodel(Y,4);
VARprint(VARout,labels);
disp(' ')
junk = input('Press enter to continue');

% Compute IRFs and error bands, then plot
[IRF, IRF_opt] = VARir(VARout,24,'oir');
[IRFinf, IRFsup, IRFmed] = VARirband(VARout,IRF_opt,100,66);
VARirplot(IRFmed,0,labels,'irf',IRFinf,IRFsup)

% Compute FEVDs and error bands
[FEVD, FEVD_opt] = VARfevd(VARout,24,'oir');
[FEVDinf,FEVDsup,FEVDmed] = VARfevdband(VARout,FEVD_opt,100,17);

% Retrieve Forecast Error Variance Decomposition
FEVD_Table(1, :) = FEVD(1,:,1);
FEVD_Table(2, :) = FEVD(4,:,1);
FEVD_Table(3, :) = FEVD(8,:,1);
FEVD_Table(4, :) = FEVD(12,:,1);

FEVD_Table(5, :) = FEVD(1,:,2);
FEVD_Table(6, :) = FEVD(4,:,2);
FEVD_Table(7, :) = FEVD(8,:,2);
FEVD_Table(8, :) = FEVD(12,:,2);

FEVD_Table(9, :) = FEVD(1,:,3);
FEVD_Table(10,:) = FEVD(4,:,3);
FEVD_Table(11,:) = FEVD(8,:,3);
FEVD_Table(12,:) = FEVD(12,:,3);

%% Print Table 1.B on screen
disp(' ')
disp('Variance Decomposition of Inflation (t=1,4,8,12)')
disp('---------------------------------------------------')
mprint(FEVD_Table(1:4,:));
disp('Variance Decomposition of Unemployment (t=1,4,8,12)')
disp('---------------------------------------------------')
mprint(FEVD_Table(5:8,:));
disp('Variance Decomposition of Fed Funds (t=1,4,8,12)')
disp('---------------------------------------------------')
mprint(FEVD_Table(9:12,:));