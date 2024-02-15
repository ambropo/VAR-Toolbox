function o = subsref(o, S) % --*-- Unitary tests --*--

% Overloads the subsref method.

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

switch S(1).type
  case '.'
    switch S(1).subs
      case {'x','y'}
        if isequal(length(S), 1)
            o = builtin('subsref', o, S(1));
        else
            if isequal(S(2).type,'.')
                o = builtin('subsref', o.(S(1).subs), S(2));
            end
        end
      case {'commands'}
        o = builtin('subsref', o, S(1));
      case {'arima','automdl','regression','transform','outlier', 'forecast', 'check', 'x11', 'estimate','composite',...
            'force','history','metadata','identify','pickmdl','seats','slidingspans','spectrum','x11regression'}
        if isequal(length(S), 1)
            o = builtin('subsref', o, S(1));
        else
            if isequal(S(2).type,'()')
                if ~ismember(S(1).subs, o.commands)
                    checkcommandcompatibility(o, S(1).subs);
                    o.commands(end+1) = {S(1).subs};
                end
                if isempty(S(2).subs)
                    % Reset the member to its default (empty).
                    o.(S(1).subs) = setdefaultmember(S(1).subs);
                else
                    % Set options.
                    if mod(length(S(2).subs), 2)
                        error('x13:%s: Wrong calling sequence, number of input arguments has to be even!', S(1).subs)
                    end
                    for i=1:2:length(S(2).subs)
                        if isoption(S(1).subs, S(2).subs{i})
                            o.(S(1).subs) = setoption(o.(S(1).subs), S(2).subs{i}, S(2).subs{i+1});
                            checkoptioncompatibility(o);
                        else
                            fprintf('Option %s is not available in block %s!', S(2).subs{i}, S(1).subs);
                        end
                    end
                end
            elseif isequal(S(2).type,'.')
                o = builtin('subsref', o.(S(1).subs), S(2));
            else
                error('x13:%s: Wrong calling sequence!', S(1).subs)
            end
        end
      case {'print', 'run', 'clean'}
        if isequal(length(S), 1)
            feval(S(1).subs, o);
        elseif isequal(length(S), 2)
            if isequal(S(2).type,'()')
                if isempty(S(2).subs)
                    feval(S(1).subs, o);
                else
                    feval(S(1).subs, o, S(2).subs{:});
                end
            else
                error('x13:: Wrong calling sequence!')
            end
        else
            error('x13:: I expect no more than two input arguments!')
        end
      case 'results'
        % Returns a structure with all the results.
        if isequal(length(S), 1)
            o = builtin('subsref', o, S(1));
        else
            if isequal(S(2).type,'.')
                o = builtin('subsref', o.(S(1).subs), S(2));
            end
        end
      otherwise
        error('x13:: I do not understand what you are asking for!')
    end
  otherwise
    error('x13:: I do not understand what you are asking for!')
end

%@test:1
%$ t = zeros(4,1);
%$ o = x13();
%$
%$ try
%$     o.unicorn;
%$     t(1) = false;
%$ catch
%$     t(1) = true;
%$ end
%$
%$ try
%$    o.x11('onearg','onevalue','twoargs');
%$    t(2) = false;
%$ catch
%$     t(2) = true;
%$ end
%$
%$ try
%$     addpath(sprintf('%s/tests/fake', dseries_src_root))
%$     o.x11('unicorn','yes please');
%$     o.x11.unicorn;
%$     rmpath(sprintf('%s/tests/fake', dseries_src_root))
%$     t(3) = false;
%$ catch
%$     t(3) = true;
%$ end
%$
%$ try
%$     o.print.unicorn;
%$     t(4) = false;
%$ catch
%$     t(4) = true;
%$ end
%$
%$ T = all(t);
%@eof:1