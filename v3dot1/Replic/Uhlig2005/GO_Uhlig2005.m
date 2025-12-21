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

%% DATA
% =======================================================================
% Load data 
[xlsdata, xlstext] = xlsread('Uhlig2005_Data.xlsx','Sheet1');
dates = xlstext(3:end,1);
vnames_long = xlstext(1,2:end);
vnames = xlstext(2,2:end);
nvar = length(vnames);
data   = Num2NaN(xlsdata);
for ii=1:length(vnames)
    DATA.(vnames{ii}) = data(:,ii);
end
year = str2double(xlstext{3,1}(1:4));
month = str2double(xlstext{3,1}(6));
nobs = size(data,1);

% Transform selected variables
tempnames = {'y','pi','comm','nbres','res'};
tempscale = [100,100,100,100,100];
for ii=1:length(tempnames)
    DATA.(tempnames{ii}) = tempscale(ii)*DATA.(tempnames{ii});
end

%% VAR ESTIMATION
% =======================================================================
% Define variables 
Xvnames      = vnames;
Xvnames_long = vnames_long;
Xnvar        = length(Xvnames);
% Construct endo
X = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA.(Xvnames{ii});
end
% Set deterministics for the VAR
det = 1;
% Set number of nlags
nlags = 12;
% Estimate VAR
[VAR, VARopt] = VARmodel(X,nlags,det);


%% SIGN RESTRICTIONS
% =======================================================================
% Set options
VARopt.vnames = Xvnames_long;
VARopt.nsteps = 60;
VARopt.snames = {'Mon. Policy Shock'};
VARopt.ndraws = 500;
VARopt.quality = 1;
VARopt.FigSize = [26,8];
VARopt.firstdate = year+(month-1)/12;
VARopt.frequency = 'm';
VARopt.figname= 'graphics/Uhlig_';

% Define sign restrictions : positive 1, negative -1, unrestricted 0
SIGN = [ 0,0,0,0,0,0;  % Real GDP
        -1,0,0,0,0,0;  % Deflator
        -1,0,0,0,0,0;  % Commodity Price
         0,0,0,0,0,0;  % Total Reserves
        -1,0,0,0,0,0;  % NonBorr. Reserves
         1,0,0,0,0,0]; % Fed Fund
     

% Define the number of steps the restrictions are imposed for:
VARopt.sr_hor = 6;

% Set options the credible intervals
VARopt.pctg = 68;

% Run sign restrictions routine
SRout = SR(VAR,SIGN,VARopt);

% Plot
FigSize(20,24)
idx = [1 3 5 2 4 6];
for ii=1:Xnvar
    subplot(3,2,idx(ii))
    PlotSwathe(SRout.IRmed(:,ii,1),[SRout.IRinf(:,ii,1) SRout.IRsup(:,ii,1)]); hold on
    plot(zeros(VARopt.nsteps),'--k');
    title(vnames{ii})
    axis tight
end

% Save
SaveFigure('Uhligh_Replication',1)



