function o = tex_rename_(o, varargin) % --*-- Unitary tests --*--

% Changes TeX name of variables in a dseries object.
%
% INPUTS
% - o           [dseries]
% - names_1     [string, cell]
% - names_2     [string]
%
% OUTPUTS
% - o     [dseries]
%
% REMARKS
% If varargin has only one element (string or cell of strings) then this input defines the new
% texnames for all the variables in dseries object o. If varargin has two elements (strings) the
% first element is the name of the variable and the second argument is the new texname for this
% variable.

% Copyright (C) 2013-2021 Dynare Team
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

assert(nargin <= 3, 'dseries::tex_rename: accepts at most three args');

if nargin == 2
    newtexname = varargin{1};
    assert(vobs(o) == 1 || vobs(o) == length(newtexname), ...
           'dseries::tex_rename: with one argument, the dseries contain only one variable.');
else
    newtexname = varargin{2};
    name = varargin{1};
    assert(ischar(name), 'dseries::tex_rename: second input argument (name) must be a string');
end

assert(ischar(newtexname) || (iscellstr(newtexname) && length(newtexname) == vobs(o)), ...
       ['dseries::tex_rename: third input argument (newtexname) name must either be a string' ...
        ' or a cell array of strings with the same number of entries as varibles in the dseries']);

if nargin == 2
    idname = 1;
else
    idname = find(strcmp(name, o.name));
    if isempty(idname)
        error(['dseries::tex_rename: Variable ' name ' is unknown in dseries object ' inputname(1)  '!'])
    end
end

if iscellstr(newtexname)
    o.tex = newtexname(:);
else
    o.tex(idname) = {newtexname};
end

%@test:1
%$ ts = dseries([transpose(1:5), transpose(6:10)],'1950q1',{'Output'; 'Consumption'}, {'Y_t'; 'C_t'});
%$ try
%$     ts.tex_rename_('Output','\\Delta Y_t');
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.freq,4);
%$     t(3) = dassert(ts.init.freq,4);
%$     t(4) = dassert(ts.init.time,1950*4+1);
%$     t(5) = dassert(ts.vobs,2);
%$     t(6) = dassert(ts.nobs,5);
%$     t(7) = dassert(ts.name,{'Output'; 'Consumption'});
%$     t(8) = dassert(ts.tex,{'\\Delta Y_t'; 'C_t'});
%$ end
%$
%$ T = all(t);
%@eof:1

%@test:3
%$ ts = dseries(rand(3,3));
%$ try
%$     ts.tex_rename_({'Output','\\Delta Y_t','\\theta_{-1}'});
%$     t(1) = 1;
%$ catch
%$     t(1) = 0;
%$ end
%$
%$ if t(1)
%$     t(2) = dassert(ts.tex,{'Output';'\\Delta Y_t';'\\theta_{-1}'});
%$ end
%$
%$ T = all(t);
%@eof:3