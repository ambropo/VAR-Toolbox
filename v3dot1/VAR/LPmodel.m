function [IR,INF,SUP,LPout] = LPmodel(ENDO,S,LPopt)
%========================================================================
% Perform local projection (LP) estimation with OLS 
%========================================================================
% [IR,INF,SUP,LPout] = LPmodel(ENDO,S,LPopt)
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
%   - INF: lower confidence band
%   - SUP: upper confidence
%   - LPout: structure including LP output
% =======================================================================
% VAR Toolbox 3.1
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% November 2024.
% -----------------------------------------------------------------------

if ~exist('LPopt','var')
    LPopt = LPoption;
end


%% Retrieve and initialize variables 
%==========================================================================
impact = LPopt.impact;
H = LPopt.nsteps;
LAGS = LPopt.LAGS;
EXOG = LPopt.EXOG;
nlag = LPopt.nlag;
const = LPopt.const;
LPout.ENDO = ENDO;
LPout.EXOG = EXOG;
LPout.LAGS = LAGS;
LPout.S = S;

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
LPout.nvar      = nvarS + nvarEXOG + nvarLAGS;
LPout.nlag      = nlag;
ntotcoeff    = const + nvarS + nvarEXOG + nvarLAGS*nlag; 
LPout.ntotcoeff = ntotcoeff;
LPout.const     = const;

% Create independent vector and lagged dependent matrix
if nvarLAGS>0
    [auxY, auxX] = VARmakexy(LAGS,nlag,const);
    lags = auxX;
    endo = ENDO(1+nlag:end,1);
    s = S(1+nlag:end,1);
    if nvarEXOG>0
        exog = EXOG(1+nlag:end,:);
    else
        exog = [];
    end
else
    lags=[];
    endo = ENDO;
    s = S;
    if nvarEXOG>0
        exog = EXOG;
    else
        exog = [];
    end
end 

% Set the size of the shock
if impact==0 
    shock = zscore(s); % one stdev shock
elseif impact==1  
    shocks=s; % unitary shock
else
    error('Impact must be either 0 or 1');
end

LHS = endo;
RHS = [shock exog lags];


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
    LPout.(aux{1}).nobs = nobse;
    LPout.(aux{1}).beta  = OLSout.beta;  % bhats
    LPout.(aux{1}).tstat = OLSout.tstat; % t-stats
    LPout.(aux{1}).bstd  = OLSout.bstd;  % beta std error
    LPout.(aux{1}).bstd_HW = OLSout.bstd_HW; 
    LPout.(aux{1}).bstd_HW = OLSout.bstd_NW; 
    tstat = zeros(ntotcoeff,1);
    tstat = OLSout.tstat;
    tout = tdis_prb(tstat,nobse-ntotcoeff);
    LPout.(aux{1}).tprob = tout;        % t-probs
    LPout.(aux{1}).resid = OLSout.resid;% resids 
    LPout.(aux{1}).yhat  = OLSout.yhat; % yhats
    LPout.(aux{1}).y     = Y;        % actual y
    LPout.(aux{1}).x     = X;        % actual y
    LPout.(aux{1}).rsqr  = OLSout.rsqr; % r-squared
    LPout.(aux{1}).rbar  = OLSout.rbar; % r-adjusted
    LPout.(aux{1}).dw    = OLSout.dw;   % DW
    LPout.(aux{1}).sigma = OLSout.sige;   % DW

    IR(hh,1) = OLSout.beta(1);
    conf = norminv(1 - (1-LPopt.pctg/100)/2);
    INF(hh,1) = IR(hh)-conf*OLSout.bstd_HW(1);
    SUP(hh,1) = IR(hh)+conf*OLSout.bstd_HW(1);
    LPout.IR = IR;


end 




