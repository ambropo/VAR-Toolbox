function [r, b] = bc_shock( A, Sigma, freq_range, nmax) 
% VAR(p) model: y_t = c + A_1*y_t-1 ... A_p y_t-p + u_t , u_t ~ (0,Sigma)
% A = [A_1,...,A_p]' is a p*n times matrix containing the AR matrices (not intercept).   
% Code gets orthogonal vector r, s.t. b = chol(Sigma,'lower')*r is the
% impact effect of the shock that maximizes the variation of variable
% "nmax" at business cycle fequency "freq_range", e.g. [8,32] for quarterly data.
Pchol = chol(Sigma,'lower');
[pn, n]=size(A);
p = floor(pn/n);
Acom = [A(1:p*n,:)';[speye(n*(p-1)),sparse(n*(p-1),n)]]; % Companion form VAR
J = [speye(n),sparse(n,n*(p-1))];  
Ij = eye(n);
ej = Ij(:,nmax);
Inp = speye(n*p);   
Theta_nmax = integral(@(om)spectral_density_j( om,J,Inp,Acom,Pchol,ej ),...
    2*pi/freq_range(2),2*pi/freq_range(1),'ArrayValued',true) ; 
[r,~]=eigs(real(Theta_nmax),1); 
b = Pchol*r; % impact effect of shock
end
function SDM = spectral_density_j( om,J,Inp,Acom,Pchol,ej )   
p1 = ej'*J*( (Inp-Acom*exp(-1i*om))\(J'*Pchol) );  
SDM=  p1'*p1; 
end