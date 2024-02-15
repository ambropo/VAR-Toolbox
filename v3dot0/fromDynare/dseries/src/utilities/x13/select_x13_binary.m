function x13_binary = select_x13_binary(warn_only)

% Returns the path to the X13 binary. If no X13 binary can be found, raises an
% error (unless warn_only=true, in which case it returns an empty string and
% displays a warning).

% Copyright (C) 2017-2019 Dynare Team
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

if nargin < 1
    warn_only = false;
end

dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
dseries_x13_root = sprintf('%s%s%s%s%s%s%s', dseries_src_root, '..', filesep(), 'externals', filesep(), 'x13', filesep());

if ismac()
    x13_binary = sprintf('%s%s%s', dseries_x13_root, 'macOS', filesep());
    if is64bit()
        x13_binary = sprintf('%s%s%s%s', x13_binary, '64', filesep(), 'x13as');
    else
        x13_binary = sprintf('%s%s%s%s', x13_binary, '32', filesep(), 'x13as');
    end
    if ~exist(x13_binary, 'file')
        [status, x13_binary] = system('which x13as');
        if ~status
            x13_binary = deblank(x13_binary);
        end
    end
elseif isunix()
    x13_binary = sprintf('%s%s%s', dseries_x13_root, 'linux', filesep());
    if is64bit()
        x13_binary = sprintf('%s%s%s%s', x13_binary, '64', filesep(), 'x13as');
    else
        x13_binary = sprintf('%s%s%s%s', x13_binary, '32', filesep(), 'x13as');
    end
    if ~exist(x13_binary, 'file')
        [status, x13_binary] = system('command -v x13as');
        if ~status
            x13_binary = deblank(x13_binary);
        end
    end
elseif ispc()
    x13_binary = sprintf('%s%s%s', dseries_x13_root, 'windows', filesep());
    if is64bit()
        x13_binary = sprintf('%s%s%s%s', x13_binary, '64', filesep(), 'x13as.exe');
    else
        x13_binary = sprintf('%s%s%s%s', x13_binary, '32', filesep(), 'x13as.exe');
    end
else
    error('Unsupported platform')
end

if ~exist(x13_binary, 'file')
    if warn_only
        warning(sprintf(['X13 binary is not available.\n' ...
            'If you are under Debian or Ubuntu, you can install it through your package manager, with ''apt install x13as''.\n' ...
            'If you are under Windows or macOS, this probably means that you did not install the dseries toolbox through an official package.\n']));
        x13_binary = '';
    else
        error('Can''t find X13 binary');
    end
end
