function [OUT,T]=pantone(colorname)
% =======================================================================
% Retrieve RGB values for a named Pantone-inspired color, or display all
% available colors in a palette when called with no arguments
% =======================================================================
% [OUT,T] = pantone(colorname)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - colorname: name of the color to retrieve (e.g. 'Plum_Light') [char]
%                if omitted, all colors are displayed as a palette and
%                OUT = [] is returned
% -----------------------------------------------------------------------
% OUTPUT
%   - OUT: 1x3 RGB vector for the requested color, scaled to [0,1] [double]
%          ([] when called with no arguments)
%   - T  : table of all color names and RGB values [table]
% -----------------------------------------------------------------------
% EXAMPLE
%   pantone;                        % display full palette
%   OUT = pantone('Plum_Light');    % retrieve RGB for Plum_Light
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: November 2024. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. COLORS
% -----------------------------------------------------------------------
% Define cell vector of color names
col_names = {
'PaloAlto'; 'PaloAlto_Light'; 'PaloAlto_Dark';
'Turquoise'; 'Turquoise_Light'; 'Turquoise_Dark';
'Olive'; 'Olive_Light'; 'Olive_Dark';
'Teal'; 'Teal_Light'; 'Teal_Dark';
'Sky'; 'Sky_Light'; 'Sky_Dark';
'Cobalt'; 'Cobalt_Light'; 'Cobalt_Dark';
'Orange'; 'Orange_Light'; 'Orange_Dark';
'Red'; 'Red_Light'; 'Red_Dark';
'Gold'; 'Gold_Light'; 'Gold_Dark';
'Plum'; 'Plum_Light'; 'Plum_Dark';
'Burgundy'; 'Burgundy_Light'; 'Burgundy_Dark';
'Choco'; 'Choco_Light'; 'Choco_Dark';
'Stone'; 'Stone_Light'; 'Stone_Dark';
'Fog'; 'Fog_Light'; 'Fog_Dark';
'Blue'; 'Blue_Light'; 'Blue_Dark';
'Pink'; 'Pink_Light'; 'Pink_Dark';
'Salmon'; 'Salmon_Light'; 'Salmon_Dark';
'Lily'; 'Lily_Light'; 'Lily_Dark';
'Mint'; 'Mint_Light'; 'Mint_Dark';
'Tomato'; 'Tomato_Light'; 'Tomato_Dark';
'BoEblue'; 'BoEblue_Light'; 'BoEblue_Dark';
'BoEred'; 'BoEred_Light'; 'BoEred_Dark';
'BoEgreen'; 'BoEgreen_Light'; 'BoEgreen_Dark';
'BoEpurple'; 'BoEpurple_Light'; 'BoEpurple_Dark';
'BoEorange'; 'BoEorange_Light'; 'BoEorange_Dark';
'BoEacqua'; 'BoEacqua_Light'; 'BoEacqua_Dark';
'BoEpink'; 'BoEpink_Light'; 'BoEpink_Dark';
'BoEgold'; 'BoEgold_Light'; 'BoEgold_Dark';
'BoEnavy'; 'BoEnavy_Light'; 'BoEnavy_Dark';
'BoEpeach'; 'BoEpeach_Light'; 'BoEpeach_Dark';
'BoEyellow'; 'BoEyellow_Light'; 'BoEyellow_Dark';
'BoEstone'; 'BoEstone_Light'; 'BoEstone_Dark';
};

% Define corresponding RGB values (scaled to [0,1] below)
col_rgb = [
23, 94, 84;       % PaloAlto
45, 113, 111;     % PaloAlto_Light
1, 66, 64;        % PaloAlto_Dark
39, 153, 137;     % Turquoise
89, 179, 169;     % Turquoise_Light
1, 126, 124;      % Turquoise_Dark
143, 153, 62;     % Olive
166, 177, 104;    % Olive_Light
122, 134, 59;     % Olive_Dark
111, 162, 135;    % Teal
138, 184, 167;    % Teal_Light
65, 120, 101;     % Teal_Dark
66, 152, 181;     % Sky
103, 175, 210;    % Sky_Light
1, 104, 149;      % Sky_Dark
0, 124, 146;      % Cobalt
0, 154, 180;      % Cobalt_Light
0, 107, 129;      % Cobalt_Dark
233, 131, 0;      % Orange
249, 164, 74;     % Orange_Light
209, 102, 15;     % Orange_Dark
224, 79, 57;      % Red
244, 121, 91;     % Red_Light
199, 70, 50;      % Red_Dark
254, 221, 92;     % Gold
255, 231, 129;    % Gold_Light
254, 197, 29;     % Gold_Dark
98, 0, 89;        % Plum
115, 70, 117;     % Plum_Light
53, 13, 54;       % Plum_Dark
101, 28, 50;      % Burgundy
127, 45, 72;      % Burgundy_Light
66, 8, 27;        % Burgundy_Dark
93, 75, 60;       % Choco
118, 98, 83;      % Choco_Light
47, 36, 36;       % Choco_Dark
127, 119, 118;    % Stone
212, 209, 209;    % Stone_Light
84, 73, 72;       % Stone_Dark
218, 215, 203;    % Fog
244, 244, 244;    % Fog_Light
182, 177, 169;    % Fog_Dark
56, 108, 176;     % Blue
150, 180, 225;    % Blue_Light
30, 60, 120;      % Blue_Dark
240, 2, 127;      % Pink
255, 153, 204;    % Pink_Light
204, 0, 102;      % Pink_Dark
253, 192, 153;    % Salmon
255, 215, 195;    % Salmon_Light
220, 150, 100;    % Salmon_Dark
190, 174, 212;    % Lily
215, 200, 235;    % Lily_Light
145, 125, 175;    % Lily_Dark
127, 201, 127;    % Mint
170, 220, 170;    % Mint_Light
80, 158, 80;      % Mint_Dark
217, 83, 79;      % Tomato
240, 120, 110;    % Tomato_Light
175, 55, 50;      % Tomato_Dark
82, 151, 255;     % BoEblue
150, 195, 255;    % BoEblue_Light
30, 90, 200;      % BoEblue_Dark
254, 1, 84;       % BoEred
255, 102, 150;    % BoEred_Light
185, 0, 55;       % BoEred_Dark
165, 215, 0;      % BoEgreen
200, 235, 100;    % BoEgreen_Light
110, 155, 0;      % BoEgreen_Dark
158, 113, 254;    % BoEpurple
187, 156, 254;    % BoEpurple_Light
136, 99, 225;     % BoEpurple_Dark
255, 115, 0;      % BoEorange
255, 164, 89;     % BoEorange_Light
231, 105, 0;      % BoEorange_Dark
60, 215, 217;     % BoEacqua
109, 225, 226;    % BoEacqua_Light
52, 188, 193;     % BoEacqua_Dark
255, 80, 200;     % BoEpink
255, 160, 228;    % BoEpink_Light
200, 20, 155;     % BoEpink_Dark
255, 211, 96;     % BoEgold
223, 195, 99;     % BoEgold_Light
192, 160, 51;     % BoEgold_Dark
18, 39, 63;       % BoEnavy
65, 82, 101;      % BoEnavy_Light
13, 27, 44;       % BoEnavy_Dark
255, 145, 115;    % BoEpeach
255, 190, 170;    % BoEpeach_Light
210, 90, 60;      % BoEpeach_Dark
255, 225, 0;      % BoEyellow
255, 240, 120;    % BoEyellow_Light
200, 170, 0;      % BoEyellow_Dark
196, 201, 206;    % BoEstone
178, 183, 188;    % BoEstone_Light
136, 147, 159;    % BoEstone_Dark
]./255;

% Build a table of RGB values indexed by color name for easy lookup
T = table(col_rgb, 'VariableNames', {'RGB'}, 'RowNames', col_names);

%% 2. NO INPUT — DISPLAY PALETTE
% -----------------------------------------------------------------------
if nargin < 1
    OUT = [];

    % Draw the color palette as a grid of labeled rectangles
    figure;
    FigSize(30, 20);
    hold on;
    axis off;

    % Compute layout dimensions
    num_colors  = size(col_rgb, 1);
    num_columns = 3;                % columns of color swatches per row
    num_rows    = ceil(num_colors / num_columns);

    % Plot each color as a labeled rectangle.
    % Layout constants (per swatch): column spacing=6, row spacing=1.8,
    % swatch x-offset=0.5, swatch width=1.5, swatch height=1, font size=12.
    for i = 1:num_colors
        col_index = mod(i - 1, num_columns);
        row_index = floor((i - 1) / num_columns);
        xPos = col_index * 6;
        yPos = -row_index * 1.8;
        text(xPos, yPos + 0.5, col_names{i}, 'HorizontalAlignment', 'right', ...
             'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
        rectangle('Position', [xPos + 0.5, yPos, 1.5, 1], ...
                  'FaceColor', col_rgb(i, :), ...
                  'EdgeColor', 'none');
    end

    % Adjust axis limits to fit the full palette
    xlim([-2, num_columns * 6]);
    ylim([-num_rows * 1.8, 1]);
    hold off;

    % Print the table to the command window
    disp(T)

%% 3. COLOR NAME INPUT — RETURN RGB
% -----------------------------------------------------------------------
else
    % Locate the requested color name in the list
    idx = find(strcmp(colorname, col_names));
    if isempty(idx)
        error('pantone: color name ''%s'' does not exist in the palette', colorname)
    end
    OUT = col_rgb(idx, :);
end
