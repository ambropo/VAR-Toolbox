function H = BarPlot(X)
% =======================================================================
% Creates a bar graph with positive data values stacked on the positive
% quadrant and negative data values stacked on the negative quadrant
% =======================================================================
% H = BarPlot(X)
% -----------------------------------------------------------------------
% INPUT
%   - X: data to plot [nobs x nvars]
% -----------------------------------------------------------------------
% OUTPUT
%   - H: handle to graph
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

H(1,:) = bar((X).*(X>0),'stacked'); 
hold on;
H(2,:) = bar((X).*(X<0),'stacked');
