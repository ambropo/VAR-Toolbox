function out = vec(X,dim)
% =======================================================================
% Vectorize the matrix X
% =======================================================================
% out = vec(X)
% -----------------------------------------------------------------------
% INPUT
%   - X: (TxN) matrix
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - dim: dimension over which to vectorize [dflt 1]. Set to 2 to get a
%          row vector
% -----------------------------------------------------------------------
% OUTPUT
%   - out: [r*c x 1] matrix
% -----------------------------------------------------------------------
% EXAMPLE
%   x = [1 2; 3 4; 5 6; 7 8; 9 10];
%   out = vec(x,1)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------

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
    