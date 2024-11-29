function B=nancumsum(A,dim,nmode)
% NANCUMSUM: Cumulative sum of a matrix, with user-specified treatment of NaNs.
%     Computes the cumulative sum of matrix A along dimension DIM, allowing
%     the user to replace NaNs with zeros, to maintain NaNs as
%     placeholders, or, when A is a vector, to discard NaNs.  
% 
% USAGE: B = nancumsum(A, DIM, NMODE)
%
% ARGUMENTS:
%
% A:    Input matrix.
%
% B:    Output cumulative sum matrix, treating NaNs as determined by nmode.
%       Note that if B is a vector (1xn or nx1), A may or may not be the
%       same size as B, depending on the method selected for representing NaNs.
%
% DIM:  B = nancumsum(A, DIM) returns the nan-cumulative sum of the elements
%       along the dimension of A specified by scalar DIM. For example,
%       nancumsum(A,1) works down the columns, nancumsum(A,2) works
%       across the rows. If DIM is not specified, it defaults to the first
%       non-singleton dimension of A. 
%
% NMODE: specifies how NaNs should be treated. Acceptable values are:
%       1: REPLACE NaNs with zeros (default).
%       2: MAINTAIN NaNs as position holders in B.
%       3: DISCARD NaNs. Note: this is legal only for VECTOR values of A.
%
% EXAMPLES:
%
% 1) a=[NaN,2:5];
%
% nancumsum(a)
% ans =
%     0     2     5     9    14
%
% nancumsum(a,[],2)
% ans =
%   NaN     2     5     9    14
%
% nancumsum(a,[],3)
% ans =
%     2     5     9    14
%
% 2) a = magic(3); a(4)=NaN;
%
% b=nancumsum(a,2)
% b =
%     8     8    14
%     3     8    15
%     4    13    15
%
% b=nancumsum(a,2,2)
% b =
%     8   NaN     6
%     3     5     7
%     4     9     2
%
% See also: cumsum, nansum, nancumprod, nanmean, nanmedian, ...
% (nancumprod is available from the FEX. Other nan* may require Toolboxes)

% Brett Shoelson
% brett.shoelson@mathworks.com
% 05/04/07

% Set defaults, check and validate inputs
if nargin < 3
    nmode = 1;
end

if ~ismember(nmode,1:3)
    error('NANCUMSUM: unacceptable value for nmode parameter.');
elseif ~isvector(A)
    if nmode == 3
        error('NANCUMSUM: For non-vector inputs, nmode must be 1 or 2.');
    end
end

if nargin < 2 || isempty(dim)
    if ~isscalar(A)
        dim = find(size(A)>1);
        dim = dim(1);
    else
        % For scalar inputs (no nonsingleton dimension)
        dim = 1;
    end
end

% Calculate cumulative sum, depending on selection of nmode
switch nmode
    case 1
        % TREAT NaNs as 0's
        B = A;
        B(B~=B) = 0;
        B = cumsum(B, dim);
    case 2
        % DO NOT INCREMENT, BUT USE NaNs AS PLACEHOLDERS.
        B = A;
        B(B==B) = cumsum(B(B==B), dim);
    otherwise % case 3
        % DISCARD NaNs. (Valid only for vector inputs.)
        B = A(A == A);
        B = cumsum(B, dim);
end
     

