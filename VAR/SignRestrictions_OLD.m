function OUT = SignRestrictions_OLD(sigma,s,SIGN)
%==========================================================================
% Perform vector autogressive (VAR) estimation with OLS 
%==========================================================================
% [VAR, VARopt] = VARmodel(ENDO,nlag,const,EXOG,nlag_ex)
% -------------------------------------------------------------------------
% INPUT
%	- ENDO: an (nobs x nvar) matrix of y-vectors
%	- nlag: lag length
% -------------------------------------------------------------------------
% OPTIONAL INPUT
%	- const: 0 no constant; 1 constant; 2 constant and trend; 3 constant, 
%       trend, and trend^2 [dflt = 0]
%	- EXOG: optional matrix of variables (nobs x nvar_ex)
%	- nlag_ex: number of lags for exogeonus variables [dflt = 0]
% -------------------------------------------------------------------------
% OUTPUT
%   - VAR: structure including VAR estimation results
%   - VARopt: structure including VAR options (see VARoption)
% =========================================================================
% Ambrogio Cesa Bianchi, March 2017
% ambrogio.cesabianchi@gmail.com

% Initialisation
dy = size(SIGN,1);
ds = size(SIGN,2);
whereToStart = 1+dy-ds;
if ~(size(s,2)==whereToStart-1)
    error('s and signRestMat must have coherent sizes')
end
nanMat = NaN*ones(dy,1);
orderIndices = 1:dy;

if whereToStart>1
    options = optimset('TolFun',10e-6,'TolX',10e-6,'MaxIter',10000,'Display','off');
    
    % Find an initial value of Sq that satisfies s*s'+Sq*Sq'=sigmaHat
    exit = 0;
    while ~(exit==1)
        [startingMat,~,exit] = fsolve(@(Sq) Sq*Sq'-sigma+s*s',randn(dy,dy-1),options);
    end
else
    startingMat = chol(sigma,'lower');
end

% While loop
counter = 1;
while 1
counter = counter + 1;
if counter>1000; error('Could not find rotation matrix'); end
    termaa = [s startingMat];
    TermA = 0;
    rotMat = eye(dy);
    rotMat(whereToStart:end,whereToStart:end) = getqr(randn(length(whereToStart:dy)));
    %rotate columns of Sq with Hausholder matrix
    terma = termaa*rotMat;
    termaa = terma;
    %check sign restrictions
    for ii = 1 : ds
        for jj = whereToStart : dy
            if isfinite(terma(1,jj))
                if sum(termaa(:,jj) .* SIGN(:,ii) < 0) == 0
                    TermA = TermA + 1;
                    orderIndices(whereToStart-1+ii) = jj;
                    terma(:,jj) = nanMat;
                    break
                elseif sum(-termaa(:,jj) .* SIGN(:,ii) < 0) == 0
                    TermA = TermA + 1;
                    terma(:,jj) = nanMat;
                    termaa(:,jj) = -termaa(:,jj);
                    orderIndices(ii+whereToStart-1) = jj;
                    break
                    
                end
            end
        end
    end
    if isequal(TermA,ds)
        break
    end
end
OUT=termaa(:,orderIndices);
end

% QR decomposition
function out=getqr(a)
[q,r]=qr(a);
for i=1:size(q,1)
    if r(i,i)<0
        q(:,i)=-q(:,i);
    end
end
out=q;
end


