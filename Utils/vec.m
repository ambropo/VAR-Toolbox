function out = vec(X,dim)
% =======================================================================
% Vectorize the matrix X
% =======================================================================
% out = vec(X)
% -----------------------------------------------------------------------
% INPUT
%   - X: [r x c] matrix
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - dim: dimension over which to vectorize [default 1. Set to 2 to get a
%          row vector]
% -----------------------------------------------------------------------
% OUTPUT
%   - out: [r*c x 1] matrix
% =======================================================================
% Ambrogio Cesa Bianchi, March 2016
% ambrogio.cesabianchi@gmail.com

% Check inputs
if ~exist('dim','var')
    dim = 1;
end

% Size of input
[r,c] = size(X);

% Vectorize
if dim==1
    out = reshape(X,r*c,1);
elseif dim==2
    out = reshape(X,1,r*c);
else
    error('input "dim" has wrong value')
end
    