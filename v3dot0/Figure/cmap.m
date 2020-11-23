function out = cmap(n)
% =======================================================================
% Returns a 1x3 row vector for RGB colors corrending to the n^th element 
% of the following list:
% - 1 blue
% - 2 yellow
% - 3 purple
% - 4 light blues
% - 5 red
% - 6 green
% - 7 dark red 
% =======================================================================
% cmap(n)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - n: number of color in the sequence
% -----------------------------------------------------------------------
% OUTPUT
%   - out: 3x1 vector or RGB color
% -----------------------------------------------------------------------
% EXAMPLE
%   out = cmap(1);
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------


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
