function x = roundn(x, n)
%ROUNDN  Round to multiple of 10^n
%
%   Use of ROUNDN is not recommended. Use the round(X,N) syntax of the
%   MATLAB ROUND function instead, but note that the sign of N is reversed:
%   ROUNDN(X,N) should be replaced with round(X,-N).
%
%   ROUNDN(X,N) rounds each element of X to the nearest multiple of 10^N.
%   N must be scalar, and integer-valued. For complex X, the imaginary
%   and real parts are rounded independently. For N = 0 ROUNDN gives the
%   same result as round. That is, ROUNDN(X,0) == round(X).
%
%   Examples
%   --------
%   % Round pi to the nearest hundredth. The same result, 3.14, is returned
%   % by both of the following:
%   roundn(pi, -2)
%   round(pi, 2)
%
%   % Round the equatorial radius of the Earth, 6378137 meters,
%   % to the nearest kilometer. Both calls return 6378000.
%   roundn(6378137, 3)
%   round(6378137, -3)
%
%  See also ROUND.

% Copyright 1996-2015 The MathWorks, Inc.

% Validate inputs. (Both are required.)
narginchk(2,2)
validateattributes(x, {'single', 'double'}, {}, 'ROUNDN', 'X')
validateattributes(n, ...
    {'numeric'}, {'scalar', 'real', 'integer'}, 'ROUNDN', 'N')

if n < 0
    % Compute the inverse of the power of 10 to which input will be
    % rounded. Because n < 0, p will be greater than 1.
    p = 10 ^ -n;

    % Round x to the nearest multiple of 1/p.
    x = round(p * x) / p;
elseif n > 0
    % Compute the power of 10 to which input will be rounded. Because
    % n > 0, p will be greater than 1.
    p = 10 ^ n;
    
    % Round x to the nearest multiple of p.
    x = p * round(x / p);
else
    x = round(x);
end
