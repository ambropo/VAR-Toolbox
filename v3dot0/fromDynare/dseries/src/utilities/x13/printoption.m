function printoption(fid, optname, optvalue) % --*-- Unitary tests --*--

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

if ischar(optvalue)
    fprintf(fid, ' %s = %s\n', optname, optvalue);
elseif isreal(optvalue)
    if isequal(numel(optvalue), 1)
        if isint(optvalue)
            fprintf(fid, ' %s = %i\n', optname, optvalue);
        else
            fprintf(fid, ' %s = %f\n', optname, optvalue);
        end
    else
        if isvector(optvalue)
            str = '(';
            for i=1:length(optvalue)
                if isint(optvalue(i))
                    str = sprintf('%s %i', str, optvalue(i));
                elseif isreal(optvalue(i))
                    str = sprintf('%s %f', str, optvalue(i));
                else
                    error('This option value type is not implemented!');
                end
                str = sprintf('%s%s', str, ')');
            end
        else
            error('This option value type is not implemented!');
        end
    end
end

%@test:1
%$ fid = fopen('test.spc', 'w');
%$
%$ try
%$     series = dseries(rand(100,1),'1999M1');
%$     o = x13(series);
%$     o.x11('save','(d11)');
%$     optnames = fieldnames(o.x11);
%$     printoption(fid,'mode',o.x11.mode);
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ T = all(t);
%@eof:1