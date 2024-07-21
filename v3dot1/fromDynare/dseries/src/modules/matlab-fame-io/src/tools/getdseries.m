function ts = getdseries(db,varargin)

% Returns a structure of dseries. Each field (M, Q, A) is a dseries with monthly, quaterly and
% annual frequency.

% Copyright (C) 2017-2018 Dynare Team
%
% This code is part of dseries fame toolbox.
%
% This code is free software you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This code is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

ts.Q=dseries();
ts.M=dseries();
ts.A=dseries();
ts.B=dseries();

if nargin > 1
    s=varargin;
    if length(s)>1
        b=[sprintf('%s*', s{1:end-1}), s{end}];
    else
        b=varargin{1};
    end
    wildCard = b;
else
    wildCard = '*';
end

ts_iterator = get_ts_iterator(db, wildCard);

info = ts_iterator.nextElement();
name = {char(info.getName())};
data = info.getTiqObjectCopy.getObservations.getValueList.getArray;

ts.error = cell(0);
ts.info = cell(0);

try
    if isempty(data)
        error(['Empty series ' name{:}]);
    end
    [datestmp, frq] = getdate(info);
    if ~isa(data,'double')
        ts.info=vertcat(ts.info, [name{:} ' - changed datatype from ' class(data) ' to double.']);
        data=double(data);
    end
    switch char(frq)
        case 'QUARTERLY'
            ts.Q.(name{:}) = dseries(data, datestmp);
        case 'MONTHLY'
            ts.M.(name{:}) = dseries(data, datestmp);
        case 'ANNUAL'
            ts.A.(name{:}) = dseries(data, datestmp);
        case 'DAILY'
            ts.B.(name{:}) = dseries(data, datestmp);              
        otherwise
            fprintf('Unimplemented frequency (%s is %s)', name{:}, cf)
    end
catch me
    ts.error = vertcat(ts.error, me.message);
end

while ts_iterator.hasMoreElements
    info = ts_iterator.nextElement();
    name = {char(info.getName())};
    data=info.getTiqObjectCopy.getObservations.getValueList.getArray;
    try
        if isempty(data)
            error(['Empty series ' name{:}]);
        end
        [datestmp, frqn] = getdate(info);
        if ~isa(data,'double')
            ts.info=vertcat(ts.info, [name{:} ' - changed datatype from ' class(data) ' to double.']);
            data=double(data);
        end
        switch char(frqn)
            case 'QUARTERLY'
                ts.Q.(name{:}) = dseries(data, datestmp);
            case 'MONTHLY'
                ts.M.(name{:}) = dseries(data, datestmp);
            case 'ANNUAL'
                ts.A.(name{:}) = dseries(data, datestmp);
            case 'DAILY'
                ts.B.(name{:}) = dseries(data, datestmp);                  
            otherwise
                fprintf('Unimplemented frequency (%s is %s)', name{:}, cf)
        end
    catch me
        ts.error = vertcat(ts.error, me.message);
    end
end


function [datestmp, frqn] = getdate(info)
    frqn = info.getTiqObjectCopy.getFrequency;
    first = info.getFirstIndex;
    yy = com.fame.timeiq.dates.DateHelper.indexToYear(first);
    mm = com.fame.timeiq.dates.DateHelper.indexToMonth(first);
    dd = com.fame.timeiq.dates.DateHelper.indexToDay(first);
    if mm>0 && mm<13 && dd>0 && dd<32
        if  strcmp('QUARTERLY', frqn)
            datestmp = datestr([yy,mm,dd,0,0,0], 'yyyyqq');
        elseif strcmp('MONTHLY', frqn)
            tmp = datestr([yy,mm,dd,0,0,0],'yyyymm');
            tmp = regexprep(tmp, '^(\d{4})(\d{2})$', '$1m$2');
            datestmp = regexprep(tmp, '^(\d{4})m0(\d)$', '$1m$2');
        elseif strcmp('ANNUAL', frqn)
            tmp = datestr([yy, mm, dd, 0, 0, 0], 'yyyy');
            datestmp = regexprep(tmp, '^(\d{4})$', '$1y');
        elseif strcmp('DAILY', frqn)
            obs = info.getTiqObjectCopy.getObservations();
            datestmp = string(obs.getIndexesAsStrings());
            DD = day(datestmp);
            MM = month(datestmp);
            YY = year(datestmp);
            datestmp = dates(365, YY, MM, DD);
        end
    else
        name = char(info.getName());
        error(['Wrong starting date for the series ' name ': y=' num2str(yy) ', m=' num2str(mm) ', d=' num2str(dd)])
    end