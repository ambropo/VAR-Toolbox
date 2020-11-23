function [INF,SUP,MED,BAR] = VARfevdband(VAR,VARopt)
% =======================================================================
% Calculate confidence intervals for forecast error variance decomposition
% computed with VARfevd
% =======================================================================
% [INF,SUP,MED,BAR] = VARfevdband(VAR,VARopt)
% -----------------------------------------------------------------------
% INPUTS 
%   - VAR: structure, result of VARmodel->VARfevd function
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% -----------------------------------------------------------------------
% OUTPUT
%   - INF(t,j,k): lower confidence band (t steps, j variable, k shock)
%   - SUP(t,j,k): upper confidence band (t steps, j variable, k shock)
%   - MED(t,j,k): median response (t steps, j variable, k shock)
%   - BAR(t,j,k): mean response (t steps, j variable, k shock)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015. Modified: August 2015
% ambrogio.cesabianchi@gmail.com

% I thank Fabien Tripier for finding a bug in STEP 2.2 for the case of
% constant and trend (const==2).


%% Check inputs
%===============================================
if ~exist('VAR','var')
    error('You need to provide VAR structure, result of VARmodel');
end
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end


%% Retrieve and initialize variables 
%===============================================
nsteps = VARopt.nsteps;
ndraws = VARopt.ndraws;
pctg   = VARopt.pctg;
method = VARopt.method;

Ft      = VAR.Ft; % rows are coefficients, columns are equations
nvar    = VAR.nvar;
nvar_ex = VAR.nvar_ex;
nlag    = VAR.nlag;
nlag_ex = VAR.nlag_ex;
const   = VAR.const;
nobs    = VAR.nobs;
resid   = VAR.residuals;
ENDO    = VAR.ENDO;
EXOG    = VAR.EXOG;

INF = zeros(nsteps,nvar,nvar);
SUP = zeros(nsteps,nvar,nvar);
MED = zeros(nsteps,nvar,nvar);
BAR = zeros(nsteps,nvar,nvar);

%% Create the matrices for the loop
%===============================================
y_artificial = zeros(nobs+nlag,nvar);

%% Loop over the number of draws
%===============================================

tt = 1; % numbers of accepted draws
ww = 1; % index for printing on screen
while tt<=ndraws
    
    % Display number of loops
    if tt==10*ww
        disp(['Loop ' num2str(tt) ' / ' num2str(ndraws) ' draws'])
        ww=ww+1;
    end

%% STEP 1: choose the method and generate the residuals
    if strcmp(method,'bs')
        % Use the residuals to bootstrap: generate a random number bounded 
        % between 0 and # of residuals, then use the ceil function to select 
        % that row of the residuals (this is equivalent to sampling with replacement)
        u = resid(ceil(size(resid,1)*rand(nobs,1)),:);
    elseif strcmp(method,'wild')
        % Wild bootstrap based on simple distribution (~Rademacher)
        rr = 1-2*(rand(nobs,1)>0.5);
        u = resid.*(rr*ones(1,nvar));
    else
        error(['The method ' method ' is not available'])
    end

%% STEP 2: generate the artificial data

    %% STEP 2.1: generate initial values for the artificial data
    % Intialize the first nlag observations with real data
    LAG=[];
    for jj = 1:nlag
        y_artificial(jj,:) = ENDO(jj,:);
        LAG = [y_artificial(jj,:) LAG]; 
    end
    % Initialize the artificial series and the LAGplus vector
    T = [1:nobs]';
    if const==0
        LAGplus = LAG;
    elseif const==1
        LAGplus = [1 LAG];
    elseif const==2
        LAGplus = [1 T(1) LAG]; 
    elseif const==3
        T = [1:nobs]';
        LAGplus = [1 T(1) T(1).^2 LAG];
    end
    if nvar_ex~=0
        LAGplus = [LAGplus VAR.X_EX(jj-nlag+1,:)];
    end
    
    %% STEP 2.2: generate artificial series 
    % From observation nlag+1 to nobs, compute the artificial data
    for jj = nlag+1:nobs+nlag
        for mm = 1:nvar
            % Compute the value for time=jj
            y_artificial(jj,mm) = LAGplus * Ft(1:end,mm) + u(jj-nlag,mm);
        end
        % now update the LAG matrix
        if jj<nobs+nlag
            LAG = [y_artificial(jj,:) LAG(1,1:(nlag-1)*nvar)];
            if const==0
                LAGplus = LAG;
            elseif const==1
                LAGplus = [1 LAG];
            elseif const==2
                LAGplus = [1 T(jj-nlag+1) LAG];
            elseif const==3
                LAGplus = [1 T(jj-nlag+1) T(jj-nlag+1).^2 LAG];
            end
            if nvar_ex~=0
                LAGplus = [LAGplus VAR.X_EX(jj-nlag+1,:)];
            end
        end
    end

%% STEP 3: estimate VAR on artificial data
    if nvar_ex~=0
        [VAR_draw, ~] = VARmodel(y_artificial,nlag,const,EXOG,nlag_ex);
    else
        [VAR_draw, ~] = VARmodel(y_artificial,nlag,const);
    end

%% STEP 4: calculate "ndraws" fevd and store them

    [fevd_draw, VAR_draw_opt] = VARfevd(VAR_draw,VARopt); % uses options from VARopt, but companion etc. from VAR_draw
    
    if VAR_draw_opt.maxEig<.9999
        FEVD(:,:,:,tt) = fevd_draw;
        tt=tt+1;
    end
end
disp('-- Done!');
disp(' ');

%% Compute the error bands
%===============================================
pctg_inf = (100-pctg)/2; 
pctg_sup = 100 - (100-pctg)/2;
INF(:,:,:) = prctile(FEVD(:,:,:,:),pctg_inf,4);
SUP(:,:,:) = prctile(FEVD(:,:,:,:),pctg_sup,4);
MED(:,:,:) = prctile(FEVD(:,:,:,:),50,4);
BAR(:,:,:) = mean(FEVD(:,:,:,:),4);
