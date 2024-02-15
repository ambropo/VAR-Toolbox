function r = subsref(o, S) % --*-- Unitary tests --*--

% Overloads the subsref method for dseries class.
%
% INPUTS
% - o    [dseries]    Time series object instantiated by dseries.
% - S    [struct]     Matlab's structure array S with two fields, type and subs. The type field is
%                     a string containing '()', '{}', or '.', where '()' specifies integer
%                     subscripts, '{}' specifies cell array subscripts, and '.' specifies
%                     subscripted structure fields. The subs field is a cell array or a string
%                     containing the actual subscripts (see matlab's documentation).
%
% OUTPUTS
% - r    [dseries]    Depending on the calling sequence `r` is a transformation of `o` obtained
%                     by applying a public method on `o`, or a dseries object built by extracting
%                     a variable from `o`, or a dseries object containing a subsample.

% Copyright (C) 2011-2022 Dynare Team
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

switch S(1).type
  case '.'
    switch S(1).subs
      case {'data','name','tex','dates','ops', 'tags'}        % Public members.
        if length(S)>1 && isequal(S(2).type,'()') && isempty(S(2).subs)
            error(['dseries::subsref: ' S(1).subs ' is not a method but a member!'])
        end
        r = builtin('subsref', o, S(1));
      case 'nobs'
        % Returns the number of observations.
        r = rows(o.data);
      case 'vobs'
        % Returns the number of variables.
        r = columns(o.data);
      case 'init'
        % Returns a dates object (first date).
        r = o.dates(1);
      case 'last'
        % Returns a dates object (last date).
        r = o.dates(end);
      case 'freq'
        % Returns an integer characterizing the data frequency (1, 2, 4, 12, 52 or 365)
        r = o.dates.freq;
      case 'length'
        error(['dseries::subsref: we do not support the length operator on ' ...
               'dseries. Please use ''nobs'' or ''vobs''']);
      case 'save'
        % Save dseries object on disk (default is a mat file).
        r = NaN;
        if isequal(length(S),2)
            if strcmp(S(2).type,'()')
                if isempty(S(2).subs)
                    save(o);
                else
                    if isempty(S(2).subs{1})
                        save(o,'',S(2).subs{2});
                    else
                        save(o,S(2).subs{:});
                    end
                end
                S = shiftS(S,1);
            else
                error('dseries::subsref: Wrong syntax.')
            end
        elseif isequal(length(S),1)
            save(o);
        else
            error('dseries::subsref: Call to save method must come in last position!')
        end
      case 'struct'
        r = dseries2struct(o);
      case 'initialize'
        r = NaN;
        initialize(o);
      case {'baxter_king_filter', 'baxter_king_filter_', ...
            'cumsum','cumsum_', ...
            'insert', ...
            'pop','pop_', ...
            'cumprod','cumprod_', ...
            'remove','remove_', ...
            'onesidedhptrend','onesidedhptrend_', ...
            'onesidedhpcycle','onesidedhpcycle_', ...
            'lag','lag_', ...
            'lead','lead_', ...
            'hptrend','hptrend_', ...
            'hpcycle','hpcycle_', ...
            'chain','chain_', ...
            'backcast','backcast_', ...
            'detrend','detrend_', ...
            'exist', ...
            'mean', ...
            'nanmean', ...
            'std', ...
            'nanstd', ...
            'center','center_', ...
            'log','log_', ...
            'exp','exp_', ...
            'ygrowth','ygrowth_', ...
            'hgrowth','hgrowth_', ...
            'qgrowth','qgrowth_', ...
            'mgrowth','mgrowth_', ...
            'dgrowth','dgrowth_', ...
            'ydiff','ydiff_', ...
            'hdiff','hdiff_', ...
            'qdiff','qdiff_', ...
            'diff', 'diff_', ...
            'mdiff','mdiff_', ...
            'abs','abs_', ...
            'flip','flip_', ...
            'isnan', ...
            'isinf', ...
            'isreal', ...
            'round', 'round_', ...
            'firstdate', ...
            'lastdate', ...
            'firstobservedperiod', ...
            'lastobservedperiod', ...
            'lineartrend', ...
            'resetops', 'resettags', ...
            'subsample', ...
            'projection', ...
            'timeaggregation'}
        if length(S)>1 && isequal(S(2).type,'()')
            if isempty(S(2).subs)
                r = feval(S(1).subs,o);
                S = shiftS(S,1);
            else
                r = feval(S(1).subs,o,S(2).subs{:});
                S = shiftS(S,1);
            end
        else
            r = feval(S(1).subs,o);
        end
      case 'size'
        if isequal(length(S),2) && strcmp(S(2).type,'()')
            if isempty(S(2).subs)
                [x,y] = size(o);
                r = [x, y];
            else
                r = size(o,S(2).subs{1});
            end
            S = shiftS(S,1);
        elseif isequal(length(S),1)
            [x,y] = size(o);
            r = [x, y];
        else
            error('dseries::subsref: Call to size method must come in last position!')
        end
      case {'set_names','rename','rename_','tex_rename','tex_rename_', 'tag'}
        r = feval(S(1).subs,o,S(2).subs{:});
        S = shiftS(S,1);
      case {'disp'}
        feval(S(1).subs,o);
        return
      otherwise                                                            % Extract a sub-object by selecting one variable.
        ndx = find(strcmp(S(1).subs,o.name));
        if ~isempty(ndx)
            r = dseries();
            r.data = o.data(:,ndx);
            r.name = o.name(ndx);
            r.tex = o.tex(ndx);
            r.dates = o.dates;
            r.ops = o.ops(ndx);
            tagnames = fieldnames(o.tags);
            for i=1:length(tagnames)
                r.tags.(tagnames{i}) = o.tags.(tagnames{i})(ndx);
            end
        else
            error('dseries::subsref: Unknown public method, public member or variable!')
        end
    end
  case '()'
    if ischar(S(1).subs{1}) && ~isdate(S(1).subs{1})
        % If ts is an empty dseries object, populate this object by reading data in a file.
        if isempty(o)
            if exist(S(1).subs{1}, 'file')
                r = dseries(S(1).subs{1});
            else
                error('dseries::subsref: Cannot find file %s', S(1).subs{1})
            end
        else
            error('dseries::subsref: dseries object is not empty!')
        end
    elseif isscalar(S(1).subs{1}) && isint(S(1).subs{1})
        % Input is also interpreted as a backward/forward operator
        if S(1).subs{1}>0
            r = lead(o, S(1).subs{1});
        elseif S(1).subs{1}<0
            r = lag(o, -S(1).subs{1});
        else
            % Do nothing.
            r = o;
        end
    elseif isdates(S(1).subs{1}) || isdate(S(1).subs{1})
        % Select observation(s) with date(s)
        if isdate(S(1).subs{1})
            Dates = dates(S(1).subs{1});
        else
            Dates = S(1).subs{1};
        end
        % Test if Dates is out of bounds
        if min(Dates)<min(o.dates)
            error(['dseries::subsref: Indices are out of bounds! Subsample cannot start before ' date2string(o.dates(1)) '.'])
        end
        if  max(Dates)>max(o.dates)
            error(['dseries::subsref: Indices are out of bounds! Subsample cannot end after ' date2string(o.dates(end)) '.'])
        end
        % Extract a subsample using a dates object
        if o.dates.freq==365
            [~,tdx] = intersect(o.dates.time(:,1),Dates.time(:,1));
        else
            [~,tdx] = intersect(o.dates.time,Dates.time,'rows');
        end
        r = copy(o);
        r.data = r.data(tdx,:);
        r.dates = r.dates(tdx);
    elseif isnumeric(S(1).subs{1}) && isequal(ndims(S(1).subs{1}), 2)
        if isempty(o)
            % Populate an empty dseries object.
            if isempty(o.dates)
                r = copy(o);
                r.dates = dates('1Y'):dates('1Y')+(rows(S(1).subs{1})-1);
                r.data = S(1).subs{1};
                r.name = default_name(columns(r.data));
                r.tex = name2tex(r.name);
                r.ops = cell(length(r.name), 1);
            else
                r = copy(o);
                r.dates = r.dates:r.dates+(rows(S(1).subs{1})-1);
                r.data = S(1).subs{1};
                r.name = default_name(columns(r.data));
                r.tex = name2tex(r.name);
                r.ops = cell(length(r.name), 1);
            end
        else
            error('dseries::subsref: It is not possible to populate a non empty dseries object!');
        end
    else
        error('dseries::subsref: I have no idea of what you are trying to do!')
    end
  case '{}'
    if iscellofchar(S(1).subs)
        r = extract(o,S(1).subs{:});
    elseif isequal(length(S(1).subs),1) && all(isint(S(1).subs{1}))
        idx = S(1).subs{1};
        if max(idx)>size(o.data,2) || min(idx)<1
            error('dseries::subsref: Indices are out of bounds!')
        end
        r = dseries();
        r.data = o.data(:,idx);
        r.name = o.name(idx);
        r.tex  = o.tex(idx);
        r.dates = o.dates;
        r.ops = o.ops(idx);
        tagnames = fieldnames(o.tags);
        for i=1:length(tagnames)
            r.tags.(tagnames{i}) = o.tags.(tagnames{i})(idx);
        end
    else
        error('dseries::subsref: What the Hell are you tryin'' to do?!')
    end
  otherwise
    error('dseries::subsref: What the Hell are you doin'' here?!')
end

S = shiftS(S,1);
if ~isempty(S)
    r = subsref(r, S);
end

return

%@test:1
 % Define a data set.
 A = [transpose(1:10),2*transpose(1:10)];

 % Define names
 A_name = {'A1';'A2'};

 % Instantiate a time series object.
 ts1 = dseries(A,[],A_name,[]);

 % Call the tested method.
 a = ts1(ts1.dates(2:9));

 % Expected results.
 e.data = [transpose(2:9),2*transpose(2:9)];
 e.nobs = 8;
 e.vobs = 2;
 e.name = {'A1';'A2'};
 e.freq = 1;
 e.init = dates(1,2);

 % Check the results.
 t(1) = dassert(a.data,e.data);
 t(2) = dassert(a.nobs,e.nobs);
 t(3) = dassert(a.vobs,e.vobs);
 t(4) = dassert(a.freq,e.freq);
 t(5) = dassert(a.init,e.init);
 T = all(t);
%@eof:1

%@test:2
 % Define a data set.
 A = [transpose(1:10),2*transpose(1:10)];

 % Define names
 A_name = {'A1';'A2'};

 % Instantiate a time series object.
 ts1 = dseries(A,[],A_name,[]);

 % Call the tested method.
 a = ts1.A1;

 % Expected results.
 e.data = transpose(1:10);
 e.nobs = 10;
 e.vobs = 1;
 e.name = {'A1'};
 e.freq = 1;
 e.init = dates(1,1);

 % Check the results.
 t(1) = dassert(a.data,e.data);
 t(2) = dassert(a.init,e.init);
 t(3) = dassert(a.nobs,e.nobs);
 t(4) = dassert(a.vobs,e.vobs);
 t(5) = dassert(a.freq,e.freq);
 T = all(t);
%@eof:2

%@test:3
 % Define a data set.
 A = [transpose(1:10),2*transpose(1:10)];

 % Define names
 A_name = {'A1';'A2'};

 % Instantiate a time series object.
 ts1 = dseries(A,[],A_name,[]);

 % Call the tested method.
 a = ts1.log;

 % Expected results.
 e.data = log(A);
 e.nobs = 10;
 e.vobs = 2;
 e.name = {'A1';'A2'};
 e.freq = 1;
 e.init = dates(1,1);

 % Check the results.
 t(1) = dassert(a.data,e.data);
 t(2) = dassert(a.nobs,e.nobs);
 t(3) = dassert(a.vobs,e.vobs);
 t(4) = dassert(a.freq,e.freq);
 t(5) = dassert(a.init,e.init);
 T = all(t);
%@eof:3

%@test:4
 % Create an empty dseries object.
 dataset = dseries();

 t = zeros(5,1);

 try
    dseries_src_root = strrep(which('initialize_dseries_class'),'initialize_dseries_class.m','');
    A = dseries([ dseries_src_root '../tests/data/dynseries_test_data.csv' ]);
    t(1) = 1;
 catch
    t = 0;
 end

 % Check the results.
 if length(t)>1
     t(2) = dassert(A.nobs,4);
     t(3) = dassert(A.vobs,4);
     t(4) = dassert(A.freq,4);
     t(5) = dassert(A.init,dates('1990Q1'));
 end
 T = all(t);
%@eof:4

%@test:5
 % Define a data set.
 A = [transpose(1:10),2*transpose(1:10),3*transpose(1:10)];

 % Define names
 A_name = {'A1';'A2';'B1'};

 % Instantiate a time series object.
 ts1 = dseries(A,[],A_name,[]);

 % Call the tested method.
 a = ts1{'A1','B1'};

 % Expected results.
 e.data = A(:,[1,3]);
 e.nobs = 10;
 e.vobs = 2;
 e.name = {'A1';'B1'};
 e.freq = 1;
 e.init = dates(1,1);

 t(1) = dassert(e.data,a.data);
 t(2) = dassert(e.nobs,a.nobs);
 t(3) = dassert(e.vobs,a.vobs);
 t(4) = dassert(e.name,a.name);
 t(5) = dassert(e.init,a.init);
 T = all(t);
%@eof:5

%@test:6
 % Define a data set.
 A = rand(10,24);

 % Define names
 A_name = {'GDP_1';'GDP_2';'GDP_3'; 'GDP_4'; 'GDP_5'; 'GDP_6'; 'GDP_7'; 'GDP_8'; 'GDP_9'; 'GDP_10'; 'GDP_11'; 'GDP_12'; 'HICP_1';'HICP_2';'HICP_3'; 'HICP_4'; 'HICP_5'; 'HICP_6'; 'HICP_7'; 'HICP_8'; 'HICP_9'; 'HICP_10'; 'HICP_11'; 'HICP_12';};

 % Instantiate a time series object.
 ts1 = dseries(A,[],A_name,[]);

 % Call the tested method.
 try
     a = ts1{'[GDP_[0-9]]'};
     t(1) = 1;
 catch
     t(1) = 0;
 end
 try
     b = ts1{'[[A-Z]*_1]'};
     t(2) = 1;
 catch
     t(2) = 0;
 end
 try
     warnstate = warning('off');
     c = ts1{'[A-Z]_1'};
     warning(warnstate);
     t(3) = 0;
 catch
     t(3) = 1;
 end

 % Expected results.
 e1.data = A(:,1:9);
 e1.nobs = 10;
 e1.vobs = 9;
 e1.name = {'GDP_1';'GDP_2';'GDP_3'; 'GDP_4'; 'GDP_5'; 'GDP_6'; 'GDP_7'; 'GDP_8'; 'GDP_9'};
 e1.freq = 1;
 e1.init = dates(1,1);
 e2.data = A(:,[1 13]);
 e2.nobs = 10;
 e2.vobs = 2;
 e2.name = {'GDP_1';'HICP_1'};
 e2.freq = 1;
 e2.init = dates(1,1);

 % Check results.
 t(4) = dassert(e1.data,a.data);
 t(5) = dassert(e1.nobs,a.nobs);
 t(6) = dassert(e1.vobs,a.vobs);
 t(7) = dassert(e1.name,a.name);
 t(8) = dassert(e1.init,a.init);
 t(9) = dassert(e2.data,b.data);
 t(10) = dassert(e2.nobs,b.nobs);
 t(11) = dassert(e2.vobs,b.vobs);
 t(12) = dassert(e2.name,b.name);
 t(13) = dassert(e2.init,b.init);
 T = all(t);
%@eof:6

%@test:7
 % Define a data set.
 A = [transpose(1:10),2*transpose(1:10)];

 % Define names
 A_name = {'A1';'A2'};

 % Instantiate a time series object.
 try
    ts1 = dseries(A,[],A_name,[]);
    ts1.save('ts1');
    t = 1;
 catch
    t = 0;
 end

 delete('ts1.mat');

 T = all(t);
%@eof:7

%@test:8
 % Define a data set.
 A = [transpose(1:10),2*transpose(1:10)];

 % Define names
 A_name = {'A1';'A2'};

 % Instantiate a time series object.
 try
    ts1 = dseries(A,[],A_name,[]);
    ts1.save('test_generated_data_file','m');
    delete('test_generated_data_file.m');
    t = 1;
 catch
    t = 0;
 end

 T = all(t);
%@eof:8

%@test:9
 % Define a data set.
 A = [transpose(1:60),2*transpose(1:60),3*transpose(1:60)];

 % Define names
 A_name = {'A1';'A2';'B1'};

 % Instantiate a time series object.
 ts1 = dseries(A,'1971Q1',A_name,[]);

 % Define the range of a subsample.
 range = dates('1971Q2'):dates('1971Q4');
 % Call the tested method.
 a = ts1(range);

 % Expected results.
 e.data = A(2:4,:);
 e.nobs = 3;
 e.vobs = 3;
 e.name = {'A1';'A2';'B1'};
 e.freq = 4;
 e.init = dates('1971Q2');

 t(1) = dassert(e.data,a.data);
 t(2) = dassert(e.nobs,a.nobs);
 t(3) = dassert(e.vobs,a.vobs);
 t(4) = dassert(e.name,a.name);
 t(5) = dassert(e.init,a.init);
 T = all(t);
%@eof:9

%@test:10
 % Define a data set.
 A = [transpose(1:60),2*transpose(1:60),3*transpose(1:60)];

 % Define names
 A_name = {'A1';'A2';'B1'};

 % Instantiate a time series object.
 ts1 = dseries(A,'1971Q1',A_name,[]);

 % Test the size method.
 B = ts1.size();
 C = ts1.size(1);
 D = ts1.size(2);
 E = ts1.size;

 t(1) = dassert(B,[60, 3]);
 t(2) = dassert(E,[60, 3]);
 t(3) = dassert(C,60);
 t(4) = dassert(D,3);
 T = all(t);
%@eof:10

%@test:11
 % Define a data set.
 A = [transpose(1:60),2*transpose(1:60),3*transpose(1:60)];

 % Define names
 A_name = {'A1';'A2';'B1'};

 % Instantiate a time series object.
 ts1 = dseries(A,'1971Q1',A_name,[]);

 % Test the size method.
 B = ts1{1};
 C = ts1{[1,3]};
 D = ts1{'A1'};

 t(1) = dassert(B.name{1},'A1');
 t(2) = dassert(B.data,A(:,1));
 t(3) = dassert(C.name{1},'A1');
 t(4) = dassert(C.data(:,1),A(:,1));
 t(5) = dassert(C.name{2},'B1');
 t(6) = dassert(C.data(:,2),A(:,3));
 t(7) = dassert(D.name{1},'A1');
 t(8) = dassert(D.data,A(:,1));
 T = all(t);
%@eof:11

%@test:12
 % Define a data set.
 A = [transpose(1:10),2*transpose(1:10)];

 % Define names
 A_name = {'A1';'A2'};

 % Instantiate a time series object.
 try
    ts1 = dseries(A,[],A_name,[]);
    ts1.save();
    t = 1;
 catch
    t = 0;
 end

 delete('dynare_series.mat')

 T = all(t);
%@eof:12

%@test:13
 try
     data = transpose(0:1:50);
     ts = dseries(data,'1950Q1');
     a = ts.lag;
     b = ts.lead;
     c = ts(-1);
     d = ts(1);
     t(1) = 1;
 catch
     t(1) = 0;
 end

 if t(1)>1
     t(2) = (a==c);
     t(3) = (b==d);
 end

 T = all(t);
%@eof:13

%@test:14
 try
     ds = dseries(transpose(1:5));
     ts = ds(ds.dates(2:3));
     t(1) = 1;
 catch
     t(1) = 0;
 end

 if t(1)>1
     t(2) = isdseries(ts);
     t(3) = isequal(ts.data,ds.data(2:3));
 end

 T = all(t);
%@eof:14

%@test:15
 try
     ds = dseries(transpose(1:5));
     ts = ds(ds.dates(2:6));
     t(1) = 0;
 catch
     t(1) = 1;
 end

 T = all(t);
%@eof:15

%@test:16
 try
     ds = dseries(transpose(1:5));
     ts = ds(dates('1Y'):dates('6Y'));
     t(1) = 0;
 catch
     t(1) = 1;
 end

 T = all(t);
%@eof:16

%@test:17
 try
     ds = dseries(transpose(1:5));
     ts = ds(dates('-2Y'):dates('4Y'));
     t(1) = 0;
 catch
     t(1) = 1;
 end

 T = all(t);
%@eof:17

%@test:18
 try
     tseries = dseries();
     ts = tseries(ones(10,1));
     t(1) = true;
 catch
     t(1) = false;
 end

 if t(1)
     t(2) = ts.dates(1)==dates('1Y');
     t(3) = ts.dates(10)==dates('10Y');
 end

 T = all(t);
%@eof:18

%@test:19
 try
     tseries = dseries(dates('2000Q1'));
     ts = tseries(ones(5,1));
     t(1) = true;
 catch
     t(1) = false;
 end

 if t(1)
     t(2) = ts.dates(1)==dates('2000Q1');
     t(3) = ts.dates(5)==dates('2001Q1');
 end

 T = all(t);
%@eof:19

%@test:20
 try
     tseries = dseries(dates('2000H1'));
     ts = tseries(ones(6,1));
     t(1) = true;
 catch
     t(1) = false;
 end

 if t(1)
     t(2) = ts.dates(1)==dates('2000H1');
     t(3) = ts.dates(6)==dates('2002H2');
 end

 T = all(t);
%@eof:20

%@test:21
 try
     tseries = dseries(dates('2000-01-01'));
     ts = tseries(ones(6,1));
     t(1) = true;
 catch
     t(1) = false;
 end

 if t(1)
     t(2) = ts.dates(1)==dates('2000-01-01');
     t(3) = ts.dates(6)==dates('2000-01-06');
 end

 T = all(t);
%@eof:21
