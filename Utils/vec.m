function out = vec(X,dim)
% =====================================================================
% Stack the elements of a matrix into a column or row vector
% =====================================================================
% out = vec(X,dim)
% ---------------------------------------------------------------------
% INPUT
%   - X: matrix to vectorize [T x N double]
% ---------------------------------------------------------------------
% OPTIONAL INPUT
%   - dim: dimension along which to vectorize [dflt = 1]. Use dim=1 for
%          a column vector; dim=2 for a row vector.
% ---------------------------------------------------------------------
% OUTPUT
%   - out: vectorized result; [T*N x 1] if dim=1, [1 x T*N] if dim=2
%          [double]
% ---------------------------------------------------------------------
% EXAMPLE
%   X   = randn(5,3);
%   col = vec(X, 1);   % 15x1 column vector
%   row = vec(X, 2);   % 1x15 row vector
% =====================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2012. Updated: 2026-05-31
% ---------------------------------------------------------------------

%% 1. CHECK INPUTS
% ---------------------------------------------------------------------
% Set default vectorization direction if the optional argument is absent.
if ~exist('dim','var')
    dim = 1;
end

%% 2. VECTORIZE
% ---------------------------------------------------------------------
% dim=1: stack columns into a (r*c x 1) column vector (standard vec operator).
%   MATLAB's reshape is column-major, so reshape(X,r*c,1) concatenates
%   column 1, then column 2, ..., then column c — matching the math vec.
% dim=2: lay out elements into a (1 x r*c) row vector
[r, c] = size(X);

% Reshape according to the requested dimension
if dim==1
    out = reshape(X, r*c, 1);
elseif dim==2
    out = reshape(X, 1, r*c);
else
    error('vec: dim must be 1 (column vector) or 2 (row vector)')
end
