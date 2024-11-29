%% 0. PRELIMINARIES
%------------------------------------------------------------------
clear; close all; clc
warning off all
format short g
addpath(genpath('/Users/jambro/GDrive/VAR-Toolbox/v3dot0'))

%% 1. LOAD AND STORE DATA
%****************************************************************** 
% Loads some US macro data to be used in the first example. The data is 
% stored in the structure DATA
%------------------------------------------------------------------
% Load data from US macro data set
[xlsdata, xlstext] = xlsread('data/Simple_Data.xlsx','Sheet1');
dates = xlstext(3:end,1);       % vector of dates in string format
datesnum = Date2Num(dates);     % vector of dates in numeric format
vnames_long = xlstext(1,2:end); % full variable names 
vnames = xlstext(2,2:end);      % variable mnemonic 
nvar = length(vnames);          % number of variables in spreadsheet
data   = Num2NaN(xlsdata);      % matrix of data in spreadsheet
% Store variables in the structure DATA
for ii=1:length(vnames)
    DATA.(vnames{ii}) = data(:,ii);
end
% Observations
nobs = size(data,1);

%% 2. TREAT DATA
%****************************************************************** 
% Computes the growth rate of real GDP and CPI index and the first 
% difference of the 1-year Treasury Bill yield
%------------------------------------------------------------------
% Select variables to treat
tempnames = {'gdp','cpi','i1yr'};         % variable mnemonics
temptreat = {'logdiff','logdiff','diff'}; % type of transformation
tempscale = [100 100 1];                  % rescaling (if needed)
% Treat and add to DATA structure
for ii=1:length(tempnames)
    aux = {['d' tempnames{ii}]};
    DATA.(aux{1}) = tempscale(ii)*...
        XoX(DATA.(tempnames{ii}),1,temptreat{ii});
end
delete temp*

%% 3. VAR ESTIMATION
%****************************************************************** 
% VAR estimation is achieved in two steps. First, select list of 
% endogenous variables (these will be pulled from the structure DATA, 
% where all data is stored). Second, set desired number of lags and 
% deterministic variables and run the VARmodel function.
%------------------------------------------------------------------
% Select the list of endogenous variables...
Xvnames = {'dgdp','i1yr'};
% ... and corresponding labels to be used in plots
Xvnames_long = {'Real GDP Growth','1-year Int. Rate'};
% Number of endo variables
Xnvar = length(Xvnames);
% Create matrix X of variables to be used in the VAR
X = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA.(Xvnames{ii});
end
% Open a figure of the desired size and plot the selected variables
FigSize(26,8)
for ii=1:Xnvar
    subplot(1,2,ii)
    H(ii) = plot(X(:,ii),'LineWidth',3,'Color',cmap(1));
    title(Xvnames_long(ii)); 
    DatesPlot(datesnum(1),nobs,6,'q') % Set the x-axis labels
    grid on; 
end
% Save figure
SaveFigure('graphics/BIV_DATA',2)
clf('reset')
% Make a common sample by removing NaNs
[X, fo, lo] = CommonSample(X);
% Set the deterministic variable in the VAR (1=constant, 2=trend)
det = 1;
% Set number of lags
nlags = 1;
% Estimate VAR by OLS
[VAR, VARopt] = VARmodel(X,nlags,det);
% Print at screen the outputs of the VARmodel estimation
format short
disp(VAR)
disp(VAR.F)
disp(VAR.sigma)
disp(VARopt)
% Update the VARopt structure with additional details
VARopt.vnames = Xvnames_long;
% Print at screen VAR coefficients and create table 
[TABLE, beta] = VARprint(VAR,VARopt,2);

%% 4. IDENTIFICATION WITH ZERO CONTEMPORANEOUS RESTRICTIONS 
%****************************************************************** 
% Identification with zero contemporaneous restrictions is achieved in two 
% steps: (1) set the identification scheme mnemonic in the structure 
% VARopt to the desired one, in this case "short"; (2) run VARir, VARvd or
% VARhd functions. 
%------------------------------------------------------------------ 
% Update the VARopt structure to select zero short-run restrictions 
VARopt.ident = 'short';
% Update the VARopt structure with additional details 
VARopt.vnames = Xvnames_long;            % variable names in plots
VARopt.nsteps = 12;                      % max horizon of IRF
VARopt.FigSize = [26,12];                % size of window (figures)
VARopt.firstdate = datesnum(1);          % first date in plots
VARopt.frequency = 'q';                  % frequency of the data
VARopt.snames = {'\epsilon^{Demand}',... % shock names
    '\epsilon^{MonPol}'};
% Compute impulse response
[IR, VAR] = VARir(VAR,VARopt);
% Print at screen 
format short
disp(VAR.B)
disp(IR(1:4,:,2))
% Compute structural shocks (Tx2)
eps_short = (VAR.B\VAR.resid')';
disp(corr(eps_short))


%% 5. IDENTIFICATION WITH ZERO LONG-RUN RESTRICTIONS 
%************************************************************************** 
% Identification with zero long-run restrictions is achieved in two 
% steps: (1) set the identification scheme mnemonic in the structure 
% VARopt to the desired one, in this case "long"; (2) run VARir, VARvd or
% VARhd functions. 
%------------------------------------------------------------------ 
% Update the VARopt structure to select zero long-run restrictions 
VARopt.ident = 'long';
% Update the VARopt structure with additional details 
VARopt.snames = {'\epsilon^{Supply}',... % shocks names
    '\epsilon^{Demand}'};
% Compute impulse responses
[IR, VAR] = VARir(VAR,VARopt);
% Print at screen 
format short
disp(VAR.B)
disp((eye(2)-VAR.Fcomp)\VAR.B)
% Compute impulse responses in the very long-run and plot
VARopt.nsteps = 150;
[IR, VAR] = VARir(VAR,VARopt);
FigSize(26,8)
subplot(1,2,1)
plot(cumsum(IR(:,1,2)),'LineWidth',2,'Marker','*','Color',cmap(1)); hold on
plot(zeros(VARopt.nsteps),'--k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title('Cumulative response of GDP growth')
subplot(1,2,2)
plot(cumsum(IR(:,2,2)),'LineWidth',2,'Marker','*','Color',cmap(1)); hold on
plot(zeros(VARopt.nsteps),'--k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title('Cumulative response of the 1-year rate')
SaveFigure('graphics/longCum_',2);
clf('reset')
% Compute structural shocks (Tx2)
eps_long = (VAR.B\VAR.resid')';


%% 6. IDENTIFICATION WITH SIGN RESTRICTIONS 
%************************************************************************** 
% Identification with sign restrictions is achieved in two steps: (1)
% define a matrix with the sign restrictions that the impulse responses 
% have to satisfy; (2) run the SR function. 
%------------------------------------------------------------------ 
% Define sign restrictions
% Positive 1, Negative -1, Unrestricted 0:
SIGN = [ 1, 1;  % Real GDP
         1,-1]; % 1-year rate 
% Update the VARopt structure with inputs to the sign restriction routine
VARopt.ndraws = 500;
VARopt.sr_hor = 1;
VARopt.pctg = 68; 
% Update the VARopt structure with additional details 
VARopt.nsteps = 12;                      % horizon of impulse responses
VARopt.figname= 'graphics/sign_';        % folder and file prefix
VARopt.FigSize = [26 8];                 % size of window (figures)
VARopt.quality = 2;                 % size of window (figures)
VARopt.snames = {'\epsilon^{Demand}',... % shocks names
    '\epsilon^{MonPol}'};
% Implement sign restrictions identification with SR routine
SRout = SR(VAR,SIGN,VARopt);
% Plot all Btilde
FigSize(26,8)
subplot(1,2,1)
plot(squeeze(SRout.IRall(:,1,2,:))); hold on
plot(zeros(VARopt.nsteps),'--k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title('Response of GDP growth to \epsilon^{MonPol}')
subplot(1,2,2)
plot(squeeze(SRout.IRall(:,2,2,:))); hold on
plot(zeros(VARopt.nsteps),'--k','LineWidth',0.5); hold on
xlim([1 VARopt.nsteps]);
title('Response of 1-year rate to \epsilon^{MonPol}')
SaveFigure('graphics/signAll_',2);
clf('reset')
% Plot credible intervals
VARirplot(SRout.IRmed,VARopt,SRout.IRinf,SRout.IRsup)
% Compute structural shocks (Tx2)
eps_sign = (SRout.B\VAR.resid')';

%% 7. IDENTIFICATION WITH EXTERNAL INSTRUMENTS
%************************************************************************** 
% Identification with external instruments is achieved in three steps: (1) 
% update the VAR structure with the external instrument to be used in the 
% first stage; (2) set the identification scheme mnemonic in the structure 
% VARopt to the desired one, in this case "iv"; (3) run the VARir function
%-------------------------------------------------------------------------- 

% Create artificial instrument (demand shock from eps_short + noise)
rng(1); 
noise = randn(nobs,1);              % random vector from N(0,1) 
noise = noise(1+fo:end-lo);         % adjust to common sample
iv = [NaN; eps_short(:,1)] + noise; % add noise to demand shock (eps_short)
VAR.IV = iv;                        % update VAR structure
% Update the options in VARopt
VARopt.ident = 'iv';
VARopt.snames = {'\epsilon^{Demand}','\epsilon^{Other}'};
% Compute impulse responses
[IR, VAR] = VARir(VAR,VARopt);
% Plot impulse responses
FigSize(26,8)
for ii=1:Xnvar
    subplot(1,2,ii);
	plot(IR(:,ii),'LineWidth',2,'Marker','*','Color',cmap(1)); hold on;
    plot(zeros(1,VARopt.nsteps),'--k','LineWidth',0.5); hold on
    plot(1,IR(1,ii),'LineStyle','-','Color',cmap(5),'LineWidth',2,...
        'Marker','p','MarkerSize',20,'MarkerFaceColor',cmap(5)); hold on
    xlim([1 VARopt.nsteps]);
    title([Xvnames_long{ii} ' to ' VARopt.snames{1}],'FontWeight','bold','FontSize',10); 
    set(gca, 'Layer', 'top');
end
SaveFigure('graphics/iv_',2)
clf('reset');

%% 8. IDENTIFICATION WITH EXTERNAL INSTRUMENTS AND SIGN RESTRICTIONS
%************************************************************************** 
% Identification with external instruments and sign restrictions is 
% achieved in five steps: (1) update the VAR structure with the external 
% instrument to be used in the first stage; (2) set the identification 
% scheme mnemonic in the structure VARopt to the desired one, in this case 
% "iv"; (3) run the VARir function to get an estimate of Biv; (4) define a 
% matrix with the sign restrictions that the IRs have to satisfy, excluding
% the first shock identified with external instruments; (5) run the SR 
% function. 
%-------------------------------------------------------------------------- 

% VAR structure has already been updated to include the first column of 
% the B matrix that we identified with the instrument in the previous
% section:
disp(VAR.Biv)
% Define sign restrictions to identify monetary policy shock
% Positive 1, Negative -1, Unrestricted 0:
SIGN = [ 1;  % Real GDP
        -1]; % 1-year rate 
% Update the VARopt structure with additional details 
VARopt.figname= 'graphics/iv_sign_';      
VARopt.snames = {'\epsilon^{Demand}','\epsilon^{MonPol}'};
% Implement sign restrictions identification with SR routine 
% conditional on VAR.Biv being already identified 
SRIVout = SR(VAR,SIGN,VARopt);
% Plot impulse responses
VARirplot(SRIVout.IRmed,VARopt,SRIVout.IRinf,SRIVout.IRsup);

m2tex('VARToolbox_Primer_v1.m')

close all


