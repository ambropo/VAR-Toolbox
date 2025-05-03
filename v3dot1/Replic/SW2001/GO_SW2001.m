% Replication of the trivariate VAR in Stock and Watson (2001, JEP).
% Figure 1 and Table 1.B.
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

% Load data
[xlsdata, xlstext] = xlsread('SW2001_Data.xlsx','Sheet1');
X = xlsdata;
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
% Set deterministics for the VAR
det = 1;
% Set number of nlags
nlags = 4;
% Estimate VAR
[VAR, VARopt] = VARmodel(X,nlags,det);
% Print estimation on screen
VARopt.vnames = vnames;
[TABLE, beta] = VARprint(VAR,VARopt,2);


%% COMPUTE IR AND VD
%==========================================================================
% Set options some options for IRF calculation
VARopt.nsteps = 24;
VARopt.ident = 'short';
VARopt.vnames = vnames_long;
VARopt.FigSize = [26,12];
% Compute IRF
[IRF, VAR] = VARir(VAR,VARopt);
% Compute error bands
[IRinf,IRsup,IRmed,IRbar] = VARirband(VAR,VARopt);
% Plot
VARirplot(IRbar,VARopt,IRinf,IRsup);

% Compute VD
[VD, VAR] = VARvd(VAR,VARopt);
% Compute VD error bands
[VDinf,VDsup,VDmed,VDbar] = VARvdband(VAR,VARopt);
% Plot VD
VARvdplot(VDbar,VARopt);


%% Print Table 1.B on screen
%==========================================================================
% Retrieve Forecast Error Variance Decomposition
FEVD_Table(1, :) = VD(1,:,1);
FEVD_Table(2, :) = VD(4,:,1);
FEVD_Table(3, :) = VD(8,:,1);
FEVD_Table(4, :) = VD(12,:,1);

FEVD_Table(5, :) = VD(1,:,2);
FEVD_Table(6, :) = VD(4,:,2);
FEVD_Table(7, :) = VD(8,:,2);
FEVD_Table(8, :) = VD(12,:,2);

FEVD_Table(9, :) = VD(1,:,3);
FEVD_Table(10,:) = VD(4,:,3);
FEVD_Table(11,:) = VD(8,:,3);
FEVD_Table(12,:) = VD(12,:,3);

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