function rep = CommResidTablePage(rep, db_q, dc_q, trange, vline_after)
% Copyright (C) 2013-2019 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

seriesNames = {{'RES_LRPOIL_GAP_WORLD'}, ...
    {'RES_LRPOIL_BAR_WORLD'}, ...
    {'RES_LRPOIL_G_WORLD'}, ...
    {'RES_LRPFOOD_GAP_WORLD'}, ...
    {'RES_LRPFOOD_BAR_WORLD'}, ...
    {'RES_LRPFOOD_G_WORLD'}};

rep.addTable('title', 'Commodities', ...
    'range', trange, ...
    'vlineAfter', vline_after);

for i = 1:length(seriesNames)
    rep.addSeries('data', db_q{seriesNames{i}{1}});
    delta = db_q{seriesNames{i}{1}} - dc_q{seriesNames{i}{1}};
    delta.tex_rename_('$\Delta$');
    rep.addSeries('data', delta, ...
        'tableShowMarkers', true, ...
        'tableAlignRight', true);
end
end
