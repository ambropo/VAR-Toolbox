function [VD, VAR] = VARvd(VAR,VARopt)
% =======================================================================
% Compute forecast error variance decompositions (VDs) for a VAR model 
% estimated with the VARmodel.m function. Three identification schemes can 
% be specified: zero contemporaneous restrictions, zero long-run 
% restrictions, and sign restrictions
% =======================================================================
% [VD, VAR] = VARvd(VAR,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel.m
%   - VARopt: options of the VAR (result of VARmodel.m)
% -----------------------------------------------------------------------
% OUTPUT
%	- VD(:,:,:): matrix with FEVDs (H horizons, N shocks, N variables)
%   - VAR: structure including VAR estimation results
%       * VAR.B: strcutral impact matrix
% -----------------------------------------------------------------------
% EXAMPLE
%   - See VARToolbox_Code.m in "../Primer/"
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% March 2012. Updated November 2020
% -----------------------------------------------------------------------


%% Check inputs
%==========================================================================
if ~exist('VAR','var')
    error('You need to provide VAR structure, result of VARmodel');
end
IV = VAR.IV;
if strcmp(VARopt.ident,'iv')
    disp('---------------------------------------------')
    disp('Forecast error variance decomposition not available with')
    disp('external instruments identification (iv)');
    disp('---------------------------------------------')
    error('ERROR. See details above');
end


%% Retrieve and initialize variables 
%==========================================================================
nsteps = VARopt.nsteps;
ident  = VARopt.ident;
Fcomp  = VAR.Fcomp;
nlag   = VAR.nlag;
nvar   = VAR.nvar;
sigma  = VAR.sigma;
VD     = zeros(nsteps,nvar,nvar);
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


%% Identification: Recover B matrix
%==========================================================================
% B matrix is recovered with Cholesky decomposition
if strcmp(ident,'short')
    [out, chol_flag] = chol(sigma);
    if chol_flag~=0; error('VCV is not positive definite'); end
    B = out';
% B matrix is recovered with Cholesky on cumulative IR to infinity
elseif strcmp(ident,'long')
    Finf_big = inv(eye(length(Fcomp))-Fcomp); % from the companion
    Finf = Finf_big(1:nvar,1:nvar);
    D  = chol(Finf*sigma*Finf')'; % identification: u2 has no effect on y1 in the long run
    B = Finf\D;
% B matrix is recovered with SR.m
elseif strcmp(ident,'sign')
    if isempty(VAR.B)
        error('You need to provide the B matrix with SR.m and/or SignRestrictions.m')
    else
        B = VAR.B;
    end
% B matrix is recovered with external instrument IV
elseif strcmp(ident,'iv')
    disp('---------------------------------------------')
    disp('Forecast error variance decomposition not available yet ')
    disp('with external instruments identification (iv)');
    disp('---------------------------------------------')
    error('ERROR. See details above');
% If none of the above, you've done somerthing wrong :)    
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


%% Calculate the contribution to the MSE for each shock (i.e, VD)
%==========================================================================
for ii = 1:nvar % loop for the shocks
    
    % The 1-step ahead variance of the forecast error is the variance of 
    % the residulas (sigma).
    MSE(:,:,1) = sigma;
    for nn = 2:nsteps
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
            VD(nn,ii,kk) = 100*FECD(kk,kk,nn);
            SE(nn,:) = sqrt(diag(MSE(1:nvar,1:nvar,nn))' );
        end
    end
end

% Update VAR with structural impact matrix
VAR.B = B;   


