function tex = name2tex(name, info) % --*-- Unitary tests --*--

% Converts plain text name into tex name.
%
% Builds a random string (starting with a letter).
%
% INPUTS
% - name [string or cell of strings] name(s) to be converted.
% - info [integer] scalar equal to 0 or 1 (adds curly braces for indices).
%
% OUTPUTS
% - tex  [string or cell of strings]

% Copyright (C) 2012-2017 Dynare Team
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

if nargin<2
    info = 0;
end

if info
    if iscell(name)
        nn = length(name);
    else
        nn = 1;
    end
end

tex = regexprep(name, '_', '\\_');

if info
    for i=1:nn
        if iscell(name)
            texname = tex{i};
        else
            texname = tex;
        end
        idx = strfind(texname,'_');
        ndx = length(idx);
        ntx = length(texname);
        if ndx
            gotonextcondition = 1;
            if isequal(ndx,1) && ~isequal(idx,2) && ~isequal(idx,ntx)
                texname = [ texname(1:idx-2) '_{' texname(idx+1:end) '}'];
                gotonextcondition = 0;
            end
            if gotonextcondition && isequal(ndx,2) && ~isequal(idx(1),2) && isequal(idx(2),ntx)
                texname = [ texname(1:idx(1)-2) '_{' texname(idx(1)+1:end) '}' ];
                gotonextcondition = 0;
            end
            if gotonextcondition && isequal(ndx,2) && idx(2)<ntx
                texname = [ texname(1:idx(2)-2) '_{' texname(idx(2)+1:end) '}' ];
                gotonextcondition = 0;
            end
            if gotonextcondition && ndx>2
                if idx(end)<ntx
                    texname = [ texname(1:idx(end)-2) '_{' texname(idx(end)+1:end) '}' ];
                else
                    texname = [ texname(1:idx(end-1)-2) '_{' texname(idx(end-1)+1:end) '}' ];
                end
            end
            if iscell(name)
                tex(i) = { texname };
            else
                tex = texname;
            end
        end
    end
end

%@test:1
%$ t = zeros(16,1);
%$ t1 = name2tex('_azert');
%$ t2 = name2tex('azert_');
%$ t3 = name2tex('_azert_');
%$ t4 = name2tex('azert_uiop');
%$ t5 = name2tex('azert_uiop_qsdfg');
%$ t6 = name2tex('azert_uiop_qsdfg_');
%$ t7 = name2tex('_azert_uiop_qsdfg');
%$ t8 = name2tex('_azert_uiop_qsdfg_');
%$ t11 = name2tex('_azert',1);
%$ t12 = name2tex('azert_',1);
%$ t13 = name2tex('_azert_',1);
%$ t14 = name2tex('azert_uiop',1);
%$ t15 = name2tex('azert_uiop_qsdfg',1);
%$ t16 = name2tex('azert_uiop_qsdfg_',1);
%$ t17 = name2tex('_azert_uiop_qsdfg',1);
%$ t18 = name2tex('_azert_uiop_qsdfg_',1);
%$
%$ t(1) = dassert(strcmp(t1,'\\_azert'),true);
%$ t(2) = dassert(strcmp(t2,'azert\\_'),true);
%$ t(3) = dassert(strcmp(t3,'\\_azert\\_'),true);
%$ t(4) = dassert(strcmp(t4,'azert\\_uiop'),true);
%$ t(5) = dassert(strcmp(t5,'azert\\_uiop\\_qsdfg'),true);
%$ t(6) = dassert(strcmp(t6,'azert\\_uiop\\_qsdfg\\_'),true);
%$ t(7) = dassert(strcmp(t7,'\\_azert\\_uiop\\_qsdfg'),true);
%$ t(8) = dassert(strcmp(t8,'\\_azert\\_uiop\\_qsdfg\\_'),true);
%$ t(9) = dassert(strcmp(t11,'\\_azert'),true);
%$ t(10) = dassert(strcmp(t12,'azert\\_'),true);
%$ t(11) = dassert(strcmp(t13,'\\_azert\\_'),true);
%$ t(12) = dassert(strcmp(t14,'azert_{uiop}'),true);
%$ t(13) = dassert(strcmp(t15,'azert\\_uiop_{qsdfg}'),true);
%$ t(14) = dassert(strcmp(t16,'azert\\_uiop_{qsdfg\\_}'),true);
%$ t(15) = dassert(strcmp(t17,'\\_azert\\_uiop_{qsdfg}'),true);
%$ t(16) = dassert(strcmp(t18,'\\_azert\\_uiop_{qsdfg\\_}'),true);
%$
%$ T = all(t);
%@eof:1

%@test:2
%$ t = zeros(16,1);
%$ t1 = name2tex({'_azert'});
%$ t2 = name2tex({'azert_'});
%$ t3 = name2tex({'_azert_'});
%$ t4 = name2tex({'azert_uiop'});
%$ t5 = name2tex({'azert_uiop_qsdfg'});
%$ t6 = name2tex({'azert_uiop_qsdfg_'});
%$ t7 = name2tex({'_azert_uiop_qsdfg'});
%$ t8 = name2tex({'_azert_uiop_qsdfg_'});
%$ t11 = name2tex({'_azert'},1);
%$ t12 = name2tex({'azert_'},1);
%$ t13 = name2tex({'_azert_'},1);
%$ t14 = name2tex({'azert_uiop'},1);
%$ t15 = name2tex({'azert_uiop_qsdfg'},1);
%$ t16 = name2tex({'azert_uiop_qsdfg_'},1);
%$ t17 = name2tex({'_azert_uiop_qsdfg'},1);
%$ t18 = name2tex({'_azert_uiop_qsdfg_'},1);
%$
%$ t(1) = dassert(t1,{'\\_azert'});
%$ t(2) = dassert(t2,{'azert\\_'});
%$ t(3) = dassert(t3,{'\\_azert\\_'});
%$ t(4) = dassert(t4,{'azert\\_uiop'});
%$ t(5) = dassert(t5,{'azert\\_uiop\\_qsdfg'});
%$ t(6) = dassert(t6,{'azert\\_uiop\\_qsdfg\\_'});
%$ t(7) = dassert(t7,{'\\_azert\\_uiop\\_qsdfg'});
%$ t(8) = dassert(t8,{'\\_azert\\_uiop\\_qsdfg\\_'});
%$ t(9) = dassert(t11,{'\\_azert'});
%$ t(10) = dassert(t12,{'azert\\_'});
%$ t(11) = dassert(t13,{'\\_azert\\_'});
%$ t(12) = dassert(t14,{'azert_{uiop}'});
%$ t(13) = dassert(t15,{'azert\\_uiop_{qsdfg}'});
%$ t(14) = dassert(t16,{'azert\\_uiop_{qsdfg\\_}'});
%$ t(15) = dassert(t17,{'\\_azert\\_uiop_{qsdfg}'});
%$ t(16) = dassert(t18,{'\\_azert\\_uiop_{qsdfg\\_}'});
%$
%$ T = all(t);
%@eof:2

%@test:3
%$ t = zeros(4,1);
%$ try
%$     t1 = name2tex({'_azert';'azert_';'_azert_';'azert_uiop';'azert_uiop_qsdfg';'azert_uiop_qsdfg_'});
%$     t(1) = 1;
%$ catch
%$     % Nothing to do here.
%$ end
%$
%$ if t(1)
%$     try
%$         t2 = name2tex({'_azert';'azert_';'_azert_';'azert_uiop';'azert_uiop_qsdfg';'azert_uiop_qsdfg_'},1);
%$         t(2) = 1;
%$     catch
%$         % Nothing to do here.
%$     end
%$ end
%$
%$ if t(1)
%$     t(3) = dassert(t1,{'\\_azert';'azert\\_';'\\_azert\\_';'azert\\_uiop';'azert\\_uiop\\_qsdfg';'azert\\_uiop\\_qsdfg\\_'});
%$ end
%$
%$ if t(2)
%$     t(4) = dassert(t2,{'\\_azert';'azert\\_';'\\_azert\\_';'azert_{uiop}';'azert\\_uiop_{qsdfg}';'azert\\_uiop_{qsdfg\\_}'});
%$ end
%$
%$ T = all(t);
%@eof:3

%@test:4
%$ try
%$    dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
%$    db = dseries([ dseries_src_root '../tests/data/dd.csv' ]);
%$    t(1) = 1;
%$ catch
%$    t(1) = 0;
%$ end
%$
%$ T = all(t);
%@eof:4
