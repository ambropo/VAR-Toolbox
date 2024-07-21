function o = rename_(o, old, new) % --*-- Unitary tests --*--

% Renames variables in a dseries object.
%
% INPUTS
% - o     [dseries]
% - old   [string, cell]
% - new   [string, cell]
%
% OUTPUTS
% - o     [dseries]

% Copyright (C) 2013-2021 Dynare Team
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

if isempty(o)
    error('dseries::rename: Cannot rename variable(s) because the object is empty!')
end

if nargin<3
    % old is new!
    if ischar(old) && isequal(vobs(o), 1)
        o.name = {old};
    elseif iscellstr(old) && isequal(vobs(o), length(old))
        o.name = old(:);
    else
        error('dseries::rename: Cannot rename variables (wrong input types or wrong dimensions).')
    end
    return
else
    if ischar(old) && ischar(new)
        multi = false;
        idname = find(strcmp(old, o.name));
        if isempty(idname)
            error('dseries::rename: Variable to be replaced (%s) is unknown', old)
        end
    elseif iscell(old) && iscell(new)
        if isvector(old) && isvector(new)
            if all(cellfun(@ischar, old)) && all(cellfun(@ischar, new)) && all(cellfun(@isrow, old)) && all(cellfun(@isrow, new))
                if length(old)==length(new)
                    multi = true;
                    names = setdiff(old, o.name);
                    names = sprintf('%s ', names{:});
                    names = names(1:end-1);
                    if ~isempty(names)
                        names = sprintf('%s ', names{:});
                        names = names(1:end-1);
                        error('dseries::rename: Some variable (%s) to be replaced are unknown.', names)
                    end
                else
                    error('dseries::rename: Input cell arrays must have the same number of elements.')
                end
            else
                error('dseries::rename: Inputs must be cell of row char arrays.')
            end
        else
            error('dseries::rename: Inputs must be one dimensional cell arrays.')
        end
    else
        error('dseries::rename: Input arguments must be a pair of char arrays or a pair of cell arrays.')
    end
end

if multi
    for i=1:length(old)
        o.name(strcmp(old{i}, o.name)) = new(i);
    end
else
    o.name(idname) = {new};
end

return

%@test:1
ts = dseries([transpose(1:5), transpose(6:10)],'1950q1',{'Output'; 'Consumption'}, {'Y_t'; 'C_t'});
try
    ts.rename_('Output','Production');
    t(1) = 1;
catch
    t(1) = 0;
end

if t(1)>1
    t(2) = dassert(ts.freq,4);
    t(3) = dassert(ts.init.freq,4);
    t(4) = dassert(ts.init.time,[1950, 1]);
    t(5) = dassert(ts.vobs,2);
    t(6) = dassert(ts.nobs,5);
    t(7) = dassert(ts.name,{'Production'; 'Consumption'});
    t(8) = dassert(ts.tex,{'Y_t'; 'C_t'});
end

T = all(t);
%@eof:1

%@test:2
ts = dseries(randn(10,1));
try
    ts.rename_('Dora');
    t(1) = 1;
catch
    t(1) = 0;
end

if t(1)>1
    t(2) = dassert(ts.name,{'Dora'});
end

T = all(t);
%@eof:2

%@test:3
ts = dseries(randn(10,3));
try
    ts.rename_({'Dora', 'The', 'Explorer'});
    t(1) = 1;
catch
    t(1) = 0;
end

if t(1)
    t(2) = dassert(ts.name, {'Dora'; 'The'; 'Explorer'});
end

T = all(t);
%@eof:3

%@test:4
ts = dseries(randn(10,3), '1938Q4', {'Dora', 'The', 'Explorer'});
try
    ts.rename_({'Dora', 'The', 'Explorer'}, {'Make', 'my', 'day'});
    t(1) = 1;
catch
    t(1) = 0;
end

if t(1)
    t(2) = dassert(ts.name, {'Make'; 'my'; 'day'});
end

T = all(t);
%@eof:4
