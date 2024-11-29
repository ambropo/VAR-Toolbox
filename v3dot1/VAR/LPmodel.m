function [IR, LP] = LPmodel(ENDO,S,LPopt)
%========================================================================
% Perform vector autogressive (VAR) estimation with OLS 
%========================================================================
% [VAR, VARopt] = LPmodel(ENDO,nlag,const,EXOG,nlag_ex)
% -----------------------------------------------------------------------
% INPUT
%	- ENDO: an (nobs x 1) vector of endo variable
%	- S: an (nobs x 1) vector of variable to project (a time t)
% -----------------------------------------------------------------------
% OPTIONAL INPUT
%   - LPopt: structure including LP options (see LPoption)
% -----------------------------------------------------------------------
% OUTPUT
%   - IR: projection of ENDO on S
%   - LP: structure including LP output
% =======================================================================
% VAR Toolbox 3.1
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2024.
% -----------------------------------------------------------------------


%% Retrieve and initialize variables 
%==========================================================================
H = LPopt.H;
LAGS = LPopt.LAGS;
EXOG = LPopt.EXOG;
nlag = LPopt.nlag;
const = LPopt.const;
LP.ENDO = ENDO;
LP.EXOG = EXOG;
LP.LAGS = LAGS;
LP.S = S;

%% Check inputs
% -----------------------------------------------------------------------
[nobsENDO, nvarENDO] = size(ENDO);
[nobsEXOG, nvarEXOG] = size(EXOG);
[nobsLAGS, nvarLAGS] = size(LAGS);
[nobsS, nvarS] = size(S);

% Check that ENDO and EXOG are conformable
if (nobsS ~= nobsENDO) 
    error('S has different number of observations from ENDO');
    if nvarEXOG>0
        if (nobsEXOG ~= nobsENDO) 
            error('EXOG has different number of observations from ENDO');
        end
    end
    if nvarLAGS>0
        if (nobsLAGS ~= nobsENDO)
            error('LAGS has different number of observations from ENDO');
        end
    end

end

% Check that lag is greater than 1, otherwise LAGSrols enter
% LAGSemporaneously
if ~exist('nlag','var')
    error('Number of lags (nlags) needed');
else
    if nlag<1
        error('Number of lags (nlags) needs to be greater or equal than 0');
    end
end

% Check if ther are constant, trend, both, or none
if ~exist('const','var')
    const = 1;
end


%% Save some parameters and create data matrices
% -----------------------------------------------------------------------
LP.nvar      = nvarS + nvarEXOG + nvarLAGS;
LP.nlag      = nlag;
ntotcoeff    = const + nvarS + nvarEXOG + nvarLAGS*nlag; 
LP.ntotcoeff = ntotcoeff;
LP.const     = const;

% Create independent vector and lagged dependent matrix
if nvarLAGS>0
    [auxY, auxX] = VARmakexy(LAGS,nlag,const);
    lags = auxX;
    endo = ENDO(1+nlag:end,1);
    shoc = S(1+nlag:end,1);
    if nvarEXOG>0
        exog = EXOG(1+nlag:end,:);
    else
        exog = [];
    end
else
    lags=[];
    endo = ENDO;
    shoc = S;
    if nvarEXOG>0
        exog = EXOG;
    else
        exog = [];
    end
end 
LHS = endo;
RHS = [shoc exog lags];


%% OLS estimation
% -----------------------------------------------------------------------
IR = nan(H,1);
for hh=1:H
    
    % Index for saving OLS output at each horoizon
    eval(['aux = {''h' num2str(hh) '''};']);
    
    % Adjust Y and X for horizon
    Y = LHS(1+hh-1:end);
    X = RHS(1:end-hh+1,:);
    
    % Estimate OLS
    OLSout = OLSmodel(Y,X,0);
    nobse = length(Y);
    LP.(aux{1}).nobs = nobse;
    LP.(aux{1}).beta  = OLSout.beta;  % bhats
    LP.(aux{1}).tstat = OLSout.tstat; % t-stats
    LP.(aux{1}).bstd  = OLSout.bstd;  % beta std error
    tstat = zeros(ntotcoeff,1);
    tstat = OLSout.tstat;
    tout = tdis_prb(tstat,nobse-ntotcoeff);
    LP.(aux{1}).tprob = tout;        % t-probs
    LP.(aux{1}).resid = OLSout.resid;% resids 
    LP.(aux{1}).yhat  = OLSout.yhat; % yhats
    LP.(aux{1}).y     = Y;        % actual y
    LP.(aux{1}).x     = X;        % actual y
    LP.(aux{1}).rsqr  = OLSout.rsqr; % r-squared
    LP.(aux{1}).rbar  = OLSout.rbar; % r-adjusted
    LP.(aux{1}).dw    = OLSout.dw;   % DW
    LP.(aux{1}).sigma = OLSout.sige;   % DW

    IR(hh)=OLSout.beta(1);
    LP.IR = IR;

end 




