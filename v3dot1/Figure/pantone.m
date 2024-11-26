function [OUT,T]=pantone(colorname)
%==========================================================================
% This function retrieves RGB color values for given color names from a 
% predefined list of Pantone colors. It can also display the colors in a 
% palette if no input is provided.
%==========================================================================
% [OUT,T]=pantone(colorname)
%--------------------------------------------------------------------------
% OPTIONAL INPUT
%	- colorname: A string representing the name of the color (e.g., 
%     'Plum_Light'). If not provided, the function will display all 
%     available colors.
%--------------------------------------------------------------------------
% OUTPUT
%   - OUT: A 1x3 vector containing the RGB values for the specified color.
%   - T: A table containing the RGB values of all colors with their names.
%--------------------------------------------------------------------------
% EXAMPLE
% pantone; % Displays all colors in a palette.
% OUT = pantone('Plum_Light'); % Retrieves the RGB values for 'Plum_Light'.
%==========================================================================
% VAR Toolbox 3.1
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2024
%--------------------------------------------------------------------------

%% COLORS 
%==========================================================================
% Define a 42x1 cell vector of color names
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
'Salmon';
'Lily';
'Mint';
'Tomato';
};

% Define a 42x3 matrix of color RGB values
col_rgb = [
23, 94, 84;        % PaloAlto
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
190, 174, 212;    % Lily
127, 201, 127;    % Mint
217,83,79;        % Tomato
]./255;

% Create a table with RGB values and color names
T = table(col_rgb, 'VariableNames', {'RGB'}, 'RowNames', col_names);

%% NO INPUT 
%==========================================================================
if nargin < 1  % Check if no input is provided
    OUT = [];  % Initialize output as an empty array
    colorname = '';  % Initialize colorname as an empty string

    % Plot palette
    %----------------------------------------------------------------------
    FigSize(30, 20);  % Set the figure size
    hold on;  % Hold the current figure to plot multiple elements
    axis off;  % Turn off the axis

    % Number of colors and columns
    num_colors = size(col_rgb, 1);  % Get the number of colors
    num_columns = 3;  % Set number of columns for layout
    num_rows = ceil(num_colors / num_columns);  % Calculate number of rows

    % Loop through each color and display as a smaller rectangle with 
    % larger text
    for i = 1:num_colors
        % Calculate the position for each color square
        col_index = mod(i - 1, num_columns);  % Column index
        row_index = floor((i - 1) / num_columns);  % Row index
        
        % Position each color block and label
        xPos = col_index * 6;  % Space each column by 6 units
        yPos = -row_index * 1.8;  % Space each row by 1.8 units
        
        % Add text label with color name to the left of each rectangle
        text(xPos, yPos + 0.5, col_names{i}, 'HorizontalAlignment', 'right', ...
             'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
        
        % Plot each color as a smaller rectangle to the right of the text
        rectangle('Position', [xPos + 0.5, yPos, 1.5, 1], ...
                  'FaceColor', col_rgb(i, :), ...
                  'EdgeColor', 'none');
    end

    % Adjust figure limits for better layout
    xlim([-2, num_columns * 6]);  % Set x-axis limits
    ylim([-num_rows * 1.8, 1]);  % Set y-axis limits
    hold off;  % Release the hold on the current figure

    % Display the table of colors
    %----------------------------------------------------------------------
    disp(T)

%% COLOR NAME INPUT 
%==========================================================================
else 
    idx = find(strcmp(colorname, col_names));  % Find the index of the input color name
    if sum(idx) == 0  % Check if the color name does not exist
        error('Color name provided does not exist');  % Display error message
    end
    OUT = col_rgb(idx, :);  % Retrieve RGB values for the specified color
end
