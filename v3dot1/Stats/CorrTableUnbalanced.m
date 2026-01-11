function [CORR, TABLE] = CorrTableUnbalanced(x,vnames)
% =======================================================================
% Computes the correlation matrix of a matrix of time series with titles
% =======================================================================
% out = CorrTable(x,vnames)
% -----------------------------------------------------------------------
% INPUT
%   - x: matrix (rows x cols) [double]
%   - vnames: array (1 x cols) with names of the (cols) series [cell]
% -----------------------------------------------------------------------
% OUTPUT
%   - CORR: correlation matrix [double]
%   - TABLE: table of correlation matrix with titles [cell]
% -----------------------------------------------------------------------
% EXAMPLE
%   x = rand(50,2);
%   [CORR, TABLE] = CorrTableUnbalanced(x,{'Consumption','Investment'})
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2015. Updated November 2020
% -----------------------------------------------------------------------


% vnames must be a row vector
if size(vnames,1)>1
    vnames = vnames';
end

% Compute the correlation matrix using the maximum amount of avaliable obs
[row , col] = size(x);
CORR = nan(col,col);
for ii=1:col
    x1 = x(:,ii);
    for jj=1:col
        x2 = x(:,jj);
        y = CommonSample([x1 x2]);
        if isempty(y) == 1
            CORR(ii,jj) = NaN;
        else
            aux = corr(y(:,1),y(:,2));
            if isnan(aux)==1
                if ii==jj
                    CORR(ii,jj) = 1;
                end
            else
                CORR(ii,jj) = corr(y(:,1),y(:,2));
            end
        end
    end
end

% Place NaNs on the uuper triangular
CORR(find(triu(CORR))) = NaN;
jj = 1;
for ii=1:col
    CORR(ii,jj) = 1;
    jj = jj +1;
end

% Transform table into cell array
table = num2cell(CORR);

% Add vnames on top
table = [vnames ; table];

% Add vnames on the left
aux = [{''} vnames]';
TABLE = [aux table];

% Print using mprint
info.cvnames = char(vnames);
info.rvnames = char([{' '} vnames]);
mprint(CORR,info);