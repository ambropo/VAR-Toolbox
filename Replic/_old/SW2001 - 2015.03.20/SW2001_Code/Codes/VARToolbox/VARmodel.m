function VARout = VARmodel(ENDO,nlag,c_case,EXOG,nlag_ex)
% =======================================================================
% Performs vector autogressive estimation
% =======================================================================
% VARout = VARmodel(ENDO,nlag,c_case,EXOG)
% -----------------------------------------------------------------------
% INPUTS 
%   ENDO = an (nobs x neqs) matrix of y-vectors
%	nlag = the lag length
%
% OPTIONAL INPUTS
%   c_case  = 0 no const; 1 const ; 2 const&trend; 3 const&trend^2; (default = 1)
%	EXOG = optional matrix of variables (nobs x nvar_ex)
%   nlag_ex = number of lags for exogeonus variables (default = 0)
%--------------------------------------------------------------------------
% OUTPUT
%    VARout.X         = independent variable (ordered as in VARmakexy)
%    VARout.Y         = dependent variable
%    VARout.X_EX      = matrix of exogenous variables
%    VARout.beta      = matrix of estimated coefficients (ordered as in VARmakexy)
%    VARout.sigma     = VCV matrix of residuals (adjusted for dof)
%    VARout.nobs      = nobs, observations adjusted (i.e., removing the lags)
%    VARout.neqs      = neqs, equations
%    VARout.nlag      = nlag, lags
%    VARout.nvar      = nlag*neqs, endogenous variables per equation
%    VARout.nvar_ex   = nvar_ex, exogenous variables;
%    VARout.ntotcoeff = nlag*neqs+nvar_ex+c_case, coefficients to estimate (per equation)
%    VARout(eq).beta  = bhat for equation eq
%    VARout(eq).tstat = t-statistics 
%    VARout(eq).tprob = t-probabilities
%    VARout(eq).resid = residuals 
%    VARout(eq).yhat  = predicted values 
%    VARout(eq).y     = actual values 
%    VARout(eq).rsqr  = r-squared
%    VARout(eq).rbar  = r-squared adjusted
%    VARout(eq).sige  = e'e/(n-nvar)
%    VARout(eq).boxq  = Box Q-statistics
%    VARout(eq).ftest = Granger F-tests
%    VARout(eq).fprob = Granger marginal probabilities
% =======================================================================
% Ambrogio Cesa Bianchi, May 2012
% ambrogio.cesabianchi@gmail.com

% Note: this code is a modified version of of the vare.m function of James 
% P. LeSage

% Note: compared to Eviews, there is a difference in the estimation of the 
% constant when lag is > 2. This is because Eviews initialize the trend
% with the number of lags (i.e., when lag=2, the trend is [2 3 ...T]), 
% while VARmakexy.m initialize the trend always with 1.




%% Check inputs
%==============
[nobs, neqs] = size(ENDO);

% Check if ther are constant, trend, both, or none
if ~exist('c_case','var')
    c_case = 1;
end

% Check if there are exogenous variables
if exist('EXOG','var')
    [nobs2, num_ex] = size(EXOG);
    % Check that ENDO and EXOG are conformable
    if (nobs2 ~= nobs)
        error('var: nobs in EXOG-matrix not the same as y-matrix');
    end
    clear nobs2
else
    num_ex = 0;
end

% Check if there is lag order of EXOG, otherwise set it to 0
if ~exist('nlag_ex','var')
    nlag_ex = 0;
end


%% Save some parameters and create data for VAR estimation
%=========================================================
    nobse            = nobs - max(nlag,nlag_ex);
    VARout.nobs      = nobse;
    VARout.neqs      = neqs;
    VARout.nlag      = nlag;
    VARout.nlag_ex   = nlag_ex;
    nvar             = neqs*nlag; 
    VARout.nvar      = nvar;
    nvar_ex          = num_ex*(nlag_ex+1);
    VARout.nvar_ex   = nvar_ex;
    ntotcoeff        = nvar + nvar_ex + c_case;
    VARout.ntotcoeff = ntotcoeff;
    VARout.c_case    = c_case;

% Create independent vector and lagged dependent matrix
[Y, X] = VARmakexy(ENDO,nlag,c_case);

% Create (lagged) exogeanous matrix
if nvar_ex>0
    X_EX  = VARmakelags(EXOG,nlag_ex);
    if nlag == nlag_ex
        X = [X X_EX];
    elseif nlag > nlag_ex
        diff = nlag - nlag_ex;
        X_EX = X_EX(diff+1:end,:);
        X = [X X_EX];
    elseif nlag < nlag_ex
        diff = nlag_ex - nlag;
        Y = Y(diff+1:end,:);
        X = [X(diff+1:end,:) X_EX];
    end
end


%% OLS estimation equation by equation
%=====================================

% pull out each y-vector and run regressions
for j=1:neqs;
    Yvec = Y(:,j);
    ols_struct = ols(Yvec,X);
    aux = ['eq' num2str(j)];
    eval( ['VARout.' aux '.beta  = ols_struct.beta;'] );        % bhats
    eval( ['VARout.' aux '.tstat = ols_struct.tstat;'] );       % t-stats
    % compute t-probs
    tstat = zeros(nvar,1);
    tstat = ols_struct.tstat;
    tout = tdis_prb(tstat,nobse-nvar);
    eval( ['VARout.' aux '.tprob = tout;'] );                   % t-probs
    eval( ['VARout.' aux '.resid = ols_struct.resid;'] );       % resids 
    eval( ['VARout.' aux '.yhat = ols_struct.yhat;'] );         % yhats
    eval( ['VARout.' aux '.y    = Yvec;'] );                    % actual y
    eval( ['VARout.' aux '.rsqr = ols_struct.rsqr;'] );         % r-squared
    eval( ['VARout.' aux '.rbar = ols_struct.rbar;'] );         % r-adjusted
    eval( ['VARout.' aux '.sige = ols_struct.sige;'] );

    % do the Q-statistics
    % use residuals to do Box-Pierce Q-stats
    % use lags = nlag in the VAR
    % NOTE: a rule of thumb is to use (1/6)*nobs but this seems excessive to me
    elag = mlag(ols_struct.resid,nlag);
    % feed the lags
    etrunc = elag(nlag+1:nobse,:);
    rtrunc = ols_struct.resid(nlag+1:nobse,1);
    qres   = ols(rtrunc,etrunc);
    if nlag ~= 1
    	boxq = (qres.rsqr/(nlag-1))/((1-qres.rsqr)/(nobse-nlag));
    else
        boxq = (qres.rsqr/(nlag))/((1-qres.rsqr)/(nobse-nlag));
    end

    eval( ['VARout.' aux '.boxq = boxq;'] );

    % form matrices for joint F-tests (exclude each variable sequentially)
    for r=1:neqs;
        xtmp = [];
        for s=1:neqs
            if s ~= r
                xlag = mlag(ENDO(:,s),nlag);
                if nlag == nlag_ex
                    xtmp = [xtmp trimr(xlag,nlag,0)];
                elseif nlag > nlag_ex
                    xtmp = [xtmp trimr(xlag,nlag,0)];
                elseif nlag < nlag_ex
                    xtmp = [xtmp trimr(xlag,nlag+diff,0)];
                end
            end
        end
        % we have an xtmp matrix that excludes 1 variable
        % add deterministic variables (if any) and constant term
        if nvar_ex > 0
            xtmp = [xtmp X_EX ones(nobse,1)];
        else
            xtmp = [xtmp ones(nobse,1)];
        end
        % get ols residual vector
        b = xtmp\Yvec; % using Cholesky solution
        etmp = Yvec-xtmp*b;
        sigr = etmp'*etmp;
        % joint F-test for variables r
        sigu = ols_struct.resid'*ols_struct.resid;
        ftest(r,1) = ((sigr - sigu)/nlag)/(sigu/(nobse-nvar)); 
    end

    if c_case~=0
        if sum(ftest<0)==0 %Shortcut to make the code working. Fix this in next realeses of the toolbox
            eval( ['VARout.' aux '.sige = ols_struct.sige;'] );
            eval( ['VARout.' aux '.ftest = ftest;' ]);     
            eval( ['VARout.' aux '.fprob = fdis_prb(ftest,nlag,nobse-nvar);' ]);
        end
    end

end % end of loop over equations 


%% Compute the matrix of coefficients & VCV
%==========================================
BETA = (X'*X)^(-1)*(X'*Y); % ordered by block lags (i.e., all coefficients with first lag, then second,...)
VARout.beta = BETA;
SIGMA = (1/(nobse-ntotcoeff))*(Y-X*BETA)'*(Y-X*BETA); % adjusted for # of estimated coeff per equation
VARout.sigma = SIGMA;
VARout.residuals = Y - X*BETA;

VARout.X = X;
VARout.Y = Y;
if nvar_ex > 0
    VARout.X_EX = X_EX;
end
