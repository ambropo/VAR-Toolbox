function out = cmap(n)
% =======================================================================
% Returns a 1x3 row vector for RGB colors.
% =======================================================================
% cmap(n)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - n: number of color in the sequence
% =======================================================================
% Ambrogio Cesa Bianchi, July 2016
% ambrogio.cesabianchi@gmail.com

colors = [...
    0.000,0.447,0.741 ; % 1 blue
    0.929,0.694,0.125 ; % 2 yellow
    0.494,0.184,0.556 ; % 3 purple
    0.301,0.745,0.933 ; % 4 light blues
    0.850,0.325,0.098 ; % 5 red
    0.466,0.674,0.188 ; % 6 green
    0.635,0.078,0.184 ; % 7 dark red
    parula];
out = colors(n,:);
