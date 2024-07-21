function [freq, init, data, varlist] = load_csv_file_data(file) % --*-- Unitary tests --*--
%function [freq, init, data, varlist] = load_csv_file_data(file)
% Loads data in a csv file.
%
% INPUTS
%  o file        string, name of the csv file (with path).
%
% OUTPUTS
%  o freq        integer scalar equal to 1, 4, 12 or 52 (for annual, quaterly, monthly or weekly frequencies).
%  o init        dates object, initial date in the dataset.
%  o data        matrix of doubles, the data.
%  o varlist     cell of strings, names of the variables.
%
% REMARKS
%  The varlist output will be set only if the first line contains variable
%  names. Similarly, if the first column does not contain dates, then
%  freq will be 1 and init will be year 1.

% Copyright (C) 2012-2017 Dynare Team
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

% Output initialization
freq = 1;                  % Default frequency is annual.
init = dates(1,1);         % Default initial date is year one.
varlist = [];

assert(exist(file, 'file') == 2, ['load_csv_file_data: I can''t find file ' file '!']);

if isoctave
    fid = fopen(file, 'r');
    firstline = fgetl(fid, 4097);
    fclose(fid);
    if length(firstline) < 4097
        if ~user_has_octave_forge_package('io')
            error(['The io package is required to read CSV files from Octave. ' ...
                   'It can be installed by running the following from the Octave ' ...
                   ' command line: pkg install -forge io']);
        end
        A = csv2cell(file);
        [data, T, L] = parsecell(A);
        withvars = L.numlimits(2,1) > L.txtlimits(2,1);
        withtime = L.numlimits(1,1) > L.txtlimits(1,1);
    else
        fid = fopen(file, 'r');
        bfile = fread(fid);
        fclose(fid);

        if isunix || ismac
            newline_code = 10;
        elseif ispc
            newline_code = 13;
        else
            error('load_csv_file_data is not implemented for your OS');
        end

        % Get the positions of the end-of-line code
        end_of_line_locations = find(bfile==newline_code);
        if ispc && isempty(end_of_line_locations)
            newline_code=10;
            end_of_line_locations = find(bfile==newline_code);
        end;
        tmp = find(bfile==newline_code);

        % Get the number of lines in the file
        ndx = length(tmp);

        % Create a cell of indices for each line
        b = [1; end_of_line_locations+1];
        c = [end_of_line_locations-1; length(bfile)+1];
        b = b(1:end-1);
        c = c(1:end-1);
        linea = 1;


        % Test the content of the first elements of the first column
        withtime = 1;
        for r=2:length(b)
            linee = char(transpose(bfile(b(r):c(r))));
            [B,C] = get_cells_id(linee,',');
            if ~isdates(linee(B(1):C(1)))
                break
            end
        end

        % Test the content of the first line
        linee = char(transpose(bfile(b(1):c(1))));
        [B,C] = get_cells_id(linee,',');
        withnames = isvarname(linee(B(2):C(2)));

        if withnames
            % Get the first line of the csv file (names of the variables).
            linee = char(transpose(bfile(b(linea):c(linea))));
            % Get the content of the first line and determine the number of variables and their names.
            [B,C] = get_cells_id(linee,',');
            if withtime
                B = B(2:end);
                C = C(2:end);
            end
            varlist = cell(length(B),1);
            number_of_variables = length(varlist);
            for i=1:number_of_variables
                varlist(i) = {linee(B(i):C(i))};
            end
            varlist = strtrim(varlist);
            linea = linea+1;
            % Remove double quotes if any
            varlist = strrep(varlist,'"','');
        end

        % Get following line (number 1 or 2 depending on withnames flag)
        linee = char(transpose(bfile(b(linea):c(linea))));
        comma_locations = transpose(strfind(linee,','));
        B = 1;
        C = comma_locations(1)-1;
        if withtime
            tmp = linee(B:C);
            % Check the dates formatting
            if isnumeric(tmp) && isint(tmp)
                tmp = [num2str(tmp) 'Y'];
            end
            if ~isdate(tmp)
                error('load_csv_file_data:: Formatting error. I can''t read the dates!')
            end
            init = dates(tmp);
            freq = init.freq;
            first = 2;
        else
            first = 1;
        end

        if ~withnames
            number_of_variables = length(tmp)-withtime;
        end

        % Initialization of matrix data.
        data = zeros(ndx,number_of_variables);

        % Populate data.
        for linea = 1+withnames:ndx
            linee = char(transpose(bfile(b(linea):c(linea))));
            [B,C] = get_cells_id(linee,',');
            for i=first:length(B)
                data(linea,i-withtime) = str2double(linee(B(i):C(i)));
            end
        end

        % Remove first line if withnames
        data = data(1+withnames:ndx, :);
        return
    end
else
    A = importdata(file, ',');
    if ~isstruct(A)
        data = A;
        T = {};
        withvars = 0;
        withtime = 0;
    else
        data = A.data;
        T = A.textdata;
        % importdata() allows text only at the top and the left, so the following
        %  tests are sufficient.
        withvars = size(T, 2) >= size(data, 2);
        withtime = size(T, 1) >= size(data, 1);
    end
end

if withvars
    varlist = T(1, 1+withtime:end);
    T = T(2:end, :);
end
if withtime
    init = dates(T{1, 1});
    freq = init.freq;
end

varlist = transpose(varlist);

% Remove double quotes if any
varlist = strrep(varlist,'"','');

%@test:1
%$ % Download csv file with data.
%$ dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
%$
%$ % Instantiate a dseries from the data in the csv file.
%$ try
%$   d = dseries([ dseries_src_root '../tests/data/data_ca1_csv.csv' ]);
%$   t(1) = true;
%$ catch
%$   t(1) = false;
%$ end
%$
%$ if t(1)
%$   t(2) = dassert(d.name,{'y_obs'; 'pie_obs'; 'R_obs'; 'de'; 'dq'});
%$ end
%$
%$ T = all(t);
%@eof:1
