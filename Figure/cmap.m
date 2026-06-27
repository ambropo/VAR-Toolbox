function out = cmap(n)
% =======================================================================
% Return the 1x3 RGB color vector corresponding to index n in the
% toolbox color sequence:
%   1 Blue, 2 Tomato, 3 Gold_Dark, 4 Mint_Dark, 5 Pink, 6 Choco_Light,
%   7 BoEacqua, 8 BoEpurple_Dark
% =======================================================================
% out = cmap(n)
% -----------------------------------------------------------------------
% INPUT
%   - n: index into the color sequence, 1–72 [double]
%        Indices 1–8 are named colors; indices 9–72 fall back to parula.
%        n > 72 will throw an out-of-bounds error.
% -----------------------------------------------------------------------
% OUTPUT
%   - out: 1x3 RGB color vector, values in [0,1] [double]
% -----------------------------------------------------------------------
% EXAMPLE
%   out = cmap(1);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. DEFINE COLOR TABLE AND RETURN REQUESTED COLOR
% -----------------------------------------------------------------------
% Entries 1-8 are named pantone colors; remaining rows fall back to parula.
colors = [
     56/255, 108/255, 176/255;   %  1 Blue
    217/255,  83/255,  79/255;   %  2 Tomato
    254/255, 197/255,  29/255;   %  3 Gold_Dark
     80/255, 158/255,  80/255;   %  4 Mint_Dark
    240/255,   2/255, 127/255;   %  5 Pink
    118/255,  98/255,  83/255;   %  6 Choco_Light
     60/255, 215/255, 217/255;   %  7 BoEacqua
    136/255,  99/255, 225/255;   %  8 BoEpurple_Dark
    parula];
out = colors(n,:);
