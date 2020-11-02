% Replication of the trivariate VAR in Stock and Watson (2001, JEP).
% Figure 1 and Table 1.B.
%
% The VAR Toolbox 2.0 is required to run this code. To get the 
% latest version of the toolboxes visit: 
% 
%       https://sites.google.com/site/ambropo/MatlabCodes
% 
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


%% PRELIMINARIES
% =======================================================================
clear all; clear session; close all; clc
warning off all

% Load data
[xlsdata, xlstext] = xlsread('SW2001_Data.xlsx','Sheet1');
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
nlags = 4;
% Estimate VAR
[VAR, VARopt] = VARmodel(X,nlags,det);
% Print estimation on screen
VARopt.vnames = vnames;
[TABLE, beta] = VARprint(VAR,VARopt,2);
disp(' ')
junk = input('Press enter to continue');


%% COMPUTE IRF AND FEVD
% =======================================================================
% Set options some options for IRF calculation
VARopt.nsteps = 24;
VARopt.ident = 'oir';
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
% % Plot
VARfevdplot(FEVDMED,VARopt,FEVDINF,FEVDSUP);


%% Print Table 1.B on screen
% =======================================================================
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

% Print on screen
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