% Replication of the monetary VAR in Uhligh (2005, JME)
% Figure 6, page 397
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
% Ambrogio Cesa Bianchi, January 2014
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
[data, label] = xlsread('Uhlig2005_Data.xls','Sheet1');

% Define label for plots
dates = label(2:end,1);
vnames = label(1,2:end);

% Transform data
X(:,1:3) = log(data(:,1:3))*100;
X(:,4)   =     data(:,4);
X(:,5:6) = log(data(:,5:6))*100;

%% VAR PRELIMINARIES AND ESTIMATION

% Define number of variables and of observations
[nobs, nvar] = size(X);

% Set the case for the VAR (0, 1, or 2)
cons = 0;

% Set number of nlags
nlags = 12;

% number of periods of IRF
nsteps = 60;

% Estimate VAR
VAR = VARmodel(X,nlags,cons);


%% SIGN RESTRICTIONS

% positive (1),negative (-1)
% unrestricted set all columns to zero
                                   
%           from   to   sign
R(:,:,1) = [ 0     0     0    % Real GDP
             1     6    -1    % Inflation
             1     6    -1    % Commodity Price
             1     6     1    % Fed Fund
             1     6    -1    % NonBorr. Reserves
             0     0     0];  % Total Reserves
         
         
ndraws = 500;
snames = {'Mon. Pol.'};
SRout = SR(VAR,nsteps,R,ndraws);

IRF = SRout.IRF_med;
INF = SRout.IRF_inf;
SUP = SRout.IRF_sup;
SRirplot(IRF,0,vnames,snames,'IRF',INF,SUP,0,12)