function ds = mdbnomics2dseries(varargin)   % --*-- Unitary tests --*--

% Given cell array from the mdbnomics library, it returns a dseries object.
%
% INPUTS
%
% - If only one arguments are provided, we must have:
%  + varargin{1}  [cell]        A T*N array of data.
%
% OUTPUTS
% - ds [dseries]

% Copyright (C) 2020 Dynare Team
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

switch nargin
    case 0
        % Return empty object.
        error('mdbnomics2dseries:WrongInputArguments', 'Input must be non empty!');
    case 1
        if iscell(varargin{1})
            switch length(varargin{1})
                case 0
                    error('mdbnomics2dseries:WrongInputArguments', 'Input must be non empty!');
                otherwise
                    o.data = varargin{1}(2:end,:);
                    o.cols = varargin{1}(1,:);
                    col_idx = {'x_frequency', 'dataset_code', 'series_code', 'original_period', 'period', 'value'};
                    for ii = 1:size(col_idx,2)
                        o.col_idx.(col_idx{ii}) = find(strcmp(col_idx{ii}, o.cols));
                    end
                    % Check if database has multiple frequencies
                    if size(unique(o.data(:, o.col_idx.x_frequency)),1) > 1
                        error('mdbnomics2dseries:DatabaseCheck: The database, that you are trying to convert, contains multiple frequencies. Currently, this type of dseries conversion is not supported. Please select a section of your database with uniform frequency.');
                    end
                    ds = convert_mdbnomics(o);
            end
        end
    otherwise
        error('mdbnomics2dseries:WrongInputArguments', 'Too many input arguments! Please check the manual.')
end
end

%@test:1
%$ try
%$     dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
%$     df_id = load([dseries_src_root '../tests/data/mdbnomics/df_id.mat']);
%$     df = df_id.df;
%$     ds = mdbnomics2dseries(df);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ds.name, {'EA19_1_0_0_0_ZUTN'});
%$     t(3) = dassert(ds.vobs, 1);
%$     t(4) = dassert(ds.tags.provider_code, {'AMECO'});
%$     t(5:10) = isfield(ds.tags, {'freq', 'unit', 'geo', 'Frequency', 'Unit', 'Country'});
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
%$     df_bi = load([dseries_src_root '../tests/data/mdbnomics/df_bi-annual.mat']);
%$     df = df_bi.df;
%$     ds = mdbnomics2dseries(df);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ds.name, {'S_EUR_AL'});
%$     t(3) = dassert(ds.vobs, 1);
%$     t(4) = dassert(ds.dates.freq, 2);
%$     t(4) = dassert(ds.tags.provider_code, {'Eurostat'});
%$     t(5:10) = isfield(ds.tags, {'FREQ', 'currency', 'geo', 'Frequency', 'Currency', 'Geopolitical_entity__reporting_'});
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ try
%$     dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
%$     df_dataset = load([dseries_src_root '../tests/data/mdbnomics/df_dataset.mat']);
%$     df = df_dataset.df;
%$     ds = mdbnomics2dseries(df);
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ds.vobs, 49);
%$     t(3) = dassert(ds.dates.freq, 1);
%$     t(4) = dassert(length(unique(ds.tags.provider_code)), 1);
%$     t(5) = dassert(size(ds.tags.provider_code,1), 49);
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$     dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
%$     df_multi = load([dseries_src_root '../tests/data/mdbnomics/df_multi-freq.mat']);
%$     df = df_multi.df;
%$     ds = mdbnomics2dseries(df);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:4
