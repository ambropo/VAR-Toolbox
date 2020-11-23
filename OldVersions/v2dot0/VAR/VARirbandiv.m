function [INF,SUP,MED,BAR] = VARirbandiv(VAR,VARopt,IV)
% =======================================================================
% Calculates confidence intervals for impulse response functions computed
% with VARiriv
% =======================================================================
% [INF,SUP,MED,BAR] = VARirbandiv(VAR,VARopt,IV)
% -----------------------------------------------------------------------
% INPUTS 
%   - VAR: VAR results obtained with VARmodel (structure)
%	- VARopt: options of the IRFs (see VARoption)
% -----------------------------------------------------------------------
% OUTPUT
%   - INF(t,j): lower confidence band (t steps, j variable)
%   - SUP(t,j): upper confidence band (t steps, j variable)
%   - MED(t,j): median response (t steps, j variable)
%   - BAR(t,j): mean response (t steps, j variable)
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015. Modified: August 2015
% ambrogio.cesabianchi@gmail.com


%% Check inputs
%===============================================
if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end
if ~exist('IV','var')
    error('You need to provide an instrumental variable (IV)');
end


%% Retrieve and initialize variables 
%=============================================================
nsteps = VARopt.nsteps;
ndraws = VARopt.ndraws;
pctg   = VARopt.pctg;
method = VARopt.method;

Ft      = VAR.Ft;  % rows are coefficients, columns are equations
nvar    = VAR.nvar;
nvar_ex = VAR.nvar_ex;
nlag    = VAR.nlag;
nlag_ex = VAR.nlag_ex;
const   = VAR.const;
nobs    = VAR.nobs;
resid   = VAR.residuals;
ENDO    = VAR.ENDO;
EXOG    = VAR.EXOG;

INF = zeros(nsteps,nvar);
SUP = zeros(nsteps,nvar);
MED = zeros(nsteps,nvar);
BAR = zeros(nsteps,nvar);

%% Create the matrices for the loop
%==================================
y_artificial = zeros(nobs+nlag,nvar);


%% Loop over the number of draws
%==========================================================================

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
        error(['The method ' method ' is not available for VARirbandiv. Use wild boostrap.'])
    elseif strcmp(method,'wild')
        % Wild bootstrap based on simple distribution (~Rademacher)
        rr = 1-2*(rand(nobs,1)>0.5);
        u = resid.*(rr*ones(1,nvar));
        Z = [IV(1:nlag,1); IV(nlag+1:end,1).*rr];
    else
        error(['The method ' method ' is not available'])
    end

%% STEP 2: generate the artificial data

    %% STEP 2.1: initial values for the artificial data
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

%% STEP 3: estimate VAR on artificial data. 
    if nvar_ex~=0
        [VAR_draw, ~] = VARmodel(y_artificial,nlag,const,EXOG,nlag_ex);
    else
        [VAR_draw, ~] = VARmodel(y_artificial,nlag,const);
    end
    
%% STEP 4: calculate "ndraws" impulse responses and store them

    [irf_draw, ~] = VARiriv(VAR_draw,VARopt,Z);  % uses options from VARopt, but companion etc. from VAR_draw
    
    if VAR_draw.maxEig<.9999
        IRF(:,:,:,tt) = irf_draw;
        tt=tt+1;
    end
end
disp('-- Done!');
disp(' ');

%% Compute the error bands
%=========================
pctg_inf = (100-pctg)/2; 
pctg_sup = 100 - (100-pctg)/2;
INF(:,:) = prctile(IRF(:,:,:),pctg_inf,3);
SUP(:,:) = prctile(IRF(:,:,:),pctg_sup,3);
MED(:,:) = prctile(IRF(:,:,:),50,3);
BAR(:,:) = mean(IRF(:,:,:),3);
