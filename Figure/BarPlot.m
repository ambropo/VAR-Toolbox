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
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PLOT POSITIVE VALUES
% -----------------------------------------------------------------------
% (X).*(X>0) zeros out every negative entry, so only positive bars are stacked
% above zero. Colors are drawn from the toolbox color map.
H(1,:) = bar((X).*(X>0), 'stacked');
for ii=1:size(H,2)
    H(1,ii).FaceColor = cmap(ii);
    H(1,ii).EdgeColor = H(1,ii).FaceColor;
end

% Save hold state so the caller's hold setting is not altered on return
holdStatus = ishold;
hold on

%% 2. PLOT NEGATIVE VALUES
% -----------------------------------------------------------------------
% (X).*(X<0) zeros out every positive entry, so only negative bars are
% stacked below zero. Each series reuses the same color as its positive bar.
H(2,:) = bar((X).*(X<0), 'stacked');
for ii=1:size(H,2)
    H(2,ii).FaceColor = H(1,ii).FaceColor;
    H(2,ii).EdgeColor = H(2,ii).FaceColor;
end

% Restore the caller's hold state
if ~holdStatus; hold off; end
