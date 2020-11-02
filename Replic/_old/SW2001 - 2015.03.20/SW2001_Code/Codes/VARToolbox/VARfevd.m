function [FEVD, FEVD_opt] = VARfevd(VAR,nsteps,ident,S)
% =======================================================================
% Compute FEVDs for a VAR model estimated with VARmodel. Three
% identification schemes can be specified: zero short-run restrictions,
% zero long run restrictions, and sign restrictions
% =======================================================================
% [FEVD, FEVD_opt] = VARfevd(VAR,nsteps,ident)
% -----------------------------------------------------------------------
% INPUT
%   - VAR     : structure, result of VARmodel function
%   - nsteps  : number of nsteps to compute the IRFs
%
% OPTIONAL INPUT
%   - ident   : type of identification--> 'oir' (default) for zero 
%               short-run restrictions, 'bq' for zero long-run 
%               restrictions 'sr' for sign restrictions
%   - S       : random orthonormal matrix (if sign restriction
%               identification is used) such that S*S'=I
%
% OUTPUT
%   - FEVD(t,j,k) : matrix with 't' steps, the FEVD due to 'j' shock for 
%                   'k' variable
%   - FEVD_opt
%      - FEVD_opt.nsteps  : number of steps
%      - FEVD_opt.ident   : identification chosen
%      - FEVD_opt.SE(t,j) : matrix with 't' steps, standard error of the 'j' variable
%      - FEVD_opt.invA    : structural matrix such that invA*epsilon = u
%      - IRF_opt.F        : companion matrix
%      - IRF_opt.maxEig   : max eigenvalue of the companion in absolute value
% =======================================================================
% Ambrogio Cesa Bianchi, January 2014
% ambrogio.cesabianchi@gmail.com

% I thank Dora Xia for pointing out a typo in the above description.

%% Check inputs
%===============================================
if ~exist('ident','var')
    ident = 'oir';
end

%% Retrieve parameters and preallocate variables
%===============================================
c_case   = VAR.c_case;
nvar     = VAR.neqs;
nlags    = VAR.nlag;
beta     = VAR.beta;
sigma    = VAR.sigma;

MSE   = zeros(nvar,nvar,nsteps);
MSE_j = zeros(nvar,nvar,nsteps);
PSI   = zeros(nvar,nvar,nsteps);
FEVD  = zeros(nsteps,nvar,nvar);
SE    = zeros(nsteps,nvar);


%% Compute the multipliers
%=========================

VARjunk = VAR;
VARjunk.sigma = eye(nvar);

IRFjunk = VARir(VARjunk,nsteps);

% this loop is to save the multipliers for each period
for mm = 1:nvar
    PSI(:,mm,:) = reshape(IRFjunk(:,:,mm)',1,nvar,nsteps);
end

%% Compute the companion matrix (needed for BQ identification)
%============================================================
switch c_case
    case 0
        beta_t = beta';
        F = [beta_t(:,1+c_case:nvar*nlags+c_case)
            eye(nvar*(nlags-1)) zeros(nvar*(nlags-1),nvar)];
    case 1
        beta_t = beta';
        F = [beta_t(:,1+c_case:nvar*nlags+c_case)
            eye(nvar*(nlags-1)) zeros(nvar*(nlags-1),nvar)];
     case 2
        beta_t = beta';
        F = [beta_t(:,1+c_case:nvar*nlags+c_case)
            eye(nvar*(nlags-1)) zeros(nvar*(nlags-1),nvar)];
     case 3
        beta_t = beta';
        F = [beta_t(:,1+c_case:nvar*nlags+c_case)
            eye(nvar*(nlags-1)) zeros(nvar*(nlags-1),nvar)];
end


%% Calculate the contribution to the MSE for each shock (i.e, FEVD)
%==================================================================

for mm = 1:nvar % loop for the shocks
    
    % Calculate Total Mean Squared Error
    MSE(:,:,1) = sigma;

    for kk = 2:nsteps;
       MSE(:,:,kk) = MSE(:,:,kk-1) + PSI(:,:,kk)*sigma*PSI(:,:,kk)';
    end;
    
    % Get the matrix invA containing the structural impulses
    if strcmp(ident,'oir')
        [out, chol_flag] = chol(sigma);
        if chol_flag~=0; error('VCV is not positive definite'); end
        invA = out';
    elseif strcmp(ident,'bq')
        Finf_big = inv(eye(length(F))-F);   % from the companion
        Finf     = Finf_big(1:nvar,1:nvar);
        D        = chol(Finf*sigma*Finf')'; % identification: u2 has no effect on y1 in the long run
        invA = Finf\D;
    elseif strcmp(ident,'sr')
        [out, chol_flag] = chol(sigma);
        if chol_flag~=0; error('VCV is not positive definite'); end
        if ~exist('S','var'); error('Rotation matrix is not provided'); end
        invA = (out')*(S');
    end
    
    % Get the column of invA corresponding to the mm_th shock
    column = invA(:,mm);
    
    % Compute the mean square error
    MSE_j(:,:,1) = column*column';
    for kk = 2:nsteps
        MSE_j(:,:,kk) = MSE_j(:,:,kk-1) + PSI(:,:,kk)*(column*column')*PSI(:,:,kk)';   
    end

    % Compute the Forecast Error Covariance Decomposition
    FECD = MSE_j./MSE;
    
    % Select only the variance terms
    for nn = 1:nsteps
        for ii = 1:nvar
            FEVD(nn,mm,ii) = FECD(ii,ii,nn);
            SE(nn,:) = sqrt( diag(MSE(:,:,nn))' );
        end
    end
end
 
FEVD_opt.nsteps    = nsteps;
FEVD_opt.ident     = ident;
FEVD_opt.SE        = SE;
FEVD_opt.invA      = invA;
FEVD_opt.F         = F;
FEVD_opt.maxEig    = max(abs(eig(F)));
% FEVD_opt.chol_flag = chol_flag;