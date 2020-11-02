% Example. Plotting a panel of time series.
%
% The 'Codes' subfolder includes the following Matlab routines needed to 
% run this program:
%
%  - Figure Toolbox in my web page. Go to:
%    https://sites.google.com/site/ambropo/MatlabCodes
%
% =======================================================================
% Ambrogio Cesa Bianchi, July 2012
% ambrogio.cesabianchi@gmail.com

%% Preliminaries

% Clean up
clear all; close all; clc;

% Add needed toolboxes
addpath('Codes\FigureToolbox')
addpath('Codes\FigureToolbox\ExportFig')

% Import data
[RGDP label] = xlsread('DATA.xlsx','RGDP');
RGDP = RGDP';
[RHP label] = xlsread('DATA.xlsx','RHP');
RHP = RHP';
label = label';
[nobs nvar] = size(RGDP);
year = 1990;
quarter = 1;
titles = label(1,2:end);


%% Plot levels

% Initialize the plot options
opt = PlotOption;
% Modify plot options
opt.row          = 2;
opt.col          = 4;
opt.VariableName = titles;
time = MakeDate(year,quarter,nobs);
opt.timeline     = time;
opt.PanelName    = {};
opt.FigTitle     = 'Real GDP (Level)';
opt.FigName      = 'GDP_Level';
opt.do_RGDP         = 1;
opt.interpr      = 'None';
opt.fontsize     = 11;
opt.fontname     = 'Palatino';
opt.NumTicks     = 5;
opt.piRGDPel        = '-r250';
opt.RGDP_label      = 'Time';
opt.y_label      = 'Level';
FigSize(32,16)

% Plot
LinePlot(RGDP,opt);


%% Plot first differences

% Compute first differences
dRGDP = log(RGDP);
dRGDP = dRGDP(5:end,:)-dRGDP(1:end-4,:);

% Modify plot options
opt.FigTitle     = 'Real GDP (Quarterly Growth Rate)';
opt.y_label      = 'YoY Growth';
opt.FigName      = 'GDP_Growth';
FigSize(32,16)
% Plot
Lineplot(dRGDP,opt);



%% Compare GDP with HP

FigSize(32,16)
opt.compare = 1;
opt.FigTitle     = 'Real GDP VS Real House Price';
opt.FigName      = 'Compare';
opt.y_label      = 'Level';
opt.PanelName    = {'Real GDP'; 'Real House Price'};

ALL(:,:,1) = RGDP;
ALL(:,:,2) = RHP;
LinePlot(ALL,opt)
