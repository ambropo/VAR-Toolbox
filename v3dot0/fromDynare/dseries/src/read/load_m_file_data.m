function [freq, init, data, varlist, tex, ops, tags] = load_m_file_data(file) % --*-- Unitary tests --*--

% Loads data in a matlab/octave script.
%
% INPUTS
%  o file         string, name of the matlab/octave script (with path)
%
% OUTPUTS
%  o freq        integer scalar equal to 1, 4, 12 or 52 (for annual, quaterly, monthly or weekly frequencies).
%  o init        dates object, initial date in the dataset.
%  o data        matrix of doubles, the data.
%  o varlist     cell of strings, names of the variables.
%
% REMARKS
% The frequency and initial date can be specified with variables FREQ__ and INIT__ in the matlab/octave script. FREQ__ must
% be a scalar integer and INIT__ a string like '1938M11', '1945Q3', '1973W3' or '2009A'. If these variables are not specified
% default values for freq and init are 1 and dates(1,1).

% Copyright (C) 2012-2021 Dynare Team
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

if isoctave
    run(file);
else
    basename = file(1:end-2);
    run(basename);
end

clear file basename;
if isoctave
    clear argn;
end

% store variables to structure, workaround for https://git.dynare.org/Dynare/dseries/-/merge_requests/40
fields=[who].';

assigns= cellfun(@(f) ['tmp__dataSet__struct.' f '=' f ';'],fields,'uniformoutput',0);
for line_iter=1:length(assigns)
    eval(assigns{line_iter});
end

[freq, init, data, varlist, tex, ops, tags] = load_mat_file_data(tmp__dataSet__struct);

return

%@test:1
 % Create a data m-file
 datafile = [tempname '.m'];
 fid = fopen(datafile,'w');
 fprintf(fid,'FREQ__ = 4;');
 fprintf(fid,'INIT__ = ''1938Q4'';');
 fprintf(fid,'NAMES__ = {''azert'';''yuiop''};');
 fprintf(fid,'TEX__ = {''azert'';''yuiop''};');
 fprintf(fid,'OPS__ = {''method1(azert)'';''method2(yuiop)''};');
 fprintf(fid,'TAGS__ = struct();');
 fprintf(fid,'TAGS__.type = cell(2, 1);');
 fprintf(fid,'TAGS__.type(1) = {''Haut''};');
 fprintf(fid,'TAGS__.type(2) = {''Bas''};');
 fprintf(fid,'azert = [1; 2; 3; 4; 5];');
 fprintf(fid,'yuiop = [2; 3; 4; 5; 6];');
 fclose(fid);

 % Try to read the data m-file
 try
     [freq, init, data, varlist, tex, ops, tags] = load_m_file_data(datafile);
     delete(datafile);
     t(1) = 1;
 catch exception
     t(1) = 0;
     T = all(t);
     LOG = getReport(exception,'extended');
     return
 end

 % Check the results.
 t(2) = dassert(freq,4);
 t(3) = isdates(init);
 t(4) = dassert(init.freq,4);
 t(5) = dassert(init.time,1938*4+4);
 t(6) = dassert(varlist,{'azert';'yuiop'});
 t(7) = dassert(tex,{'azert';'yuiop'});
 t(8) = dassert(ops,{'method1(azert)';'method2(yuiop)'});
 t(9) = dassert(tags.type,{'Haut';'Bas'});
 t(10) = dassert(data(:,1),[1;2;3;4;5]);
 t(11) = dassert(data(:,2),[2;3;4;5;6]);
 T = all(t);
%@eof:1
