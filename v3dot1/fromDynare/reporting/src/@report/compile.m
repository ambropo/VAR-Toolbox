function o = compile(o, varargin)
%function o = compile(o)
% Compile Report Object
%
% INPUTS
%   o            [report]  report object
%   varargin     [char]    allows user to change report compiler for a
%                          given run of compile.
%
% OUTPUTS
%   o     [report]  report object
%
% SPECIAL REQUIREMENTS
%   none

% Copyright (C) 2013-2019 Dynare Team
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

opts.compiler = o.compiler;
opts.showReport = true;
opts.showOutput = o.showOutput;

if nargin > 1
    if round((nargin-1)/2) ~= (nargin-1)/2
        error('@report.compile: options must be supplied in name/value pairs');
    end

    optNames = fieldnames(opts);

    % overwrite default values
    for pair = reshape(varargin, 2, [])
        ind = find(strcmpi(optNames, pair{1}));
        assert(isempty(ind) || length(ind) == 1);
        if ~isempty(ind)
            opts.(optNames{ind}) = pair{2};
        else
            error('@report.compile: %s is not a recognized option.', pair{1});
        end
    end
end

assert(ischar(opts.compiler), '@report.compile: compiler file must be a string');
assert(islogical(opts.showReport), '@report.compile: showReport must be either true or false');
assert(islogical(opts.showOutput), '@report.compile: showOutput must be either true or false');

if exist([o.directory '/' o.fileName], 'file') ~= 2
    o.write();
end

middle = ' ./';
if isempty(opts.compiler)
    status = 1;
    if ismac
        % Add most likely places for pdflatex to exist outside of default $PATH
        [status, opts.compiler] = ...
            system('PATH=$PATH:/usr/texbin:/usr/local/bin:/usr/local/sbin:/Library/TeX/texbin;which pdflatex');
    elseif ispc
        [status, opts.compiler] = system('findtexmf --file-type=exe pdflatex');
        if status == 1
            [status] = system('pdflatex.exe --version');
            if status == 0
                opts.compiler = 'pdflatex.exe';
            end
        end
        middle = ' ';
        opts.compiler = ['"' strtrim(opts.compiler) '"'];
    elseif isunix
        % “which” has been deprecated in Debian Bookworm; rather use “command -v”
        % which should work with any reasonably recent GNU/Linux shell
        [status, opts.compiler] = system('command -v pdflatex');
    end
    assert(status == 0, ...
           '@report.compile: Could not find a tex compiler on your system');
    opts.compiler = strtrim(opts.compiler);
    o.compiler = opts.compiler;
    if opts.showOutput
        disp(['Using compiler: ' o.compiler]);
    end
end

orig_dir = pwd;
cd(o.directory)
options = '-synctex=1 -halt-on-error';
[~, rfn] = fileparts(o.fileName);
if ~isempty(o.maketoc)
    % TOC compilation requires two passes
    compile_tex(o, orig_dir, opts, [options ' -draftmode'], middle, rfn);
end
if status ~= 0
    cd(orig_dir)
    error(['@report.compile: There was an error in compiling ' rfn '.pdf.' ...
           '  ' opts.compiler ' returned the error code: ' num2str(status)]);
end
compile_tex(o, orig_dir, opts, options, middle, rfn);

if o.showOutput || opts.showOutput
    fprintf('Done.\n\nYour compiled report is located here:\n  %s.pdf\n\n\n', [pwd '/' rfn])
end
if opts.showReport && ~isoctave
    open([rfn '.pdf']);
end
cd(orig_dir)
end

function compile_tex(o, orig_dir, opts, options, middle, rfn)
if opts.showOutput
    if isoctave
        system([opts.compiler ' ' options middle o.fileName]);
        status = 0;
    else
        status = system([opts.compiler ' ' options middle o.fileName], '-echo');
    end
else
    status = system([opts.compiler ' -interaction=batchmode ' options middle o.fileName]);
end

if status ~= 0
    cd(orig_dir)
    error(['@report.compile: There was an error in compiling ' rfn '.pdf.' ...
        '  ' opts.compiler ' returned the error code: ' num2str(status)]);
end
end
