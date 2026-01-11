%% 0. PRELIMINARIES
%-------------------------------------------------------------------------- 
clear all; clear session; close all; clc
warning off all
format short g
addpath(genpath('/Users/jambro/GDrive/VAR-Toolbox/v3dot0'))

%% 1. LOAD & STORE DATA
%************************************************************************** 
% Loads some US macro data to be used in the first example. The data is 
% stored in the structure DATA
%-------------------------------------------------------------------------- 
% % % Load data from US macro data set
% % [xlsdata, xlstext] = xlsread('data/Simple_Data.xlsx','Sheet1');
% % dates = xlstext(3:end,1);
% % datesnum = Date2Num(dates);
% % vnames_long = xlstext(1,2:end);
% % vnames = xlstext(2,2:end);
% % nvar = length(vnames);
% % data   = Num2NaN(xlsdata);
% % % Store variables in the structure DATA
% % for ii=1:length(vnames)
% %     DATA.(vnames{ii}) = data(:,ii);
% % end
% % % Observations
% % nobs = size(data,1);
% % % Transform selected variables
% % tempnames = {'cpi','gdp','i1yr'};
% % temptreat = {'logdiff','logdiff','diff'};
% % tempscale = [100,100,1];
% % for ii=1:length(tempnames)
% %     aux = {['d' tempnames{ii}]};
% %     DATA.(aux{1}) = tempscale(ii)*XoX(DATA.(tempnames{ii}),1,temptreat{ii});
% % end
% % 
% % %% 2. PLOT DATA
% % %************************************************************************** 
% % % Plots some selected variables in the data set 
% % %-------------------------------------------------------------------------- 
% % % Select the list of variables to plot...
% % Xvnames = {'gdp','cpi','unemp','vix','i1yr','ebp'};
% % % ... and corresponding labels to be used in plots
% % Xvnames_long = {'Real GDP','CPI','Unemployment','Vix Index',...
% %     '1-year Int. Rate','EBP'};
% % Xnvar = length(Xvnames);
% % % Create matrices of variables to be used in the VAR
% % X = nan(nobs,Xnvar);
% % for ii=1:Xnvar
% %     X(:,ii) = DATA.(Xvnames{ii});
% % end
% % % Open a figure of the desired size and plot the selected series
% % FigSize(26,18)
% % for ii=1:Xnvar
% %     subplot(3,2,ii)
% %     H(ii) = plot(X(:,ii),'LineWidth',3,'Color',cmap(1));
% %     title(Xvnames_long(ii)); 
% %     DatesPlot(datesnum(1),nobs,6,'q') % Set the x-axis label using dates
% %     grid on; 
% % end
% % % Save figure
% % SaveFigure('graphics/DATA_GK',1)
% % clf('reset')
% % 
% % 
% % %% 3. VAR ESTIMATION
% % %************************************************************************** 
% % % VAR estimations is achieved in two steps: (1) define the endogenous 
% % % variables, the desired number of lags, and deterministic variables; (2)
% % % run the VARmodel function.
% % %-------------------------------------------------------------------------- 
% % % Select list of endogenous variables (these will be pulled from the 
% % % structure DATA, where all data is stored) and their corresponding labels 
% % % that will be used in plots
% % Xvnames      = {'dgdp','i1yr'};
% % Xvnames_long = {'Real GDP','1-year Tbill'};
% % Xnvar        = length(Xvnames);
% % % Plot selected data
% % FigSize(26,6)
% % for ii=1:Xnvar
% %     subplot(1,2,ii)
% %     H(ii) = plot(DATA.(Xvnames{ii}),'LineWidth',3,'Color',cmap(1));
% %     title(Xvnames_long(ii)); 
% %     DatesPlot(datesnum(1),nobs,6,'q') % Set the x-axis label using dates
% %     grid on; 
% % end
% % SaveFigure('graphics/BIV_DATA',1)
% % clf('reset')
% % % Create matrices of variables to be used in the VAR
% % X = nan(nobs,Xnvar);
% % for ii=1:Xnvar
% %     X(:,ii) = DATA.(Xvnames{ii});
% % end
% % % Make a common sample by removing NaNs
% % X = CommonSample(X);
% % % Set the deterministic variable in the VAR (1=constant, 2=trend)
% % det = 1;
% % % Set number of lags
% % nlags = 1;
% % % Estimate VAR by OLS
% % [VAR, VARopt] = VARmodel(X,nlags,det);
% % % Print at screen the outputs of the VARmodel function
% % disp(VAR)
% % disp(VARopt)
% % % Update the VARopt structure with additional details
% % VARopt.vnames = Xvnames_long;
% % % Print at screen VAR coefficients and create table 
% % [TABLE, beta] = VARprint(VAR,VARopt,2);
% % % Print at screen some results. Start with estimated coefficients
% % disp(VAR.F)
% % disp(VAR.sigma)
% % % Maximum eigenvalue 
% % disp(eig(VAR.Fcomp))













% % %% 8. IDENTIFICATION WITH A MIX OF EXTERNAL INSTRUMENTS AND SIGN RESTRICTIONS
% % %************************************************************************** 
% % % Identification with external instruments and sign restrictions is 
% % % achieved in five steps: (1) set the identification scheme mnemonic in 
% % % the structure VARopt to the "iv"; (2) update the VARopt structure with 
% % % the external instrument to be used in identification; (3) run the VARir 
% % % function to get na estimate of b; (4) define a matrix with the sign 
% % % restrictions that the IRs have to satisfy; (5) run the SR function. 
% % % The external instrument & sign restriction identification example is 
% % % based on the replication of Cesa-Bianchi and Sokol (2019) paper
% % %-------------------------------------------------------------------------- 
% % 
% % % 8.1 Load data from Cesa-Bianchi and Sokol
% % %-------------------------------------------------------------------------- 
% % [xlsdata, xlstext] = xlsread('data/CS2020_Data.xlsx','Sheet1');
% % dates = xlstext(3:end,1);
% % datesnum = Date2Num(dates);
% % vnames_long = xlstext(1,2:end);
% % vnames = xlstext(2,2:end);
% % nvar = length(vnames);
% % data   = Num2NaN(xlsdata);
% % for ii=1:length(vnames)
% %     DATA.(vnames{ii}) = data(:,ii);
% % end
% % year = str2double(xlstext{3,1}(1:4));
% % month = str2double(xlstext{3,1}(6));
% % nobs = size(data,1);
% % 
% % % 8.2 Plot series
% % %-------------------------------------------------------------------------- 
% % % Plot all series in DATA
% % FigSize(26,18)
% % for ii=1:nvar
% %     subplot(3,2,ii)
% %     H(ii) = plot(DATA.(vnames{ii}),'LineWidth',3,'Color',cmap(1));
% %     title(vnames_long(ii)); 
% %     DatesPlot(datesnum(1),nobs,6,'m') % Set the x-axis label 
% %     grid on; 
% % end
% % SaveFigure('graphics/CS_DATA',2)
% % clf('reset')
% % 
% % % 8.3 Set up and estimate VAR
% % %-------------------------------------------------------------------------- 
% % % Select endo
% % Xvnames_long = {'1yr T-Bill';'Consumer Price Index';'Industrial Production'...
% %         ;'Excess Bond Premium';'Bond yield'};
% % Xvnames      = {'gs1';'logcpi';'logip';'ebp';'bond'};
% % Xnvar        = length(Xvnames);
% % % Create matrices of variables in the VAR
% % X = nan(nobs,Xnvar);
% % for ii=1:Xnvar
% %     X(:,ii) = DATA.(Xvnames{ii});
% % end
% % % With the usual notation, select the instrument from the DATA structure:
% % IVvnames      = {'jk'};
% % IVvnames_long = {'JK instrument'};
% % IVnvar        = length(IVvnames);
% % % Create vector of instruments to be used in the VAR
% % IV = nan(nobs,IVnvar);
% % for ii=1:IVnvar
% %     IV(:,ii) = DATA.(IVvnames{ii});
% % end
% % % Estimate VAR
% % det = 1;
% % nlags = 12;
% % [VAR, VARopt] = VARmodel(X,nlags,det);
% % VARopt.vnames = Xvnames_long;
% % VARopt.nsteps = 60;
% % VARopt.quality = 2;
% % VARopt.FigSize = [26,12];
% % VARopt.firstdate = datesnum(1);
% % VARopt.frequency = 'm';
% % VARopt.figname= 'graphics/CS_';
% % 
% % % 8.4 Identification
% % %-------------------------------------------------------------------------- 
% % % Identification is achieved in multiple steps. First, employ the external 
% % % instrument as in the previous example
% % VAR.IV = IV;
% % % Update the options in VARopt to be used in IR calculations and plots
% % VARopt.ident = 'iv';
% % VARopt.method = 'wild';
% % % Compute IR
% % [IR, VAR] = VARir(VAR,VARopt);
% % % Note that the VAR structure has been updated to include the first column 
% % % of the B matrix that we identified with the instrument
% % disp(VAR.b)
% % % Then set up the sign restrictions. We define the sign restrictions to 
% % % identify aggregate demand, supply, and financial shocks. The monetary 
% % % policy shock has already been identified with IV. One shock is left
% % % unidentified
% % SIGN = [-1,       0,      -1     0;        ... policy rate
% %         -1,      -1,      -1     0;        ... ip        
% %         -1,       1,      -1     0;        ... cpi
% %          1,       1,      +1     0;        ... ebp
% %         -1,       0,      +1     0];       ... bond
% %        % D        S       U      F
% % 
% % % Start with the shock names
% % VARopt.snames = {'Monetary policy Shock','Demand Shock','Supply Shock',...
% %         'Financial Shock','Unidentified'};
% % % Define the number of steps the restrictions are imposed in:
% % VARopt.sr_hor = 6;
% % % Set options the credible intervals
% % VARopt.pctg = 95;
% % % Set number of rotations
% % VARopt.ndraws = 250;
% % % As VAR.b is not empty, the function SR now performs the sign restrictions 
% % % identification prcedure conditional on the VAR.b matrix identified in 
% % % the previous step
% % SRout = SR(VAR,SIGN,VARopt);
% % % Plot impulse responses
% % SRirplot(SRout.IRmed,VARopt,SRout.IRinf,SRout.IRsup);
% % 
% % 
% % %% 9. CLEAN UP
% % %************************************************************************** 
% % % Export tex file
% % m2tex('VARToolbox_Primer.m')
% % % Remove VAR Toolbox from Matlab path
% % rmpath(genpath('/Users/jambro/Google Drive/VAR-Toolbox/v3dot0'))
% % 
% % 
