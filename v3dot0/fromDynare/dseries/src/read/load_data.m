function [init, data, varlist, tex, ops, tags] = load_data(filename)

% INPUTS
% - filename     [string]  Name of the file containing data.
%
% OUTPUTS
% - init         [dates]   Initial period.
% - data         [double]  Array of data (T*N).
% - varlist      [cell]    Names of the N variables (as strings).
% - tex          [cell]    TeX names of the N variables.

% Copyright (C) 2017 Dynare Team
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

if ~nargin || ~ischar(filename) || isempty(filename)
    error('dseries:load_data: Input argument cannot be an empty string!')
elseif check_file_extension(filename,'m')
    [~, init, data, varlist, tex, ops, tags] = load_m_file_data(filename);
elseif check_file_extension(filename,'mat')
    [~, init, data, varlist, tex, ops, tags] = load_mat_file_data(filename);
elseif check_file_extension(filename,'csv')
    [~, init, data, varlist] = load_csv_file_data(filename);
    tex = [];
    ops = cell(length(varlist), 1);
    tags = struct();
elseif check_file_extension(filename,'xls') || check_file_extension(filename,'xlsx')
    if isglobalinbase('options_')
        % Check that the object is instantiated within a dynare session so that options_ global structure exists.
        % Should provide latter a mechanism to pass range and sheet to dseries constructor...
        range = evalin('base','options_.xls_range');
        sheet = evalin('base','options_.xls_sheet');
    else
        % By default only the (whole) first sheet is loaded.
        range = [];
        sheet = [];
    end
    [~, init, data, varlist] = load_xls_file_data(filename, sheet, range);
    tex = [];
    ops = cell(length(varlist), 1);
    tags = struct();
elseif check_file_extension(filename,'db')
    % Fame database (need to have matlab-fame-io submodule and TimeIQ installed)
    FameInfo = fame.open.connector();
    db = fame.open.database(FameInfo, filename);
    [data, init, varlist] = fame.getall.timeseries(db);
    fame.close.database(db);
    fame.close.connector(FameInfo);
    tex = [];
    ops = cell(length(varlist), 1);
    tags = struct();
else
    error('dseries:WrongInputArguments', 'I''m not able to load data from %s!', filename);
end

if isempty(tex)
    tex = name2tex(varlist);
end