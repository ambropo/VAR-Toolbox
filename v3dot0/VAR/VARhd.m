function [HD, VAR] = VARhd(VAR,VARopt)
% =======================================================================
% Compute the historical decomposition of the time series in a VAR
% estimated with VARmodel and identified with VARir/VARfevd
% =======================================================================
% HD = VARhd(VAR)
% -----------------------------------------------------------------------
% INPUTS 
%   - VAR: structure, result of VARmodel -> VARir/VARfevd function
%   - VARopt: options of the VAR (result of VARmodel.m)
% -----------------------------------------------------------------------
% OUTPUT
%   - HD: structure including the historical decomposition
% -----------------------------------------------------------------------
% EXAMPLE
%   - See VARToolbox_Code.m in "../Primer/"
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


% I thank Andrey Zubarev for finding a bug in the contribution of the 
% exogenous variables when nvar_ex~=0 and nlag_ex>0. 


%% Check inputs
%==========================================================================
if ~exist('VAR','var')
    error('You need to provide VAR structure, result of VARmodel');
end
IV = VAR.IV;
if strcmp(VARopt.ident,'iv')
    disp('---------------------------------------------')
    disp('Historical decomposition not available with')
    disp('external instruments identification (iv)');
    disp('---------------------------------------------')
    error('ERROR. See details above');
end


%% Retrieve and initialize variables 
%==========================================================================
sigma   = VAR.sigma;                      % VCV matrix of the VAR 
Fcomp   = VAR.Fcomp;                      % Companion matrix
const   = VAR.const;                      % constant and/or trends
F       = VAR.Ft';                        % make comparable to notes
nvar    = VAR.nvar;                       % number of endogenous variables
nvar_ex = VAR.nvar_ex;                    % number of exogenous (excluding constant and trend)
nvarXeq = VAR.nvar * VAR.nlag;            % number of lagged endogenous per equation
nlag    = VAR.nlag;                       % number of lags 
nlag_ex = VAR.nlag_ex;                    % number of lags of the exogenous 
Y       = VAR.Y;                          % left-hand side
X       = VAR.X(:,1+const:nvarXeq+const); % right-hand side (no exogenous)
nobs    = size(Y,1);                      % number of observations


%% Identification: Recover B matrix
%==========================================================================
% B matrix is recovered with Cholesky decomposition
if strcmp(VARopt.ident,'short')
    [out, chol_flag] = chol(sigma);
    if chol_flag~=0; error('VCV is not positive definite'); end
    B = out';
% B matrix is recovered with Cholesky on cumulative IR to infinity
elseif strcmp(VARopt.ident,'long')
    Finf_big = inv(eye(length(Fcomp))-Fcomp); % from the companion
    Finf = Finf_big(1:nvar,1:nvar);
    D  = chol(Finf*sigma*Finf')'; % identification: u2 has no effect on y1 in the long run
    B = Finf\D;
% B matrix is recovered with SR.m
elseif strcmp(VARopt.ident,'sign')
    if isempty(VAR.B)
        error('You need to provide the B matrix with SR.m and/or SignRestrictions.m')
    else
        B = VAR.B;
    end
% B matrix is recovered with external instrument IV
elseif strcmp(VARopt.ident,'iv')
    disp('---------------------------------------------')
    disp('Forecast error variance decomposition not available with')
    disp('external instruments identification (iv)');
    disp('---------------------------------------------')
    error('ERROR. See details above');
% If none of the above, you've done something wrong :)    
else
    disp('---------------------------------------------')
    disp('Identification incorrectly specified.')
    disp('Choose one of the following options:');
    disp('- short: zero contemporaneous restrictions');
    disp('- long:  zero long-run restrictions');
    disp('- sign:  sign restrictions');
    disp('- iv:    external instrument');
    disp('---------------------------------------------')
    error('ERROR. See details above');
end


%% Compute historical decompositions
%==========================================================================

% Contribution of each shock
eps = B\transpose(VAR.resid); % structural errors 
B_big = zeros(nvarXeq,nvar);
B_big(1:nvar,:) = B;
Icomp = [eye(nvar) zeros(nvar,(nlag-1)*nvar)];
HDshock_big = zeros(nlag*nvar,nobs+1,nvar);
HDshock = zeros(nvar,nobs+1,nvar);
for j=1:nvar % for each variable
    eps_big = zeros(nvar,nobs+1); % matrix of shocks conformable with companion
    eps_big(j,2:end) = eps(j,:);
    for i = 2:nobs+1
        HDshock_big(:,i,j) = B_big*eps_big(:,i) + Fcomp*HDshock_big(:,i-1,j);
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
if const>1
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
if const>2
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
if nvar_ex>0
    for ii=1:nvar_ex
        VARexo = VAR.X_EX(:,ii);
        EXO(1:nvar,ii) = F(:,nvar*nlag+const+ii); % this is c in my notes
        for i = 2:nobs+1
            HDexo_big(:,i) = EXO(:,ii)*VARexo(i-1,:)' + Fcomp*HDexo_big(:,i-1);
            HDexo(:,i,ii) = Icomp * HDexo_big(:,i);
        end
    end
end

% All decompositions must add up to the original data
HDendo = HDinit + HDconst + HDtrend + HDtrend2 + sum(HDexo,3) + sum(HDshock,3);
    
    
    
%% Save and reshape all HDs
%==========================================================================
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
HD.exo    = zeros(nobs+nlag,nvar,nvar_ex);           % [nobs x var x var_ex]
    for i=1:nvar_ex
        HD.exo(:,:,i) = [nan(nlag,nvar);   HDexo(:,2:end,i)'];
    end
HD.endo   = [nan(nlag,nvar);   HDendo(:,2:end)'];    % [nobs x var]

% Update VAR with structural impact matrix
VAR.B = B; 

