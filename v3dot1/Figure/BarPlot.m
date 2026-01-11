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
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(20,2);
%   H = BarPlot(X)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------


H(1,:) = bar((X).*(X>0),'stacked'); 
for ii=1:size(H,2)
    H(1,ii).FaceColor = cmap(ii);
    H(1,ii).EdgeColor = H(1,ii).FaceColor;
end
hold on;
H(2,:) = bar((X).*(X<0),'stacked');
for ii=1:size(H,2)
    H(2,ii).FaceColor = H(1,ii).FaceColor;
    H(2,ii).EdgeColor = H(2,ii).FaceColor;
end
