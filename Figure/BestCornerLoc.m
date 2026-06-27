function loc = BestCornerLoc(ax)
% =======================================================================
% Find the corner of ax with the least plotted-data density for a legend.
% =======================================================================
% loc = BestCornerLoc(ax)
% -----------------------------------------------------------------------
% INPUT
%   - ax: axes handle [axes]
% -----------------------------------------------------------------------
% OUTPUT
%   - loc: legend location string: 'northeast', 'northwest', 'southeast',
%          or 'southwest' [char]
% -----------------------------------------------------------------------
% EXAMPLE
%   loc = BestCornerLoc(gca);
%   lh  = legend(gca, {'series 1','series 2'}, 'Location', loc);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: May 2026. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. PARTITION AXES INTO FOUR CORNER QUADRANTS
% -----------------------------------------------------------------------
% Each quadrant covers the half of the axes range nearest that corner.
% Data density is estimated by counting (x,y) samples that fall inside
% each quadrant; the emptiest quadrant becomes the legend location.

% Label each corner and compute the axis midpoints that define the boundaries
corners = {'northeast','northwest','southeast','southwest'};
xl = ax.XLim; yl = ax.YLim;
xmid = mean(xl); ymid = mean(yl);

% Bounding box for each quadrant [xmin xmax ymin ymax]
regions = { [xmid xl(2) ymid yl(2)]; ...  % northeast
            [xl(1) xmid ymid yl(2)]; ...  % northwest
            [xmid xl(2) yl(1) ymid]; ...  % southeast
            [xl(1) xmid yl(1) ymid]  };   % southwest

%% 2. COUNT DATA SAMPLES IN EACH QUADRANT
% -----------------------------------------------------------------------
% Walk every child of ax that exposes XData/YData (lines, area series,
% patches). NaN values are skipped.

% Initialise sample counts and retrieve all children of the axes
counts = zeros(1,4);
kids   = ax.Children;

% For each quadrant, sum samples from all plottable children that fall within it
for k = 1:4
    r = regions{k};
    for j = 1:numel(kids)
        if isprop(kids(j),'XData') && isprop(kids(j),'YData')
            xd = double(kids(j).XData(:));
            yd = double(kids(j).YData(:));
            ok = ~isnan(xd) & ~isnan(yd);
            counts(k) = counts(k) + sum( xd(ok) >= r(1) & xd(ok) <= r(2) & ...
                                         yd(ok) >= r(3) & yd(ok) <= r(4) );
        end
    end
end

%% 3. RETURN THE LEAST-POPULATED CORNER
% -----------------------------------------------------------------------
[~, best] = min(counts);
loc = corners{best};
