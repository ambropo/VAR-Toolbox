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
% VAR Toolbox 3.1
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated March 2024
% -----------------------------------------------------------------------

a = randn(n);
[q,r]=qr(a);
for i=1:size(q,1)
    if r(i,i)<0
        q(:,i)=-q(:,i);
    end
end
out=q;
end
