%% 1. PRELIMINARIES
%-------------------------------------------------------------------------- 
delete 'SCREEN.m' 
clear all; clear session; close all; clc
warning off all
addpath(genpath('/Users/jambro/Google Drive/VAR-Toolbox/'))
addpath('codes')


%% 1. LOAD DATA
%************************************************************************** 
% The data used in this example is read from an Excel file and stored in a
% structure (DATA).
%-------------------------------------------------------------------------- 

% Load data from Gertler and Karadi data set
[xlsdata, xlstext] = xlsread('data/GK2015_Data.xlsx','VAR_data');
data   = Num2NaN(xlsdata(:,3:end));
vnames = xlstext(1,3:end);

% Store variables in the structure DATA
for ii=1:length(vnames)
    DATA.(vnames{ii}) = data(:,ii);
end
year = xlsdata(1,1);
month = xlsdata(1,2);

% Observations
nobs = size(data,1);


%% 2. PLOT DATA
%************************************************************************** 

% Select the list of variables to plot...
Xvnames = {'logip','gs1'};

% ... and corresponding labels to be used for plots
Xvnames_long = {'Industrial Production','1-year Rate'};
Xnvar        = length(Xvnames);

% Create matrices of variables to be used in the VAR
X = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA.(Xvnames{ii});
end

% Open a figure of the desired size and plot the selected series
FigSize(26,12)
for ii=1:Xnvar
    subplot(1,2,ii)
    H(ii) = plot(X(:,ii),'LineWidth',3,'Color',cmap(1));
    title(Xvnames_long(ii)); 
    DatesPlot(year+(month-1)/12,nobs,6,'m') % Set the x-axis label 
    grid on; 
end

% Create a legend common to the two panels
lopt = LegOption; lopt.handle = H; LegSubplot(vnames,lopt); FigFont(10);

% Save figure
SaveFigure('graphics/F1_PLOT',1)
clf('reset')


%% 3. VAR ESTIMATION
%************************************************************************** 
% VAR estimations is achieved in two steps: (1) set the vector of endogenous 
% variables, the desired number of lags, and deterministic variables; (2)
% run teh VARmdoel function.
%-------------------------------------------------------------------------- 

% Select list of endogenous variables (these will be pulled from the 
% structure DATA, where all data is stored) and their corresponding labels 
% that will be used for plots
Xvnames      = {'logip','gs1'};
Xvnames_long = {'Industrial Production','Policy rate'};
Xnvar        = length(Xvnames);

% Create matrices of variables to be used in the VAR
X = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA.(Xvnames{ii});
end

% Set the deterministic variable in the VAR (1=constant, 2=trend)
det = 1;

% Set number of lags
nlags = 12;

% Estimate VAR by OLS
[VAR, VARopt] = VARmodel(X,nlags,det);

% Print at screen the outputs of the VARmodel function
disp(VAR)
disp(VARopt)

% Update the VARopt structure with additional details
VARopt.vnames = Xvnames_long;

% Print at screen and create table that can be exported to Excel
[TABLE, beta] = VARprint(VAR,VARopt,2);


%% 4. IDENTIFICATION WITH ZERO CONTEMPORANEOUS RESTRICTIONS 
%************************************************************************** 
% Identification with zero contemporaneous restrictions is achieved in two 
% steps: (1) set the identification scheme mnemonic in the structure 
% VARopt to the desired one, in this case "ch"; (2) run the VARir or the 
% VARvd functions. For the zero contemporaneous restrictions 
% identification, consider the simple bivariate VAR estimated in the 
% previous section.
%-------------------------------------------------------------------------- 

% In the case of zero contemporaneous restrictions set:
VARopt.ident = 'ch';

% Update the VARopt structure with additional details to be used in IR 
% calculations and plots
VARopt.nsteps = 60;
VARopt.quality = 1;
VARopt.FigSize = [26,12];
VARopt.firstdate = year+(month-1)/12;
VARopt.frequency = 'm';
VARopt.figname= 'graphics/CH_';

% 4.1 IMPULSE RESPONSES
%-------------------------------------------------------------------------- 
% Compute IR
[IR, VAR] = VARir(VAR,VARopt);
% Compute IR error bands
[IRinf,IRsup,IRmed,IRbar] = VARirband(VAR,VARopt);
% Plot IR
VARirplot(IRbar,VARopt,IRinf,IRsup);

% 4.2 FORECAST ERROR VARIANCE DECOMPOSITION
%-------------------------------------------------------------------------- 
% Compute VD
[VD, VAR] = VARvd(VAR,VARopt);
% Compute VD error bands
[VDinf,VDsup,VDmed,VDbar] = VARvdband(VAR,VARopt);
% Plot VD
VARvdplot(VDbar,VARopt);

% 4.3 HISTORICAL DECOMPOSITION
%-------------------------------------------------------------------------- 
% Compute HD
[HD, VAR] = VARhd(VAR,VARopt);
% Plot HD
VARhdplot(HD,VARopt);


%% 5. IDENTIFICATION WITH ZERO LONG-RUN RESTRICTIONS 
%************************************************************************** 
% As in the previous section, identification is achieved in two steps: (1) 
% set the identification scheme mnemonic in the structure VARopt to the 
% desired one, in this case "bq"; (2) run the VARir or VARvd functions. 
% For the zero long-run restrictions identification, consider the same VAR 
% as in the previous section.
%-------------------------------------------------------------------------- 

% In the case of zero long-run restrictions identification set:
VARopt.ident = 'bq';

% Update the options in VARopt to be used in IR calculations and plots
VARopt.figname= 'graphics/BQ_';

% 5.1 IMPULSE RESPONSES
%-------------------------------------------------------------------------- 
% Compute IR
[IR, VAR] = VARir(VAR,VARopt);
% Compute error bands
[IRinf,IRsup,IRmed,IRbar] = VARirband(VAR,VARopt);
% Plot
VARirplot(IRbar,VARopt,IRinf,IRsup);

% 5.2 FORECAST ERROR VARIANCE DECOMPOSITION
%-------------------------------------------------------------------------- 
% Compute VD
[VD, VAR] = VARvd(VAR,VARopt);
% Compute error bands
[VDinf,VDsup,VDmed,VDbar] = VARvdband(VAR,VARopt);
% Plot
VARvdplot(VDbar,VARopt);

% 5.3 HISTORICAL DECOMPOSITION
%-------------------------------------------------------------------------- 
% Compute HD
[HD, VAR] = VARhd(VAR,VARopt);
% Plot HD
VARhdplot(HD,VARopt);


%% 5. IDENTIFICATION WITH SIGN RESTRICTIONS
%************************************************************************** 
% For the sign restrictions example, consider a larger VAR  with four 
% endogenous variables. Identification with sign restrictions is achieved 
% in a slightly different way relative to zero contemporaneous or long-run 
% restrictions. Identification is achieved in two steps: (1) define a 
% matrix with the sign restrictions that the IRs have to satisfy; (2) run 
% the SR function. 
%-------------------------------------------------------------------------- 

% 5.1 FOUR-VARIABLE VAR ESTIMATION
%-------------------------------------------------------------------------- 
% Select list of endogenous variables for the VAR estimation with the usual 
% notation:
Xvnames      = {'gs1','logip','logcpi','ebp'};
Xvnames_long = {'Policy rate','Industrial Production','CPI','Excess Bond Premium'};
Xnvar        = length(Xvnames);

% Create matrices of variables to be used in the VAR
X = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA.(Xvnames{ii});
end

% Set the deterministic variable in the VAR (1=constant, 2=trend)
det = 1;

% Set number of nlags
nlags = 12;

% Estimate VAR by OLS
[VAR, VARopt] = VARmodel(X,nlags,det);

% Update the VARopt structure with additional details to be used in IR 
% calculations and plots
VARopt.vnames = Xvnames_long;
VARopt.nsteps = 60;
VARopt.quality = 1;
VARopt.FigSize = [26,12];
VARopt.firstdate = year+(month-1)/12;
VARopt.figname= 'graphics/SR_';
VARopt.frequency = 'm';

% 5.2 IDENTIFICATION
%-------------------------------------------------------------------------- 
% Define the shock names
VARopt.snames = {'Demand Shock','Supply Shock','Monetary Policy Shock','Unidentified'};

% Define the sign restrictions
SIGN = [-1,       0,       1      0;        ... policy rate
        -1,      -1,      -1      0;        ... ip        
        -1,       1,      -1      0;        ... cpi
         1,       1,       1      0];       ... ebp
       % D        S        MP     U   

% Define the number of steps the restrictions are imposed for:
VARopt.sr_hor = 6;

% Set options the credible intervals
VARopt.pctg = 95;

% The functin SR performs the sign restrictions identification and computes
% IRs, VDs, and HDs. All the results are stored in SRout
SRout = SR(VAR,SIGN,VARopt);

% 5.3 PLOT
%-------------------------------------------------------------------------- 
% Plot impulse responses
VARopt.FigSize = [26,24];
SRirplot(SRout.IRmed,VARopt,SRout.IRinf,SRout.IRsup);

% Plot variance decompositions
VARopt.FigSize = [26,24];
SRvdplot(SRout.VD,VARopt);

% To plot Plot hd
VARopt.FigSize = [26,12];
SRhdplot(SRout.HD,VARopt);


%% 6. IDENTIFICATION WITH EXTERNAL INSTRUMENTS
%************************************************************************** 
% Identification with external instruments is achieved in three steps: (1) 
% set the identification scheme mnemonic in the structure VARopt to the 
% desired one, in this case "iv"; (2) update the VARopt structure with the 
% external instrument to be used for identification; (3) run the VARir 
% function. For the external instruments example, we consider the same VAR 
% as in the sign restrictions example. 
%-------------------------------------------------------------------------- 

% First update the VARopt structure with additional details to be used for
% the IR calculations and plots
VARopt.figname= 'graphics/IV_';

% With the usual notation, select the instrument from the DATA structure:
IVvnames      = {'ff4_tc'};
IVvnames_long = {'FF4 futures'};
IVnvar        = length(IVvnames);

% Create vector of instruments to be used in the VAR
IV = nan(nobs,IVnvar);
for ii=1:IVnvar
    IV(:,ii) = DATA.(IVvnames{ii});
end

% Identification is achieved with the external instrument IV, which needs
% to be added to the VARopt structure
VAR.IV = IV;

% Update the options in VARopt to be used in IR calculations and plots
VARopt.ident = 'iv';
VARopt.method = 'wild';

% Compute IRs
[IR, VAR] = VARir(VAR,VARopt);

% Compute error bands
[IRinf,IRsup,IRmed,IRbar] = VARirband(VAR,VARopt);

% Can now plot the impulse responses with the usual code
VARopt.FigSize = [26,24];
VARirplot(IRbar,VARopt,IRinf,IRsup);


%% 7. IDENTIFICATION WITH A MIX OF EXTERNAL INSTRUMENTS AND SIGN RESTRICTIONS
%************************************************************************** 
% Identification with external instruments is achieved in three steps: (1) 
% set the identification scheme mnemonic in the structure VARopt to the 
% desired one, in this case "iv"; (2) update the VARopt structure with the 
% external instrument to be used for identification; (3) run the VARir 
% function. For the external instruments example, we consider the same VAR 
% as in the sign restrictions example. 
%-------------------------------------------------------------------------- 

% First update the VARopt structure with additional details to be used for
% the IR calculations and plots
VARopt.figname= 'graphics/IVSR_';

% Define the shock names
VARopt.snames = {'Monetary policy Shock','Demand Shock','Supply Shock','Unidentified'};

% But now we assume that the first shock is identified with the external 
% instrument. In other words, the first column of the B matrix is given by:
disp(VAR.b)

% So, we define the sign restrictions only for the aggregate demand, the 
% aggregate supply, and the un-identified shock
SIGN = [-1,       0,      0;        ... policy rate
        -1,      -1,      0;        ... ip        
        -1,       1,      0;        ... cpi
         1,       1,      0];       ... ebp
       % D        S       U   

% Define the number of steps the restrictions are imposed for:
VARopt.sr_hor = 6;

% Set options the credible intervals
VARopt.pctg = 95;

% The functin SR performs the sign restrictions identification and computes
% IRs, VDs, and HDs. All the results are stored in SRout
SRout = SR(VAR,SIGN,VARopt);

% Plot impulse responses
VARopt.FigSize = [26,24];
SRirplot(SRout.IRmed,VARopt,SRout.IRinf,SRout.IRsup);


%%
m2tex('VARToolbox_Code.m')
% rmpath(genpath('C:/AMPER/VARToolbox'))


