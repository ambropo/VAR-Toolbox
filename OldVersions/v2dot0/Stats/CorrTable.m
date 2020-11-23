function out = CorrTable(x,vnames)
% =======================================================================
% Computes the correlation matrix of a matrix of time series with titles
% =======================================================================
% out = CorrTable(x,vnames)
% -----------------------------------------------------------------------
% INPUT
%   - x: T obs (rows) x N series (columns)
%   - vnames: cell array with vnames of the N series
% -----------------------------------------------------------------------
% OUTPUT
%   - out: table of correlation matrix with titles
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015


% vnames must be a row vector
if size(vnames,1)>1
    vnames = vnames';
end

% Compute correlation
y = corrcoef(x);
[r, ~] = size(y);

% Place NaNs on the uuper triangular
y(find(triu(y))) = NaN;
jj = 1;
for ii=1:r
    y(ii,jj) = 1;
    jj = jj +1;
end

% Save position of NaNs
nans = isnan(y);

% Transform table into cell array
table = num2cell(y);

% Substitue NaNs with -
table(nans) = {'--'};

% Add vnames on top
table = [vnames ; table];

% Add vnames on the left
aux = [{''} vnames]';
out = [aux table];

% Print using mprint
info.cvnames = char(vnames);
info.rvnames = char([{' '} vnames]);
mprint(y,info)