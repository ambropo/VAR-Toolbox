function out = OrthNorm(n)
% =======================================================================
% Compute a [n x n] random orthonormal matrix drawn from the Haar measure
% =======================================================================
% out = OrthNorm(n)
% -----------------------------------------------------------------------
% INPUT
%   - n: size of the matrix [integer]
% -----------------------------------------------------------------------
% OUTPUT
%   - out: [n x n] random orthonormal matrix [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   Q = OrthNorm(3);
%   disp(Q*Q')   % should be identity
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
if nargin < 1
    error('OrthNorm: input n (matrix size) is required');
end

%% 2. DRAW RANDOM ORTHONORMAL MATRIX
% -----------------------------------------------------------------------
% QR is not unique: MATLAB's qr() can return Q with columns of either sign.
% The sign-normalisation loop enforces r(i,i) >= 0 (positive diagonal),
% giving a unique ("canonical") Q. Used in sign-restriction algorithms to
% draw uniformly from the Haar measure on the space of orthonormal matrices.
a = randn(n);
[q, r] = qr(a);
for i = 1:size(q,1)
    if r(i,i) < 0
        q(:,i) = -q(:,i);
    end
end
out = q;
end
