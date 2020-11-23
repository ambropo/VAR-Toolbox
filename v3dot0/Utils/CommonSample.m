function [OUT, fo, lo] = CommonSample(DATA,dim)
% =======================================================================
% If a row of DATA contains a NaN, the row is removed. If dim=2, if a 
% column of DATA contains a NaN, the column is removed.
% =======================================================================
% [OUT, lo, fo] = CommonSample(DATA)
% -----------------------------------------------------------------------
% INPUT
%	- DATA: matrix DATA(i,j)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - dim: default 1, change to 2 to CommonSample by column
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: common sample matrix
%	- lo : number of NaNs at the beginning
%	- fo : number of NaNs at the end
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; NaN 4; 5 6];
%   OUT = CommonSample(x)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

% If no dimension is specified, set it to 1
if ~exist('dim','var')
    dim = 1;
end

fo = 0;
lo = 0;

if dim==1
    temp = sum(DATA,2);
    ii = 1;
    if isnan(temp(ii))
        while isnan(temp(ii))
                fo = fo+1;
                ii = ii+1;
                if ii>length(temp)
                    break
                end
        end
    end
    for ii=1:rows(DATA)-fo
        if isnan(temp(end+1-ii))
            lo = lo+1;
        end
    end
    DATA(any(isnan(DATA),2),:) = [];
else
    temp = sum(DATA,1);
    ii = 1;
    if isnan(temp(ii))
        while isnan(temp(ii))
                fo = fo+1;
                ii = ii+1;
        end
    end
    for ii=1:cols(DATA)-fo
        if isnan(temp(end+1-ii))
            lo = lo+1;
        end
    end
    DATA(:,any(isnan(DATA),1)) = [];
end

OUT = DATA;
