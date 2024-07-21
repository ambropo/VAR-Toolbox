function series_start_date = get_series_start_date(frequency, original_period)   % --*-- Unitary tests --*--
% Given cell array obtained using from the mdbnomics library,
% it returns a cell array of metadata ot be appended to a dseries object.
%
% INPUTS
% - frequency         [string]         Dataset frequency: monthly, quarterly, bi-annual, annual
% - original_period   [string]         Series original period
%
% OUTPUTS
% - series_start_date [string]

% Copyright (C) 2020 Dynare Team
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

date_ext = regexp(original_period, '\d*', 'Match');
switch frequency
    case 'daily'
        series_start_date = original_period;
    case 'monthly'
        series_start_date = [date_ext{1} 'M' regexprep(date_ext{2},'\<0*','')];
    case 'quarterly'
        series_start_date = [date_ext{1} 'Q' date_ext{2}];
    case {'bi-annual', 'bi-monthly'}
        series_start_date = [date_ext{1} 'H' date_ext{2}];
    case 'annual'
        series_start_date = [original_period 'Y'];
    otherwise
        error('mdbnomics2dseries::get_series_start_date: The frequency of the dataset is currently unsupported!');
end
end

%@test:1
%$ try
%$     str = get_series_start_date('monthly','1997-01');
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(str, '1997M1');
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ try
%$     str = get_series_start_date('quarterly','1938-Q4');
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(str, '1938Q4');
%$ end
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ try
%$     str = get_series_start_date('bi-annual','1997-S2');
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(str, '1997H2');
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$     str = get_series_start_date('annual','1997');
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(str, '1997Y');
%$ end
%$
%$ T = all(t);
%@eof:4

%@test:5
%$ try
%$     str = get_series_start_date('daily','1997-01-01');
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(str, '1997-01-01');
%$ end
%$
%$ T = all(t);
%@eof:5