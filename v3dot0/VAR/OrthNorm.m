function out = OrthNorm(n)
% =======================================================================
% Compute a [n x n] random orthonormal matrix
% =======================================================================
% out = OrthNorm(n)
% -----------------------------------------------------------------------
% INPUT
%   - n: size of the matrix
% -----------------------------------------------------------------------
% OUTPUT
%   - out: [n x n] random orthonormal matrix
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% [n x n]  matrix of N(0,1) random variables
X = randn(n,n);

% QR decomposition of X
[Q, ~] = qr(X);

% Check precision
if sum(sum(Q*Q'))> n + 1.0e-5
    error('Q*transpose(Q) is not equal to identity')
end

% Random orthonormal matrix such that Q*Q'=I
out = Q; 