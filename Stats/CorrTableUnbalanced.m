function [CORR, TABLE] = CorrTableUnbalanced(x,vnames)
% =======================================================================
% Computes the pairwise correlation matrix of an unbalanced panel of time
% series (each pair uses only their common non-NaN observations)
% =======================================================================
% [CORR, TABLE] = CorrTableUnbalanced(x,vnames)
% -----------------------------------------------------------------------
% INPUT
%   - x: matrix (rows x cols) [double]
%   - vnames: array (1 x cols) with names of the (cols) series [cell]
% -----------------------------------------------------------------------
% OUTPUT
%   - CORR: correlation matrix [double]
%   - TABLE: table of correlation matrix with titles [cell]
%   Note: mprint also prints CORR as a formatted table to the command
%         window as a side effect.
% -----------------------------------------------------------------------
% EXAMPLE
%   x = randn(50,3);
%   vnames = {'X1','X2','X3'};
%   [CORR, TABLE] = CorrTableUnbalanced(x,vnames);
% =======================================================================
% VAR Toolbox 4.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% First version: March 2015. Updated: 2026-05-31
% -----------------------------------------------------------------------

%% 1. CHECK INPUTS
% -----------------------------------------------------------------------
% Validate required inputs and ensure vnames is a row vector.
if nargin < 2
    error('CorrTableUnbalanced: x and vnames are required inputs.')
end

% vnames must be a row vector
if size(vnames,1)>1
    vnames = vnames';
end

%% 2. COMPUTE PAIRWISE CORRELATIONS
% -----------------------------------------------------------------------
% Each (ii,jj) entry uses only the rows where both series are non-NaN,
% via CommonSample. This handles unbalanced panels where series have
% different start/end dates or internal gaps.
[~, col] = size(x);
CORR = nan(col,col);
for ii=1:col
    x1 = x(:,ii);
    for jj=1:col
        x2 = x(:,jj);
        y = CommonSample([x1 x2]);
        if isempty(y)
            CORR(ii,jj) = NaN;
        else
            aux = corr(y(:,1),y(:,2));
            if isnan(aux)
                if ii==jj
                    CORR(ii,jj) = 1;  % constant series: define self-corr = 1
                else
                    CORR(ii,jj) = NaN; % off-diagonal constant pair: undefined
                end
            else
                CORR(ii,jj) = aux;
            end
        end
    end
end

% Zero out the strictly upper triangle (keep lower triangle and diagonal)
CORR(logical(triu(ones(col), 1))) = NaN;

%% 3. FORMAT AND PRINT OUTPUT TABLE
% -----------------------------------------------------------------------
% Assemble a cell array with variable names as row and column labels,
% then print a formatted version to the command window via mprint.
TAB = num2cell(CORR);
TAB = [vnames ; TAB];          % column headers on top
aux = [{''} vnames]';
TABLE = [aux TAB];             % row labels on the left

% Print formatted table to command window
info.cvnames = char(vnames);
info.rvnames = char([{' '} vnames]);
mprint(CORR,info);
