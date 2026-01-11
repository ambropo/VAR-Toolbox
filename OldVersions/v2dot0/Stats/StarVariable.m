function OUT = StarVariable(DATA)
% Computes foreign variables as in the GVAR with equal weights
% =======================================================================
% [OUT, wgts] = xstar(DATA)
% -----------------------------------------------------------------------
% INPUTS
%   - DATA: an (T x N) matrix of time series
%--------------------------------------------------------------------------
% OUTPUT
%    - OUT: (T x N) matrix of xstar time series
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com


[nobs, nvar] = size(DATA);
OUT = nan(nobs, nvar);
w = ones(1,nvar)./nvar;

for ii=1:nvar
    % Create a logical vector to exclude variable ii
    select = ones(1,nvar); select(ii)=0; select = logical(select);
    % Remove variable ii from DATA
    data = DATA(:,select);
    % Remove weight/flow ii from w
    weights = w(select);
    % Compute xstar variable for cuntry ii
    OUT(:,ii) = CrossWeightAverage(data,weights);
end





