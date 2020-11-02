function [FEVD, VAR] = VARfevd(VAR,VARopt)
% =======================================================================
% Compute FEVDs for a VAR model estimated with VARmodel. Three
% identification schemes can be specified: zero short-run restrictions,
% zero long run restrictions, and sign restrictions
% =======================================================================
% [FEVD, VAR] = VARfevd(VAR,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% -----------------------------------------------------------------------
% OUTPUT
%	- FEVD(t,j,k): matrix with 't' steps, the FEVD due to 'j' shock for 
%       'k' variable
%   - VAR: structure including VAR estimation results
%       * VAR.invA: identified contemporaneous A matrix
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogio.cesabianchi@gmail.com

% I thank Dora Xia for pointing out a typo in the above description.


%% Check inputs
%==========================================================================
if ~exist('VAR','var')
    error('You need to provide VAR structure, result of VARmodel');
end
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end


%% Retrieve and initialize variables 
%==========================================================================
nsteps = VARopt.nsteps;
ident  = VARopt.ident;
S      = VAR.S;
Fcomp  = VAR.Fcomp;
nvar   = VAR.nvar;
sigma  = VAR.sigma;
MSE    = zeros(nvar,nvar,nsteps);
MSE_j  = zeros(nvar,nvar,nsteps);
PSI    = zeros(nvar,nvar,nsteps);
FEVD   = zeros(nsteps,nvar,nvar);
SE     = zeros(nsteps,nvar);


%% Compute the multipliers
%==========================================================================
VARjunk = VAR;
VARjunk.sigma = eye(nvar);
IRFjunk = VARir(VARjunk,VARopt);

% this loop is to save the multipliers for each period. Smart way of
% computing multipliers when nlag>1 (if nlag=1, this is equivalent to F^n)
for mm = 1:nvar
    PSI(:,mm,:) = reshape(IRFjunk(:,:,mm)',1,nvar,nsteps);
end

%% Calculate the contribution to the MSE for each shock (i.e, FEVD)
%==========================================================================
sigmacomp = [sigma zeros(nvar*(VAR.nlag-1),nvar); zeros(nvar*(VAR.nlag-1)) zeros(nvar*(VAR.nlag-1),nvar)];
for mm = 1:nvar % loop for the shocks
    
    Fcomp_eye = eye(size(Fcomp,1));
    % Calculate variance of the forecast errors  (kk steps ahead)
    MSE(:,:,1) = sigma;
    MSEalt(:,:,1) = sigmacomp;
    for kk = 2:nsteps;
       MSE(:,:,kk) = MSE(:,:,kk-1) + PSI(:,:,kk)*sigma*PSI(:,:,kk)';
       Fcomp_eye = Fcomp_eye * Fcomp;
       MSEalt(:,:,kk) = MSEalt(:,:,kk-1) + Fcomp_eye*sigmacomp*Fcomp_eye';
    end
    %MSEalt = MSEalt(1:nvar,1:nvar,:);
    
    % Get the matrix invA containing the structural impulses
    if strcmp(ident,'oir')
        [out, chol_flag] = chol(sigma);
        if chol_flag~=0; error('VCV is not positive definite'); end
        invA = out';
    elseif strcmp(ident,'bq')
        Finf_big = inv(eye(length(Fcomp))-Fcomp);   % from the companion
        Finf     = Finf_big(1:nvar,1:nvar);
        D        = chol(Finf*sigma*Finf')'; % identification: u2 has no effect on y1 in the long run
        invA = Finf\D;
    elseif strcmp(ident,'sr')
        [out, chol_flag] = chol(sigma);
        if chol_flag~=0; error('VCV is not positive definite'); end
        if isempty(S); error('Rotation matrix is not provided'); end
        invA = (out')*(S');
    end
    
    % Get the column of invA corresponding to the mm_th shock
    column = invA(:,mm);
    
    % Compute the mean square error
    MSE_j(:,:,1) = column*column';
    Fcomp_eye = eye(size(Fcomp,1));
    BBcomp = [column*column' zeros(nvar*(VAR.nlag-1),nvar); zeros(nvar*(VAR.nlag-1)) zeros(nvar*(VAR.nlag-1),nvar)];
    MSE_altj(:,:,1) = BBcomp;
    for kk = 2:nsteps
        MSE_j(:,:,kk) = MSE_j(:,:,kk-1) + PSI(:,:,kk)*(column*column')*PSI(:,:,kk)';   
        Fcomp_eye = Fcomp_eye * Fcomp;
        MSE_altj(:,:,kk) = MSE_altj(:,:,kk-1) + Fcomp_eye*BBcomp*Fcomp_eye';
    end

    % Compute the Forecast Error Covariance Decomposition
    FECD = MSE_j./MSE;
    FECDalt = MSE_altj(1:nvar,1:nvar,:)./MSEalt(1:nvar,1:nvar,:);
    
    % Select only the variance terms
    for nn = 1:nsteps
        for ii = 1:nvar
            FEVD(nn,mm,ii) = 100*FECD(ii,ii,nn);
            FEVDalt(nn,mm,ii) = 100*FECDalt(ii,ii,nn);
            SE(nn,:) = sqrt( diag(MSE(:,:,nn))' );
        end
    end
end

% Update VARopt
VAR.invA = invA;



