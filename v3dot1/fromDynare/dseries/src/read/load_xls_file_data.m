function [freq, init, data, varlist] = load_xls_file_data(file, sheet, range)

% Loads data in a xls file.
%
% INPUTS
%  o file       string, name of the file (with extension).
%  o sheet      string, name of the sheet to be read.
%  o range      string of the form 'B2:D6'
%
% OUTPUTS
%  o freq       integer scalar (1, 4, 12 or 52), code for frequency.
%  o init       dates object, initial date of the sample.
%  o data       matrix of doubles, the raw data.
%  o varlist    cell of strings (column), names of the variables in the database.
%
% REMARKS
%  The range argument is only available on windows platform (with Excel installed).

% Copyright (C) 2013-2017 Dynare Team
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

% Set defaults.
if nargin<3 || isempty(range)
    range = '';
    if nargin<2 || isempty(sheet)
        sheet = 1;
        if nargin<1 || isempty(file)
            error('load_xls_file_data:: I need at least one input (name of the xls or xlsx file)!')
        end
    end
end

if isoctave && ~user_has_octave_forge_package('io')
    error(['The io package is required to read CSV files from Octave. ' ...
           'It can be installed by running the following from the Octave ' ...
           ' command line: pkg install -forge io']);
end

% Check file extension.
if ~(check_file_extension(file,'xls') || check_file_extension(file,'xlsx'))
    ext = get_file_extension(file);
    if isempty(ext)
        if exist([file '.xls'],'file')
            file = [file '.xls'];
        elseif exist([file '.xlsx'],'file')
            file = [file '.xlsx'];
        else
            error(['load_xls_file_data:: Unable to find the data file ' file ' with an xls or xlsx extension!'])
        end
    else
        error(['load_xls_file_data:: The data file ' file ' has wrong extension (must be either xls or xlsx)!'])
    end
end

% Check if io package is installed.
if isoctave && ~user_has_octave_forge_package('io')
    error('The io package is required to read XLS/XLSX files from Octave')
end

% Do not support XLS with octave.
if isoctave && isequal(get_file_extension(file), 'xls')
    warning('XLS files not supported with Octave! Please use XLSX instead.')
end

[num,txt,raw] = xlsread(file, sheet, range);

% Get dimensions of num, txt and raw
[n1, n2] = size(num);
[t1, t2] = size(txt);
[r1, r2] = size(raw);

% Check the content of the file.
if isequal(t1,0) && isequal(t2,0)
    % The file contains no informations about the variables and dates.
    notime = 1;
    noname = 1;
elseif isequal(t2,1) && t1>=t2 && n2~=t2  %only one column present, but no var name in header text
                                          % The file contains no informations about the dates.
    notime = 0;
    noname = 1;
elseif isequal(t2,1) && t1>=t2 && n2==t2 %only one column present with var name in header text
                                         % The file contains no informations about the variables.
    notime = 1;
    noname = 0;
elseif isequal(t1,1) && t2>=t1
    % The file contains no informations about the dates.
    notime = 1;
    noname = 0;
else
    % The file contains informations about the variables and dates.
    notime = 0;
    noname = 0;
end

% Output initialization.
freq = 1;
init = dates(1,1);
varlist = [];
data = num;

% Update freq.
if ~notime
    if isempty(txt{1,1})
        first_date = txt{2,1};
    else
        first_date = txt{1,1};
    end
    if isnumeric(first_date) && isint(first_date)
        first_date = [num2str(first_date) 'Y'];
    end
    if isdate(first_date)
        init = dates(first_date);
        freq = init.freq;
    else
        error('load_xls_file_data: I am not able to read the dates!')
    end
end

% Update varlist.
if ~noname
    if notime
        varlist = transpose(txt);
    else
        varlist = transpose(txt(1,2:end));
    end
    % Remove leading and trailing white spaces
    for i=1:length(varlist)
        varlist(i) = {strtrim(varlist{i})};
    end
else
    % set default names
    varlist = cell(n2,1);
    for i=1:n2
        varlist(i) = {['Variable_' int2str(i)]};
    end
end
