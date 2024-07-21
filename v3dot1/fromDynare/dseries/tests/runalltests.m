function runalltests()

% Copyright (C) 2015-2022 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dseries submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

dseries_src_root = []; % Will be updated by calling initialize_dseries_class().

opath = path();

system('rm -f failed');
system('rm -f pass');

% Check that the m-unit-tests module is available.
try
    initialize_unit_tests_toolbox;
catch
    error('Missing dependency: m-unit-tests module is not available.')
end

% Get path to the current script
unit_tests_root = strrep(which('runalltests'),'runalltests.m','');

% Initialize the dseries module
try
    initialize_dseries_class();
catch
    addpath([unit_tests_root '../src']);
    initialize_dseries_class();
end

warnstate = warning('off');

if isoctave()
    if ~user_has_octave_forge_package('io')
        error('Missing dependency: io package is not available.')
    end
    more off;
    addpath([unit_tests_root 'fake']);
end

r = run_unitary_tests_in_directory(dseries_src_root(1:end-1));

delete('*.log');

if any(~[r{:,3}])
    system('touch failed');
else
    system('touch pass');
end

warning(warnstate);
path(opath);

display_report(r);
