function Y = rcumsum(X)

% Returns the cumulated sum of X from bottom to top (reversed order
% compared to cumsum, emulate the `reverse` option).
%
% INPUTS
% - X      [double]      T×N array
%
% OUTPUTS
% - Y      [double]      T×N array

if isoctave() || matlab_ver_less_than('9.4')
    Y = flipud(cumsum(flipud(X)));
else
    Y = cumsum(X, 'reverse');
end