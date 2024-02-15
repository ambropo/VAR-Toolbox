function ds = convert_mdbnomics(o)

% INPUTS
% - o         [struct]         Struct with fields: data, cols, col_idx
%
% OUTPUTS
% - ds        [dseries]

% Copyright (C) 2020-2021 Dynare Team
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare dates submodule is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if ~isstruct(o)
    error('mdbnomics2dseries::convert_mdbnomics: The input argument must be a struct!');
end

% Initialize dseries
ds = dseries();

% Check for multiple datasets
if isoctave && octave_ver_less_than('6')
    dataset_codes = unique(o.data(:,o.col_idx.dataset_code));
else
    dataset_codes = unique(o.data(:,o.col_idx.dataset_code),'stable');
end

% Convert mdbnomics to dseries
for ii = 1:length(dataset_codes)
    % Slice data for dataset
    ds_dataset = o.data(strcmp(o.data(:,o.col_idx.dataset_code),dataset_codes{ii}),:);
    if isoctave && octave_ver_less_than('6')
        series_codes = unique(ds_dataset(:,o.col_idx.series_code));
    else
        series_codes = unique(ds_dataset(:,o.col_idx.series_code),'stable');
    end
    % Get list of variable names
    list_of_names = cellfun(@(x)regexprep(x, '[^a-zA-Z0-9]', '_'), series_codes, 'UniformOutput', false);
    % Get dataset values
    ds_dataset_values = cell2mat(ds_dataset(:,o.col_idx.value));
    % Get length of series
    series_length = cell2mat(cellfun(@(x)length(find(strcmp(x, ds_dataset(:,o.col_idx.series_code)))), series_codes, 'UniformOutput', false));
    % Get starting value indices
    dataset_start_val = cumsum([1, series_length(1:end-1)']);

    % Check if dataset starting date is uniform
    starting_dates = o.data(dataset_start_val, o.col_idx.original_period);
    freq = ds_dataset{1,o.col_idx.x_frequency};
    if length(unique(starting_dates)) > 1
        % Build dseries object by series
        dataset = dseries();
        for s = 1:length(starting_dates)
            % Get dseries date format from dataset
            dseries_date = get_series_start_date(freq, starting_dates{s});
            % Transform dataset into dseries
            data_series = ds_dataset_values(dataset_start_val(s):dataset_start_val(s)+series_length(s)-1);
            series = dseries(data_series, dseries_date, list_of_names{s});
            dataset = [dataset series];
        end
    else
        % Pad values with NaN when series length in the same dataset is unequal
        if size(series_length, 1) > 1 && length(unique(series_length)) > 1
            val_ = mat2cell(ds_dataset_values, series_length');
            ds_dataset_values = cell2mat(cellfun(@(x)cat(1, x, nan(max(series_length)-length(x),1)), val_, 'UniformOutput', false));
        end

        % Reshape dseries input data
        data_dataset = reshape(ds_dataset_values, max(series_length), size(series_codes, 1));

        % Get dseries date format from dataset
        starting_date = min(datenum(ds_dataset(:,o.col_idx.period)));
        original_period = ds_dataset(strcmp(ds_dataset(:,o.col_idx.period),datestr(starting_date, 'yyyy-mm-dd')),o.col_idx.original_period);
        dseries_date = get_series_start_date(freq, original_period{1});
        % Transform dataset into dseries
        dataset = dseries(data_dataset, dseries_date, list_of_names);
    end
    % Append initial dseries object
    ds = [ds dataset];
end

% Add tags to the variables
if length(dataset_codes) > 1
    if isoctave && octave_ver_less_than('6')
        series_codes = unique(o.data(:,o.col_idx.series_code));
    else
        series_codes = unique(o.data(:,o.col_idx.series_code),'stable');
    end
    list_of_names = cellfun(@(x)regexprep(x, '[^a-zA-Z0-9]', '_'), series_codes, 'UniformOutput', false);
    series_length = cell2mat(cellfun(@(x)length(find(strcmp(x, o.data(:,o.col_idx.series_code)))), series_codes, 'UniformOutput', false));
end

% Select relevant column indices (ignore columns: 'original_period', 'period', 'original_value', 'value')
col_idx = [1:6,11:size(o.data,2)];
tag_names = cellfun(@(x)regexprep(x, '[^a-zA-Z0-9]','_'), o.cols(col_idx), 'UniformOutput', false);
data_start_val = cumsum([1, series_length(1:end-1)']);
tag_data = o.data(data_start_val,col_idx);

for ii = 1:length(tag_names)
    tag(ds, tag_names{ii});
    for jj = 1:length(list_of_names)
        tag(ds, tag_names{ii}, list_of_names{jj}, tag_data{jj,ii});
    end
end
end
