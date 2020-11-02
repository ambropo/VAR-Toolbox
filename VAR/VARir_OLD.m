function [IRF, VAR] = VARir_OLD(VAR,VARopt)
% =======================================================================
% Compute IRFs for a VAR model estimated with VARmodel. Three
% identification schemes can be specified: zero short-run restrictions,
% zero long run restrictions, and sign restrictions
% =======================================================================
% [IRF, VAR] = VARir(VAR,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% ----------------------------------------------------------------------- 
% OUTPUT
%   - IRF(t,j,k): matrix with 't' steps, containing the IRF of 'j' variable 
%       to 'k' shock
%   - VAR: structure including VAR estimation results. Not here that the 
%       struicture VAR is an output of VARmodel. This fucntion adds to VAR
%       some additional results, e.g. VAR.B is the strcutral impact matrix
% =======================================================================
% Ambrogio Cesa Bianchi, March 2017
% ambrogio.cesabianchi@gmail.com

% Note. This code follows the notation as in the lecture notes available at
% https://sites.google.com/site/ambropo/MatlabCodes

% Specifically if Y, u, and e are [NxT] matrices, the following is true:
% Reduced form VAR    -->  Y = F*Y(-1) + u    (F => Ft' from VARmodel function) 
% Structural form VAR -->  Y = F*Y(-1) + Be     

% Where:
% 	u = B*e  -->  e = inv(B)*u  -->  e = IRF.B\transpose(VAR.residuals);

% Impulse responses:
% IRF(1) = B*e          where "e" is impulse in the code
% IRF(j) = H(j)*IRF(1)  where H(j)=H^j and for j=2,...,nsteps



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
impact = VARopt.impact;
shut   = VARopt.shut;
ident  = VARopt.ident;
recurs = VARopt.recurs;
S      = VAR.S;
Fcomp  = VAR.Fcomp;
nvar   = VAR.nvar;
nlag   = VAR.nlag;
sigma  = VAR.sigma;
IRF    = nan(nsteps,nvar,nvar);


%% Compute Wold representation
%==========================================================================
% Initialize Wold multipliers
PSI = zeros(nvar,nvar,nsteps);
% Re-write F matrix to compute multipliers
VAR.Fp = zeros(nvar,nvar,nlag);
I = VAR.const+1;
for ii=1:nsteps
    if ii<=nlag
        VAR.Fp(:,:,ii) = VAR.F(:,I:I+nvar-1);
    else
        VAR.Fp(:,:,ii) = zeros(nvar,nvar);
    end
    I = I + nvar;
end
% Compute multipliers
PSI(:,:,1) = eye(nvar);
for ii=2:nsteps
    jj=1;
    aux = 0;
    while jj<ii
        aux = aux + PSI(:,:,ii-jj)*VAR.Fp(:,:,jj);
        jj=jj+1;
    end
    PSI(:,:,ii) = aux;
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
    Finf_big = inv(eye(length(Fcomp))-Fcomp); % from the companion
    Finf = Finf_big(1:nvar,1:nvar);
    D  = chol(Finf*sigma*Finf')'; % identification: u2 has no effect on y1 in the long run
    B = Finf\D;
elseif strcmp(ident,'sr')
    [out, chol_flag] = chol(sigma);
    if chol_flag~=0; error('VCV is not positive definite'); end
    if isempty(S); error('Rotation matrix is not provided'); end
    B = (out')*(S');
end
% Update VAR with structural impact matrix
VAR.B = B;   


%% Compute the impulse response
%==========================================================================
for mm=1:nvar
    % Set to zero a row of the companion matrix if "shut" is selected
    if shut~=0
        Fcomp(shut,:) = 0;
    end
    % Initialize the impulse response vector
    response = zeros(nvar, nsteps);
    % Create the impulse vector
    impulse = zeros(nvar,1); 
    % Set the size of the shock
    if impact==0
        impulse(mm,1) = 1; % one stdev shock
    elseif impact==1
        impulse(mm,1) = 1/B(mm,mm); % unitary shock
    else
        error('Impact must be either 0 or 1');
    end
    % First period impulse response (=impulse vector)
    response(:,1) = B*impulse;
    % Shut down the response if "shut" is selected
    if shut~=0
        response(shut,1) = 0;
    end
    % Recursive computation of impulse response
    if strcmp(recurs,'wold')
        for kk = 2:nsteps
            response(:,kk) = PSI(:,:,kk)*B*impulse;
        end
    elseif strcmp(recurs,'comp')
        for kk = 2:nsteps
            FcompN = Fcomp^(kk-1);
            response(:,kk) = FcompN(1:nvar,1:nvar)*B*impulse;
        end
    end
    IRF(:,:,mm) = response';
end



