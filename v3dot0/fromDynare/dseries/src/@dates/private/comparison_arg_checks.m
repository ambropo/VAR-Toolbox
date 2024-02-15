function [o, p] = comparison_arg_checks(varargin) % --*-- Unitary tests --*--

% Returns two dates objects or an error if objects to be compared are not compatible.
%
% INPUTS
% - varargin
%
% OUTPUTS
% - o [dates] dates object with n or 1 elements.
% - p [dates] dates object with n or 1 elements.

% Copyright (C) 2014-2019 Dynare Team
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

if ~isequal(nargin,2)
    s = dbstack;
    error(sprintf('dates:%s:ArgCheck',s(2).name),'I need exactly two input arguments!')
end

if ~isa(varargin{1},'dates') || ~isa(varargin{2},'dates')
    s = dbstack;
    error(sprintf('dates:%s:ArgCheck',s(2).name),'Input arguments have to be dates objects!')
end

if ~isequal(varargin{1}.freq,varargin{2}.freq)
    s = dbstack;
    error(sprintf('dates:%s:ArgCheck',s(2).name),'Input arguments must have common frequency!')
end

if ~isequal(varargin{1}.ndat, varargin{2}.ndat) && ~(isequal(varargin{1}.ndat,1) || isequal(varargin{2}.ndat,1))
    s = dbstack;
    if ~isequal(s(2).name, 'eq')
        error(sprintf('dates:%s:ArgCheck',s(2).name),'Dimensions are not consistent!')
    end
end

o = varargin{1};
p = varargin{2};

%@test:1
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     [o, p] = comparison_arg_checks(1);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:1

%@test:2
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     [o, p] = comparison_arg_checks('make', 'my', 'day');
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:2

%@test:3
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     [o, p] = comparison_arg_checks('punk', dates('1950Q1'));
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:3

%@test:4
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     [o, p] = comparison_arg_checks(dates('1950Q1'), 1);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:4

%@test:5
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     [o, p] = comparison_arg_checks(dates('1950Q1'), dates('1950M1'));
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:5

%@test:6
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     [o, p] = comparison_arg_checks(dates('1950Q1'):dates('1950Q2'), dates('1950Q1'):dates('1950Q3'));
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:6

%@test:7
%$ OPATH = pwd();
%$ DSERIES_PATH = strrep(which('initialize_dseries_class'),'/initialize_dseries_class.m','');
%$ cd([DSERIES_PATH '/@dates/private']);
%$
%$ try
%$     [o, p] = comparison_arg_checks(dates('1950Q2'), dates('1950Q1'));
%$     t(1) = true;
%$ catch
%$     t(1) = false;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(o, dates('1950Q2'));
%$     t(3) = dassert(p, dates('1950Q1'));
%$ end
%$
%$ T = all(t);
%$ cd(OPATH);
%@eof:7