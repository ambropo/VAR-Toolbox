classdef vspace < handle
    % vspace Class
    %
    % Copyright (C) 2013-2022 Dynare Team
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
    properties (SetAccess = private)
        hline = 0  % Number of horizontal lines to be inserted. Default 0
        number = 1 % Number of new lines to be inserted. Default 1
    end
    methods
        function o = vspace(varargin)
            %function o = vspace(varargin)
            % Vspace Class Constructor
            %
            % INPUTS
            %   varargin        0 args  : empty vspace object
            %                   1 arg   : must be vspace object (return a copy of arg)
            %                   > 1 args: option/value pairs (see structure below for options)
            %
            % OUTPUTS
            %   o     [vspace]  vspace object
            %
            % SPECIAL REQUIREMENTS
            %   none
            if nargin == 0
                return
            elseif nargin == 1
                assert(isa(varargin{1}, 'vspace'), ...
                    '@vspace.vspace: with one arg to Vspace constructor, you must pass a vspace object');
                o = varargin{1};
                return
            end

            if round(nargin/2) ~= nargin/2
                error('@vspace.vspace: options must be supplied in name/value pairs.');
            end

            % Octave 5.1.0 has not implemented `properties` and issues a warning when using `fieldnames`
            if isoctave
                warnstate = warning('off', 'Octave:classdef-to-struct');
            end
            optNames = fieldnames(o);
            if isoctave
                warning(warnstate);
            end

            % overwrite default values
            for pair = reshape(varargin, 2, [])
                ind = find(strcmpi(optNames, pair{1}));
                assert(isempty(ind) || length(ind) == 1);
                if ~isempty(ind)
                    o.(optNames{ind}) = pair{2};
                else
                    error('@vspace.vspace: %s is not a recognized option.', pair{1});
                end
            end

            % Check options provided by user
            assert(isint(o.number), '@vspace.vspace: number must be an integer');
            assert(isint(o.hline), '@vspace.vspace: hline must be an integer');
        end
    end
    methods (Hidden = true)
        % Methods defined in separate files
        write(o, fid);
    end
end
