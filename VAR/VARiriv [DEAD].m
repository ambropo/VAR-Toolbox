function [IR, VAR] = VARiriv(VAR,VARopt)
% =======================================================================
% Compute IRFs for a VAR model estimated with VARmodel using the external 
% instrument approach of Stock and Watson (2012) and Mertens and Ravn
% (2013). 
% =======================================================================
% [IRF, IVout] = VARiriv(VAR,VARopt,IV)
% -----------------------------------------------------------------------
% INPUTS 
%   - VAR: structure, result of VARmodel function
%   - VARopt: options of the VAR (see VARopt from VARmodel)
%   - IV is a (vector) instrumental variable correlated with the shock of
%       interest and uncorrelated with the other shocks
% ----------------------------------------------------------------------- 
% OUTPUT
%   - IRF(t,j): matrix with 't' steps, containing the IRF of 'j' variable 
%       to one identified shock
%   - IVout: first-stage and second stage results from the IV
%       identification
% =======================================================================
% Ambrogio Cesa Bianchi, March 2017
% ambrogio.cesabianchi@gmail.com



%% Check inputs
%===============================================
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end
IV = VARopt.IV;
if isempty(IV)
    error('You need to provide the data for the instrument in VARopt (IV)');
end

%% Retrieve and initialize variables 
%=============================================================
nsteps = VARopt.nsteps;
shut   = VARopt.shut;


%% Instrumental variable - First stage
%=========================================================
nvar = VAR.nvar;
nlag = VAR.nlag;

% Recover residuals (order matter!)
up = VAR.resid(:,1);     % is the shock that I want to identify
uq = VAR.resid(:,2:end); % other shocks

% Make sample of IV comparable with up and uq
[aux, fo, lo] = CommonSample([up IV(VAR.nlag+1:end,:)]);
p = aux(:,1);
q = uq(end-length(p)+1:end,:);
Z = aux(:,2:end);

% Run first stage regression and fitted
OLSout = OLSmodel(p,Z,1);
p_hat = OLSout.yhat;


%% IR on impact - Second Stage
%=========================================================
IR(1,1) = 1;
for ii=2:nvar
    second = OLSmodel(q(:,ii-1),p_hat,0);
    IR(ii,1) = second.beta;
end
if shut~=0
    IR(shut,1) = 0;
end

%% Compute Wold representation
%===============================================
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
VAR.PSI = PSI;


%% IR dynamics
%=========================================================
% Iterate forward with Wold multipliers
for ii=2:nsteps
    IR(:,ii) = PSI(:,:,ii)*IR(:,1);
end

% Get IR from big_IR
IR = IR(1:nvar,:)';


%% Save
%=========================================================
VAR.IVfirst = OLSout;
aux = [nan(VAR.nlag,1); nan(fo,1); p_hat];
VAR.IVfitted = aux;
VAR.IVfstat = OLSout.F;
VAR.IVrsqr = OLSout.rsqr;
VAR.B = nan(nvar,nvar);
VAR.B(:,1) = IR(1,:)';



