function [CORR, OUT] = CorrUnbalanced(DATA,labels)
% =======================================================================
% Compute correlation of a panel of time series DATA (with T 
% observations and N variables) using rows with no missing values in 
% column i or j. 
% 
% note: for each pair of columns, the correlation is computed using the
% maximum amount of available observations. This is to deal with 
% unbalanced panels. Therefore, NaN are accepted.
% =======================================================================
% [CORR, OUT] = CorrUnbalanced(DATA,labels)
% -----------------------------------------------------------------------
% INPUT
%	- DATA: matrix DATA T (observations) x N (variables)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - labels: Default "Variable", names of each variable j
% -----------------------------------------------------------------------
% OUPUT
%	- CORR: matrix of correlation N x N 
%	- OUT.N: number of observations used for each pair
%	- OUT.table: formatted table of correlation matrix with titles
% -----------------------------------------------------------------------
% EXAMPLE
%   DATA = rand(50,4);
%   [CORR, OUT] = CorrUnbalanced(DATA)
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------



%% Preliminaries: define the dimension of the matrix of interest
% =========================================================================
[nobs, nvar] = size(DATA);

% If no names are provided set it to 'Variable'
if ~exist('labels','var')
    labels(1,1:nvar) = {'Variable'};
end

% If labels are entered as jx1 vector, transpose it
if size(labels,1) > 1
    labels = labels';
end

%% Compute pairwise correlation
% =========================================================================
CORR = nan(nvar,nvar);
OUT.N = nan(nvar,nvar);
% Compute the correlation matrix using the maximum amount of avaliable obs
for ii=1:nvar
    X1 = DATA(:,ii);
    for jj=1:nvar
        X2 = DATA(:,jj);
        Y = CommonSample([X1 X2]);
        if isempty(Y)
            CORR(ii,jj) = NaN;
            OUT.N(ii,jj) = 0;
        else
            aux = corr(Y(:,1),Y(:,2));
            OUT.N(ii,jj) = length(Y);
            % This is to take into account that if there is no variation in
            % the data, corr(x,y) yields NaN. If that happens the pairwise
            % correlation is set to zero. (February 2013)
            if isnan(aux)
                if ii==jj
                    CORR(ii,jj) = 1; % Even if there is no variation the corr of each column with itself is seto to 1
                else
                    CORR(ii,jj) = NaN;
                end
            else
                CORR(ii,jj) = aux;
            end
        end
    end
end



% %Write the table in PairCorr.xls with titles
% title = {'' , 'Level', 'First Diff.'};
% TABLE = [labels  ; num2cell(PC')];
% TABLE = [title ; TABLE'];
