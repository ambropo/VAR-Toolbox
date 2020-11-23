function H = AreaPlot(X)
% =======================================================================
% Creates an area graph with positive data values stacked on the positive
% quadrant and negative data values stacked on the negative quadrant
% =======================================================================
% H = AreaPlot(X)
% -----------------------------------------------------------------------
% INPUT
%   - X: data to plot [nobs x nvars]
% -----------------------------------------------------------------------
% OUTPUT
%   - H: handle to graph
% -----------------------------------------------------------------------
% EXAMPLE
%   X = randn(20,2);
%   H = AreaPlot(X)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------



H(1,:) = area((X).*(X>0),'LineStyle','none'); 
for ii=1:size(H,2)
    H(1,ii).FaceColor = cmap(ii);
    H(1,ii).EdgeColor = H(1,ii).FaceColor;
end
hold on;
H(2,:) = area((X).*(X<0),'LineStyle','none'); 
for ii=1:size(H,2)
    H(2,ii).FaceColor = H(1,ii).FaceColor;
    H(2,ii).EdgeColor = H(2,ii).FaceColor;
end
