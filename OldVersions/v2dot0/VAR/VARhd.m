function HD = VARhd(VAR)
% =======================================================================
% Compute the historical decomposition of the time series in a VAR
% estimated with VARmodel and identified with VARir/VARfevd
% =======================================================================
% HD = VARhd(VAR)
% -----------------------------------------------------------------------
% INPUTS 
%   - VAR: structure, result of VARmodel -> VARir/VARfevd function
% -----------------------------------------------------------------------
% OUTPUT
%   - HD: structure including the historical decomposition
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% I thank Andrey Zubarev for finding a bug in the contribution of the 
% exogenous variables when nvar_ex~=0 and nlag_ex>0. 


%% Check inputs
%===============================================
if ~exist('VAR','var')
    error('You need to provide VAR structure, result of VARmodel');
end
% If there is VAR check that the inverse of the A matrix is not empty
invA = VAR.invA;
if isempty(invA)
    error('You need to identify the VAR before running VARhd. Run VARir/VARfevd first.');
end

%% Retrieve and initialize variables 
%===============================================
Fcomp   = VAR.Fcomp;                      % Companion matrix
const   = VAR.const;                      % constant and/or trends
F       = VAR.Ft';                        % make comparable to notes
eps     = invA\transpose(VAR.residuals);  % structural errors 
nvar    = VAR.nvar;                       % number of endogenous variables
nvar_ex = VAR.nvar_ex;                    % number of exogenous (excluding constant and trend)
nvarXeq = VAR.nvar * VAR.nlag;            % number of lagged endogenous per equation
nlag    = VAR.nlag;                       % number of lags 
nlag_ex = VAR.nlag_ex;                    % number of lags of the exogenous 
Y       = VAR.Y;                          % left-hand side
X       = VAR.X(:,1+const:nvarXeq+const); % right-hand side (no exogenous)
nobs    = size(Y,1);                      % number of observations


%% Compute historical decompositions
%===============================================

% Contribution of each shock
    invA_big = zeros(nvarXeq,nvar);
    invA_big(1:nvar,:) = invA;
    Icomp = [eye(nvar) zeros(nvar,(nlag-1)*nvar)];
    HDshock_big = zeros(nlag*nvar,nobs+1,nvar);
    HDshock = zeros(nvar,nobs+1,nvar);
    for j=1:nvar; % for each variable
        eps_big = zeros(nvar,nobs+1); % matrix of shocks conformable with companion
        eps_big(j,2:end) = eps(j,:);
        for i = 2:nobs+1
            HDshock_big(:,i,j) = invA_big*eps_big(:,i) + Fcomp*HDshock_big(:,i-1,j);
            HDshock(:,i,j) =  Icomp*HDshock_big(:,i,j);
        end
    end
    
% Initial value
    HDinit_big = zeros(nlag*nvar,nobs+1);
    HDinit = zeros(nvar, nobs+1);
    HDinit_big(:,1) = X(1,:)';
    HDinit(:,1) = Icomp*HDinit_big(:,1);
    for i = 2:nobs+1
        HDinit_big(:,i) = Fcomp*HDinit_big(:,i-1);
        HDinit(:,i) = Icomp *HDinit_big(:,i);
    end
    
% Constant
    HDconst_big = zeros(nlag*nvar,nobs+1);
    HDconst = zeros(nvar, nobs+1);
    CC = zeros(nlag*nvar,1);
    if const>0
        CC(1:nvar,:) = F(:,1);
        for i = 2:nobs+1
            HDconst_big(:,i) = CC + Fcomp*HDconst_big(:,i-1);
            HDconst(:,i) = Icomp * HDconst_big(:,i);
        end
    end
    
% Linear trend
    HDtrend_big = zeros(nlag*nvar,nobs+1);
    HDtrend = zeros(nvar, nobs+1);
    TT = zeros(nlag*nvar,1);
    if const>1;
        TT(1:nvar,:) = F(:,2);
        for i = 2:nobs+1
            HDtrend_big(:,i) = TT*(i-1) + Fcomp*HDtrend_big(:,i-1);
            HDtrend(:,i) = Icomp * HDtrend_big(:,i);
        end
    end
    
% Quadratic trend
    HDtrend2_big = zeros(nlag*nvar, nobs+1);
    HDtrend2 = zeros(nvar, nobs+1);
    TT2 = zeros(nlag*nvar,1);
    if const>2;
        TT2(1:nvar,:) = F(:,3);
        for i = 2:nobs+1
            HDtrend2_big(:,i) = TT2*((i-1)^2) + Fcomp*HDtrend2_big(:,i-1);
            HDtrend2(:,i) = Icomp * HDtrend2_big(:,i);
        end
    end

% Exogenous
    HDexo_big = zeros(nlag*nvar,nobs+1);
    HDexo = zeros(nvar,nobs+1);
    EXO = zeros(nlag*nvar,nvar_ex*(nlag_ex+1));
    if nvar_ex>0;
        VARexo = VAR.X_EX;
        EXO(1:nvar,:) = F(:,nvar*nlag+const+1:end); % this is c in my notes
        for i = 2:nobs+1
            HDexo_big(:,i) = EXO*VARexo(i-1,:)' + Fcomp*HDexo_big(:,i-1);
            HDexo(:,i) = Icomp * HDexo_big(:,i);
        end
    end

% All decompositions must add up to the original data
HDendo = HDinit + HDconst + HDtrend + HDtrend2 + HDexo + sum(HDshock,3);
    
    
    
%% Save and reshape all HDs
%===============================================
HD.shock = zeros(nobs+nlag,nvar,nvar);  % [nobs x shock x var]
    for i=1:nvar
        for j=1:nvar
            HD.shock(:,j,i) = [nan(nlag,1); HDshock(i,2:end,j)'];
        end
    end
HD.init   = [nan(nlag-1,nvar); HDinit(:,1:end)'];    % [nobs x var]
HD.const  = [nan(nlag,nvar);   HDconst(:,2:end)'];   % [nobs x var]
HD.trend  = [nan(nlag,nvar);   HDtrend(:,2:end)'];   % [nobs x var]
HD.trend2 = [nan(nlag,nvar);   HDtrend2(:,2:end)'];  % [nobs x var]
HD.exo    = [nan(nlag,nvar);   HDexo(:,2:end)'];     % [nobs x var]
HD.endo   = [nan(nlag,nvar);   HDendo(:,2:end)'];    % [nobs x var]

