function out = getqr(a)
% =======================================================================
% QR factorization of a matrix a.
% =======================================================================
% out = getqr(a)
% -----------------------------------------------------------------------
% INPUT
%	- a: Matrix to factorize
% -----------------------------------------------------------------------
% OUTPUT
%   - out: factorized matrix such that out*out'=I
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% December 2021
% -----------------------------------------------------------------------

[q,r]=qr(a);
for i=1:size(q,1)
    if r(i,i)<0
        q(:,i)=-q(:,i);
    end
end
out=q;
end