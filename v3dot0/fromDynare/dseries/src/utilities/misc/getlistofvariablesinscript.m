function list = getlistofvariablesinscript(mscript)

% Returns the list of variables in a script.
%
% INPUTS
% - mscript   [char]   1×n array, name of a matlab script.
%
% OUTPUTS
% - list      [cell]   cell of row char arrays, list of variables defined in mscript.

if ~ischar(mscript)
    error('Input argument must be a row char array (name of a matlab script')
end

if ~exist(mscript, 'file')
    error('Cannot find %s.', mscript)
end

[filepath, filename, ext] = fileparts(mscript);

if ~isequal(ext, '.m')
    error('Wrong extension')
end

run(mscript);

list = whos;
list = {list(:).name};
list = setdiff(list, {'filepath', 'filename', 'ext', 'mscript'});