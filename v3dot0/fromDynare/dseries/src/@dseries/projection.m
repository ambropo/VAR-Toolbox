function o = projection(o, info, periods)  % --*-- Unitary tests --*--

% Projects variables in dseries object o.
%
% INPUTS
% - o         [dseries]          Dataset.
% - info      [cell]             n×3 array, with vobs(o)>=n, description of the paths.
% - periods   [integer]          scalar, length of the projection path.
%
% OUTPUTS
% - o         [dseries]          Updated dseries object.
%
% REMARKS
% [1] Second input argument is a n×3 cell array. Each row provides
%     informations necessary to project a variable. The first column
%     contains the name of variable (row char array). the second column
%     contains the name of the method used to project the associated
%     variable (row char array), possible values are 'Trend',
%     'Constant', and 'AR'. Last column provides quantitative
%     informations about the projection. If the second column value is
%     'Trend', the third column value is the growth factor of the
%     (exponential) trend. If the second column value is 'Constant',
%     the third column value is the level of the variable. If the
%     second column value is 'AR', the third column value is the
%     autoregressive parameter. The variables can be projected with an
%     AR(p) model, if the third column contains a 1×p vector of
%     doubles.
% [2] The stationarity of the AR(p) model is not tested.
% [3] The case of the constant projection, using the last value of the
%     variable, is covered with 'Trend' and a growth factor equal to 1,
%     or 'AR' with an autoregressive parameter equal to one (random walk).
% [4] This projection routine only deals with exponential trends.

% Fetch useful lines in info
[~, ~, i2] = intersect(o.name, info(:,1));
INFO = info(i2,:);

% Change number of periods in dseries object o
T = nobs(o);
o.data = cat(1, o.data, zeros(periods, vobs(o)));
o.dates = [o.dates; o.dates(end)+1:o.dates(end)+periods];

for i=1:rows(INFO)
    j = find(strcmp(o.name, INFO{i,1}));
    switch INFO{i,2}
      case 'Constant'
        if abs(INFO{i,3})>0
            o.data(T+(1:periods),j) = INFO{i,3};
        end
      case 'Trend'
        if abs(INFO{i,3}-1)>0
            o.data(T+(1:periods),j) = o.data(T,j)*cumprod(INFO{i,3}^(1.0/frequency(o))*ones(periods,1));
        else
            o.data(T+(1:periods),j) = o.data(T,j)*ones(periods,1);
        end
      case 'AR'
        if isequal(length(INFO{i,3}), 1)
            if abs(INFO{i,3})>0
                o.data(T+(1:periods),j) = o.data(T,j)*cumprod(INFO{i,3}*ones(periods,1));
            end
        else
            p = length(INFO{i,3});
            b = transpose(INFO{i,3}(:)); % Insure that the vector of autoregressive parameters is a row vector.
            for t=T+1:T+periods
                o.data(t,j) = b*o.data(t-(1:p),j);
            end
        end
      otherwise
        error('dseries::projection: Content of provided second argument (info) is not correct.')
    end
end

return

%@test:1
try
     data = ones(10,4);
     ts = dseries(data, '1990Q1', {'A1', 'A2', 'A3', 'A4'});
     info = {'A1', 'Trend', 1.2; 'A2', 'Constant', 0.0; 'A3', 'AR', .5; 'A4', 'AR', [.4, -.2]};
     ts.projection(info, 10);
     t(1) = true;
 catch
     t(1) = false;
 end

if t(1)
    t(2) = isequal(ts.nobs(), 20);
    t(3) = dassert(ts.A1.data(11), 1.046635139392, 1e-12) & dassert(ts.A1.data(14), 1.2, 1e-15);
    t(4) = dassert(ts.A2.data(11:20), zeros(10,1), 1e-15);
    t(5) = dassert(ts.A3.data(11), 0.5, 1e-15) & dassert(ts.A3.data(12), 0.25, 1e-15);
    t(6) = dassert(ts.A4.data(11), 0.2, 1e-15) & dassert(ts.A4.data(12), 0.2*0.4-0.2, 1e-15);
end
T = all(t);
%@eof:1