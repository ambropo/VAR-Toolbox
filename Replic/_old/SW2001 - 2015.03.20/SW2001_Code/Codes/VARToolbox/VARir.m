function [IRF, IRF_opt] = VARir(VAR,nsteps,ident,impact,S)
% =======================================================================
% Compute IRFs for a VAR model estimated with VARmodel. Three
% identification schemes can be specified: zero short-run restrictions,
% zero long run restrictions, and sign restrictions
% =======================================================================
% [IRF IRF_opt] = VARir(VAR,nsteps,ident,impact)
% -----------------------------------------------------------------------
% INPUT
%   - VAR     : structure, result of VARmodel function
%   - nsteps  : number of nsteps to compute the IRFs
%
% OPTIONAL INPUT
%   - ident   : type of identification--> 'oir' (default) for zero 
%               short-run restrictions, 'bq' for zero long-run 
%               restrictions 'sr' for sign restrictions
%   - impact  : size of the shock. 0 for 1stdev (default), 1 for unity
%   - S       : random orthonormal matrix (if sign restriction
%               identification is used) such that S*S'=I
% 
% OUTPUT
%   - IRF(t,j,k) : matrix with 't' steps, the IRF of the 'j' variable for 
%                  the 'k' shock
%   - IRF_opt
%      - IRF_opt.nsteps   : number of steps
%      - IRF_opt.ident    : identification chosen
%      - IRF_opt.impact   : unit or 1 st dev
%      - IRF_opt.invA     : structural matrix such that invA*epsilon = u
%      - IRF_opt.F        : companion matrix
%      - IRF_opt.maxEig   : max eigenvalue of the companion in absolute value
% =======================================================================
% Ambrogio Cesa Bianchi, January 2014
% ambrogio.cesabianchi@gmail.com

% Note. This code follows the notation as in the lecture notes available at
% https://sites.google.com/site/ambropo/MatlabCodes

% Reduced form VAR    -->  Y = F*Y(-1) + u   (PHI is beta_t in the code)
% Structural form VAR --> AY = B*Y(-1) + e     
% Where:
% F = invA*B 
% u = invA*e
% Impulse responses:
% IRF(1) = invA*e          where "e" is impulse in the code
% IRF(j) = H(j)*IRF(1)     where H(j)=H^j and for j=2,...,nsteps



%% Check inputs
%===============================================
if ~exist('impact','var')
    impact = 0;
end

if ~exist('ident','var')
    ident = 'oir';
end

%% Retrieve parameters and preallocate variables
%===============================================
c_case    = VAR.c_case;
nvar      = VAR.neqs;
nlags     = VAR.nlag;
beta      = VAR.beta;
sigma     = VAR.sigma;

IRF = zeros(nsteps,nvar,nvar);

%% Compute the impulse response
%==============================

for mm=1:nvar

    % Compute the companion matrix (check for constant, trend, and/or 
    % exogenous variables and remove them
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
    
    Fn = eye(size(F,1));
      
    % Initialize the impulse response vector
    imp_res = zeros(nvar, nsteps);
    
    % Create the impulse vector
    impulse = zeros(nvar,1); 
    
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
    
    % Set the size of the shock
    if impact==0
        impulse(mm,1) = 1;             % one stdev shock
    elseif impact==1
        impulse(mm,1) = 1/invA(mm,mm); % unitary shock
    else
        error('Impact must be either 0 or 1');
    end

    % First period impulse response (=impulse vector)
    imp_res(:,1) = invA*impulse;
    big_impulse  = [(invA*impulse)' zeros(1, nvar*(nlags-1))]';
    
    % Recursive computation of impulse response
    for kk = 2:nsteps
        Fn = Fn * F; % this is the multiplier F^n
        big_imp_res   = Fn * big_impulse;
        imp_res(:,kk) = big_imp_res(1:nvar);
    end
    IRF(:,:,mm) = imp_res';
end

IRF_opt.nsteps    = nsteps;
IRF_opt.ident     = ident;
IRF_opt.impact    = impact;
IRF_opt.invA      = invA;
IRF_opt.F         = F;
IRF_opt.maxEig    = max(abs(eig(F)));
% IRF_opt.chol_flag = chol_flag;
