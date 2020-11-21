
function res=LPir(y,nLags,nHorizon,NWlags,deltai,errorBands)

% computes IRFs using local projection method (Jorda 2005)
%
% Y_{t+h}=a_{h}+B_{1}^{h+1}y_{t-1}+...+B_{p}^{h+1}y_{t-p}+u_{t+h}
% IRF(t,h,d_{i})=E(y_{t+h}|u_t=d_{i})-E(y_{t+h}|u_t=0)=B_{1}^{h}d_{i} h=1:H
% 
% inputs:
% y=[Txn] matrix of data
% nLags=number of lags in VAR
% nHorizon=maximum IRFs horizon
% NWlags=lags for HAC covariances
% deltai=[1xN] vector of zeros but shock size at shock position
% errorBands=if true also produces 95% error bands
%
% output: structure (responses to the chosen structural shock only)
% irfs=[(nH+1)xn] matrix of responses to structural shock
% irfs_u & irfs_l=[(nH+1)xn] matrices of error bands 
%
% miranda 2014 smirandaagrippino@london.edu

%--------------------------------------------------------------------------

[T,n]=size(y); nL=nLags; nH=nHorizon;

% Build a matrix including leads and lags of y of the followiong form:
% [y_{t+h},...,y_{t+1},y_{t},y_{t-1},...,y_{t-p}]'
nY=n*(nL+nH); 
iY=ismember(1:nY,n*nH+1:n*(nH+1));      % identifies dependent
iLead=ismember(1:nY,1:n*nH);            % identifies leads 
iLag=ismember(1:nY,nY-n*(nL-1)+1:nY);   % identifies lags
Y=NaN(T-(nL+nH)+1,nY);
for j=nL:nL+nH
    Y(:,n*(j-1)+1:n*j)=y(nL+nH-j+1:end-j+1,:);
%     Y(:,n*(j-1)+1:n*j)=y(j-nL+1:end-j-nH,:);
end
nT=size(Y,1);

%VAR innovations
trend = (1:nT)'; trend2 = (1:nT)'.^2;
v = Y(:,iY)-[ones(nT,1) Y(:,iLag)]*([ones(nT,1) Y(:,iLag)]\Y(:,iY));
% v = Y(:,iY)-[ones(nT,1) trend Y(:,iLag)]*([ones(nT,1) trend Y(:,iLag)]\Y(:,iY));
% v = Y(:,iY)-[ones(nT,1) trend trend2 Y(:,iLag)]*([ones(nT,1) trend trend2 Y(:,iLag)]\Y(:,iY));
% VAR = VARmodel(y,nLags,3)

SigmaV=cov(v); Bzero=chol(SigmaV); Bzero=bsxfun(@rdivide,Bzero,diag(Bzero));
%Bzero: structuralShock=VARinnovations*B; B=inv(Bzero);

%local projection
projCoeffs=[ones(nT,1) Y(:,~iLead)]\Y(:,iLead);
% projCoeffs=[ones(nT,1) trend Y(:,~iLead)]\Y(:,iLead);
% projCoeffs=[ones(nT,1) trend trend2 Y(:,~iLead)]\Y(:,iLead);
irfCoeffs=projCoeffs(2:n+1,:); %irf coefficients [nx(n*nH)] grouped per lag

%structural responses
LocalProjStructuralIRF=NaN(n,nH+1);
LocalProjStructuralIRF(:,1)=deltai'*Bzero; %on impact
LocalProjStructuralIRF(:,2:end)=fliplr(reshape(deltai'*Bzero*irfCoeffs,n,nH));

if errorBands
    %error bands (Hamilton (1994))
    %variance of proj coeffs: SigmaB=Q^{-1}*SigmaU*Q^{-1} (but here x and u are
    %orthogonal!) SigmaU=HACvar(proj residuals)
    u=Y(:,iLead)-[ones(nT,1) Y(:,~iLead)]*projCoeffs; u=bsxfun(@minus,u,mean(u)); %projection residuals
    SigmaU=u'*u; %HAC error (T*)covariance estimator
    nwweight=(NWlags+1-(1:NWlags))./(NWlags+1);
    for j=1:NWlags
        Gammaj=(u(j+1:nT,:)'*u(1:nT-j,:));
        SigmaU=SigmaU+nwweight(j)*(Gammaj+Gammaj');
    end
    Qi=inv([ones(nT,1) Y(:,~iLead)]'*[ones(nT,1) Y(:,~iLead)]); nX=length(Qi);
    %
    lpirfUpperBound=LocalProjStructuralIRF; lpirfLowerBound=LocalProjStructuralIRF;
    diBzero=kron(eye(n),[zeros(nX,1),kron([0;1;zeros(n*nL-1,1)],deltai'*Bzero),zeros(nX,n*(nL-1))]);
    for h=1:nH
        SigmaB=kron(diag(diag(SigmaU(n*(h-1)+1:n*h,n*(h-1)+1:n*h)))/(nT-nL),Qi);
        Omega=diBzero*SigmaB*diBzero'; Omega=Omega(Omega~=0).^0.5*1.96;
        lpirfUpperBound(:,nH-h+1)=lpirfUpperBound(:,nH-h+1)+Omega;
        lpirfLowerBound(:,nH-h+1)=lpirfLowerBound(:,nH-h+1)-Omega;
    end
    %on impact
    Qi=inv([ones(nT,1) Y(:,iLag)]'*[ones(nT,1) Y(:,iLag)]); nX=length(Qi);
    SigmaB=kron(diag(diag(SigmaV))/(nT-nL),Qi);
    diBzero=kron(eye(n),[zeros(nX,1),kron([0;1;zeros(n*(nL-1)-1,1)],deltai'*Bzero),zeros(nX,n*(nL-2))]);
    Omega=diBzero*SigmaB*diBzero'; Omega=Omega(Omega~=0).^0.5*1.96;
    lpirfUpperBound(:,1)=lpirfUpperBound(:,1)+Omega;
    lpirfLowerBound(:,1)=lpirfLowerBound(:,1)-Omega;
else
    lpirfUpperBound=NaN(n,nH+1); lpirfLowerBound=NaN(n,nH+1);
end

%load results
res.irfs=LocalProjStructuralIRF';
res.irfs_u=lpirfUpperBound';
res.irfs_l=lpirfLowerBound';



