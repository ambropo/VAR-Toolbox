function [INF,SUP,MED] = VARirband(VAR,IRF_opt,ndraws,pctg,method)
% =======================================================================
% Calculates confidence intervals for impulse response functions computed
% with VARir
% =======================================================================
% [INF,SUP,MED] = VARirband(VAR,IRF_opt,ndraws,method)
% -----------------------------------------------------------------------
% INPUTS 
%   VAR     = VAR results obtained with VARmodel (structure)
%	IRF_opt = options of the IRFs (is the output of VARir)
%
% OPTIONAL INPUTS
%   ndraws    = number of draws for boostrapping [default 100]
%   pctg      = confidence level [default 90]
%   method    = 'bs' for Bootstrapping [default 'bs']
%
% OUTPUT
%   INF(t,j,k) = lower confidence band (t steps, j variable, k shock)
%   SUP(t,j,k) = upper confidence band (t steps, j variable, k shock)
%   MED(t,j,k) = median response (t steps, j variable, k shock)
% =======================================================================
% Ambrogio Cesa Bianchi, November 2012
% ambrogio.cesabianchi@gmail.com




%% Retrieve some parameters from the structure VAR and IRF_opt
%=============================================================

nsteps = IRF_opt.nsteps;
impact = IRF_opt.impact;
ident  = IRF_opt.ident;

beta     = VAR.beta;  % rows are coefficients, columns are equations
nvars    = VAR.neqs;
nvar_ex  = VAR.nvar_ex;
nlags    = VAR.nlag;
c_case   = VAR.c_case;
nobs     = VAR.nobs;
Y        = VAR.Y;
resid    = VAR.residuals;
if nvar_ex~=0
    exog     = VAR.X_EX;
end

%% Check inputs 
%============================

if ~exist('ndraws','var')
    ndraws = 100;
end

if ~exist('pctg','var')
    pctg = 90;
end

if ~exist('method','var')
    method = 'bs';
end

INF = zeros(nsteps,nvars,nvars);
SUP = zeros(nsteps,nvars,nvars);
MED = zeros(nsteps,nvars,nvars);

%% Create the matrices for the loop
%==================================

y_artificial = zeros(nobs,nvars);


%% Loop over the number of draws, generate data, estimate the var and then 
%% calculate impulse response functions
%==========================================================================

for tt=1:ndraws
    disp(['Loop ' num2str(tt) ' / ' num2str(ndraws) ' draws'])

%% STEP 1: choose the method (Monte Carlo or Bootstrap) and generate the 
%% residuals
    if strcmp(method,'bs')
        % Use the residuals to bootstrap: generate a random number bounded 
        % between 0 and # of residuals, then use the ceil function to select 
        % that row of the residuals (this is equivalent to sampling with replacement)
        u = resid(ceil(size(resid,1)*rand(nobs,1)),:);
    else
        error(['The method ' method ' is not available'])
    end

%% STEP 2: generate the artifcial data

    %% STEP 2.1: initial values for the artifcial data
    % Intialize the first nlags observations with real data + plus artificial
    % res. Nontheless, in the estimation of the var on the simulated data, 
    % I through away the first nobs observations so it should not matter.
    LAG=[];
    for jj = 1:nlags
        y_artificial(jj,:) = Y(jj,:) + u(jj,:);
        LAG = [y_artificial(jj,:) LAG]; 
        % Initialize the artificial series and the LAGplus vector
        if c_case==0
            LAGplus = LAG;
        elseif c_case==1
            LAGplus = [1 LAG];
        elseif c_case==2
            T = [1:nobs]';
            LAGplus = [1 T(jj) LAG]; 
        elseif c_case==3
            T = [1:nobs]';
            LAGplus = [1 T(jj) T(jj).^2 LAG];
        end
        if nvar_ex~=0
            LAGplus = [LAGplus exog(jj,:)];
        end
    end
    
    %% STEP 2.2: generate artificial series
    % From observation nlags+1 to nobs, compute the artificial data
    for jj = nlags+1:nobs
        for mm = 1:nvars
            % Compute the value for time=jj
            y_artificial(jj,mm) = LAGplus * beta(1:end,mm) + u(jj,mm);
        end
        % now update the LAG matrix
        LAG = [y_artificial(jj,:) LAG(1,1:(nlags-1)*nvars)];
        if c_case==0
            LAGplus = LAG;
        elseif c_case==1
            LAGplus = [1 LAG];
        elseif c_case==2
            LAGplus = [1 T(jj) LAG];
        elseif c_case==3
            LAGplus = [1 T(jj) T(jj).^2 LAG];
        end
        if nvar_ex~=0
            LAGplus = [LAGplus exog(jj,:)];
        end
    end

%% STEP 3: estimate VAR on artificial data. 
    if nvar_ex~=0
        VAR_draw = VARmodel(y_artificial(1:end,:),nlags,c_case,exog);
    else
        VAR_draw = VARmodel(y_artificial(1:end,:),nlags,c_case);
    end
    
    beta_draw  = VAR_draw.beta;
    sigma_draw = VAR_draw.sigma;

%% STEP 4: calculate "ndraws" impulse responses and store them
    
    [irf_draw, ~] = VARir(VAR_draw,nsteps,ident,impact);
    
    % if you don't have three dimensional arrays this will break.
    IRF(:,:,:,tt) = irf_draw;
    
end

%% Compute the error bands
%=========================
if strcmp(method,'bs') % When using boostratp, use percentile (upper and lower bounds) bands type

    pctg_inf = (100-pctg)/2; 
    pctg_sup = 100 - (100-pctg)/2;
    INF(:,:,:) = prctile(IRF(:,:,:,:),pctg_inf,4);
    SUP(:,:,:) = prctile(IRF(:,:,:,:),pctg_sup,4);
    MED(:,:,:) = prctile(IRF(:,:,:,:),50,4);
else
    error(['The method ' method ' is not available'])
end

