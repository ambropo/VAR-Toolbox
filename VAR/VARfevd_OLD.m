function [FEVD, VAR] = VARfevd_OLD(VAR,VARopt)
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
%       * VAR.B: strcutral impact matrix
% =======================================================================
% Ambrogio Cesa Bianchi, March 2017
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
nlag   = VAR.nlag;
nvar   = VAR.nvar;
sigma  = VAR.sigma;
FEVD   = zeros(nsteps,nvar,nvar);
SE     = zeros(nsteps,nvar);
MSE    = zeros(nvar,nvar,nsteps);
MSE_shock = zeros(nvar,nvar,nsteps);

%% Compute Wold representation
%==========================================================================
% Initialize Wold multipliers
PSI = zeros(nvar,nvar,nsteps);
% Re-write F matrix to compute multipliers
VAR.Fp = zeros(nvar,nvar,nlag);
I = VAR.const+1;
for kk=1:nsteps
    if kk<=nlag
        VAR.Fp(:,:,kk) = VAR.F(:,I:I+nvar-1);
    else
        VAR.Fp(:,:,kk) = zeros(nvar,nvar);
    end
    I = I + nvar;
end
% Compute multipliers
PSI(:,:,1) = eye(nvar);
for kk=2:nsteps
    jj=1;
    aux = 0;
    while jj<kk
        aux = aux + PSI(:,:,kk-jj)*VAR.Fp(:,:,jj);
        jj=jj+1;
    end
    PSI(:,:,kk) = aux;
end
% Update VAR with Wold multipliers
VAR.PSI = PSI;


%% Identification
%==========================================================================
% Get the matrix B containing the structural impulses
if strcmp(ident,'oir')
    [out, chol_flag] = chol(sigma);
    if chol_flag~=0; error('VCV is not positive definite'); end
    B = out';
elseif strcmp(ident,'bq')
    Finf_big = inv(eye(length(Fcomp))-Fcomp);   % from the companion
    Finf     = Finf_big(1:nvar,1:nvar);
    D        = chol(Finf*sigma*Finf')'; % identification: u2 has no effect on y1 in the long run
    B = Finf\D;
elseif strcmp(ident,'sr')
    [out, chol_flag] = chol(sigma);
    if chol_flag~=0; error('VCV is not positive definite'); end
    if isempty(S); error('Rotation matrix is not provided'); end
    B = (out')*(S');
end
% Update VAR with structural impact matrix
VAR.B = B;   


%% Calculate the contribution to the MSE for each shock (i.e, FEVD)
%==========================================================================
for ii = 1:nvar % loop for the shocks
    
    % The 1-step ahead variance of the forecast error is the variance of 
    % the residulas (sigma).
    MSE(:,:,1) = sigma;
    for nn = 2:nsteps;
        MSE(:,:,nn) = MSE(:,:,nn-1) + PSI(:,:,nn)*sigma*PSI(:,:,nn)';
    end
    % The 1-step ahead variance of the mm^th structural forecast error is 
    % the square of the mm^th column of the structural impact matrix (B)
    MSE_shock(:,:,1) = B(:,ii)*B(:,ii)';
    for nn = 2:nsteps
        MSE_shock(:,:,nn) = MSE_shock(:,:,nn-1) + PSI(:,:,nn)*MSE_shock(:,:,1)*PSI(:,:,nn)';
    end

    % Compute the Forecast Error Covariance Decomposition
    FECD = MSE_shock(1:nvar,1:nvar,:)./MSE(1:nvar,1:nvar,:);

    % Select only the variance terms
    for nn = 1:nsteps
        for kk = 1:nvar
            FEVD(nn,ii,kk) = 100*FECD(kk,kk,nn);
            SE(nn,:) = sqrt(diag(MSE(1:nvar,1:nvar,nn))' );
        end
    end
end



