% Replication of the monetary VAR in Uhligh (2005, JME).
% Figure 6, page 397.
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
[xlsdata, xlstext] = xlsread('Uhlig2005_Data.xls','Sheet1');

% Define and transform (if needed)
dates = xlstext(2:end,1);
vnames = xlstext(1,2:end);
X(:,1:3) = log(xlsdata(:,1:3))*100;
X(:,4)   = xlsdata(:,4);
X(:,5:6) = log(xlsdata(:,5:6))*100;


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
% Restrictions: positive 1, negative -1, unrestricted 0
R(:,:,1) = [ 0     0     0    % Real GDP
             1     6    -1    % Inflation
             1     6    -1    % Commodity Price
             1     6     1    % Fed Fund
             1     6    -1    % NonBorr. Reserves
             0     0     0];  % Total Reserves

% Set options for IRFs and SR
VARopt.nsteps = 60;
VARopt.ndraws = 100;
VARopt.snames = {'MonPol Shock'};
VARopt.vnames = vnames;
% Run sign restrictions routine
SRout = SR(VAR,R,VARopt);
% Save
IRF = SRout.IRFmed;
INF = SRout.IRFinf;
SUP = SRout.IRFsup;
% Plot
SRirplot(IRF,VARopt,INF,SUP)