function [OUT, fo, lo] = CommonSample(DATA,dim)
% =======================================================================
% If a row of DATA contains a NaN, the row is removed. If dim=2, if a
% column of DATA contains a NaN, the column is removed.
% =======================================================================
% [OUT, fo, lo] = CommonSample(DATA, dim)
% -----------------------------------------------------------------------
% INPUT
%   - DATA: matrix of data [T x N]
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - dim: dimension along which to remove NaNs [dflt = 1 (rows)]
%          Set to 2 to remove columns containing NaN
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: data matrix with all NaN-containing rows (or columns) removed
%   - fo : number of leading NaN rows (or columns)
%   - lo : number of trailing NaN rows (or columns)
% -----------------------------------------------------------------------
% EXAMPLE
%   X = [1 2; NaN 4; 5 6; 7 NaN; 9 10];
%   [OUT, fo, lo] = CommonSample(X);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
if ~exist('dim','var')
    dim = 1;
end

%% 2. REMOVE NaN ROWS/COLUMNS AND COUNT LEADING/TRAILING NaNs
% -----------------------------------------------------------------------
% Initialize counters: fo = number of leading NaN rows (or cols);
% lo = number of trailing ones.
fo = 0;
lo = 0;

if dim==1
    % Sum across columns: any NaN in a row makes the row sum NaN
    temp = sum(DATA,2);
    ii = 1;

    % Count consecutive NaNs at the start (leading missing observations)
    if isnan(temp(ii))
        while isnan(temp(ii))
            fo = fo+1;
            ii = ii+1;
            if ii>length(temp)
                break
            end
        end
    end

    % Count consecutive NaNs at the end (trailing missing observations)
    for ii=1:rows(DATA)-fo
        if isnan(temp(end+1-ii))
            lo = lo+1;
        else
            break
        end
    end

    % Remove all rows that contain at least one NaN
    DATA(any(isnan(DATA),2),:) = [];
else
    % Sum across rows: any NaN in a column makes the column sum NaN
    temp = sum(DATA,1);
    ii = 1;

    % Count consecutive NaNs at the start (leading missing columns)
    if isnan(temp(ii))
        while isnan(temp(ii))
            fo = fo+1;
            ii = ii+1;
            if ii > length(temp); break; end
        end
    end

    % Count consecutive NaNs at the end (trailing missing columns)
    for ii=1:cols(DATA)-fo
        if isnan(temp(end+1-ii))
            lo = lo+1;
        else
            break
        end
    end

    % Remove all columns that contain at least one NaN
    DATA(:,any(isnan(DATA),1)) = [];
end

% Return the cleaned data matrix
OUT = DATA;
