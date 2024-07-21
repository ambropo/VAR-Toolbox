function initialize_dseries_class()

% Copyright © 2015-2021 Dynare Team
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

% Get the path to the dseries toolbox.
dseries_src_root = strrep(which('initialize_dseries_class'), 'initialize_dseries_class.m', '');

% Is the dseries package used as a standalone?
dseries_src_path_s = strsplit(dseries_src_root, filesep());
isstandalone = ~isequal(dseries_src_path_s(end-3:end), {'matlab', 'modules', 'dseries', 'src'}) & isempty(which('dynare'));

% Set the subfolders to be added in the path.
p = {'mdbnomics2dseries'; ...
     'read'; ...
     'utilities/is'; ...
     'utilities/op'; ...
     'utilities/convert'; ...
     'utilities/str'; ...
     'utilities/insert'; ...
     'utilities/file'; ...
     'utilities/from'; ...
     'utilities/get'; ...
     'utilities/print'; ...
     'utilities/variables'; ...
     'utilities/cumulate'; ...
     'utilities/struct'; ...
     'utilities/misc'; ...
     'utilities/x13'};

% Add missing routines if dynare is not in the path
if ~exist('isint','file')
    p{end+1} = 'utilities/missing/isint';
end

if ~exist('isoctave','file')
    p{end+1} = 'utilities/missing/isoctave';
end

if ~exist('shiftS','file')
    p{end+1} = 'utilities/missing/shiftS';
end

if ~exist('matlab_ver_less_than','file')
    p{end+1} = 'utilities/missing/matlab_ver_less_than';
end

if ~exist('octave_ver_less_than','file')
    p{end+1} = 'utilities/missing/octave_ver_less_than';
end

if ~exist('demean','file')
    p{end+1} = 'utilities/missing/demean';
end

if ~exist('ndim','file')
    p{end+1} = 'utilities/missing/ndim';
end

if ~exist('OCTAVE_VERSION', 'builtin') && isstandalone
    p{end+1} = 'utilities/missing/dims';
end

if ~exist('sample_hp_filter','file')
    p{end+1} = 'utilities/missing/sample_hp_filter';
end

if ~exist('get_file_extension','file')
    p{end+1} = 'utilities/missing/get_file_extension';
end

if exist('OCTAVE_VERSION', 'builtin') && ~exist('user_has_octave_forge_package','file')
    p{end+1} = 'utilities/missing/user_has_octave_forge_package';
end

if ~exist('get_cells_id','file')
    p{end+1} = 'utilities/missing/get_cells_id';
end

if ~exist('randomstring','file')
    p{end+1} = 'utilities/missing/randomstring';
end

if ~exist('one_sided_hp_filter','file')
    p{end+1} = 'utilities/missing/one_sided_hp_filter';
end

if ~exist('nanmean','file')
    p{end+1} = 'utilities/missing/nanmean';
end

% Set path
P = cellfun(@(c)[dseries_src_root c], p, 'uni', false);
addpath(P{:});

% If X13 binary is not available, display a warning, and remove the x13
% subdirectory from the path
if isempty(select_x13_binary(true))
    rmpath([dseries_src_root 'utilities/x13']);
end

% The following version requirement should not be stricter than the one in
% Dynare (matlab/dynare.m and mex/build/octave/configure.ac)
if isoctave && octave_ver_less_than('5.1.0')
    skipline()
    warning(['This version of dseries has only been tested on Octave 5.1.0 and above. It may fail to run or give unexpected result. Consider upgrading your version of Octave.'])
    skipline()
end

assignin('caller', 'dseries_src_root', dseries_src_root);
