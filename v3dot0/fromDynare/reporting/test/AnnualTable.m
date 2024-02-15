function rep = AnnualTable(rep, db_a, dc_a, seriesRootName, arange)
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

shortNames = {'US', 'EU', 'JA', 'EA6', 'LA6', 'RC6'};
longNames  = {'Coca Cola', 'Kinder Bueno', 'Pizza', ...
    'Vegetarianism Is Good', 'OS X', 'Dothraki'};

rep.addSeries('tableSubSectionHeader', 'A group', ...
    'tableRowColor', 'red!22');
for i = 1:length(shortNames)
    db_a.tex_rename_([seriesRootName shortNames{i}], longNames{i});
    rep.addSeries('data', db_a{[seriesRootName shortNames{i}]});
    delta = dc_a{[seriesRootName shortNames{i}]}-db_a{[seriesRootName shortNames{i}]};
    delta.tex_rename_('$\Delta$');
    rep.addSeries('data', delta, ...
        'tableShowMarkers', true, ...
        'tableAlignRight', true);
end
end
