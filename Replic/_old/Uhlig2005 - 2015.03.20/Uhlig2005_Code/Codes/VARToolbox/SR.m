function SRout = SR(VAR,nsteps,R,ndraws)
% =======================================================================
% Compute IRFs and FEVDs for a VAR model estimated with VARmodel and 
% identified with sign restrictions
% =======================================================================
% SRout = SR(VAR,nsteps,R,ndraws)
% -----------------------------------------------------------------------
% INPUT
%   - VAR     : structure, result of VARmodel function
%   - nsteps  : number of nsteps to compute the IRFs
%   - R       : 3-D matrix containing the sign restrictions (nvar,3,nshocks)
%               described below
%   - ndraws  : number of (accepted) draws to store
% 
% OUTPUT
%   - SRout.IRF_all  : 4-D matrix of IRFs  (nsteps,nvar,nshocks,ndraws)
%   - SRout.FEVD_all : 4-D matrix of FEVDs (nsteps,nvar,nshocks,ndraws)
%   - SRout.invA_all : 4-D matrix of invAs (nvar,nvar,nshocks,ndraws)
%   - SRout.IRF_med  : median of IRF_all
%   - SRout.FEVD_med : median of FEVD_all
%   - SRout.invA_med : median of invA_all
%   - SRout.IRF_inf  : 16th percentile of IRF_all
%   - SRout.IRF_sup  : 84th percentile of IRF_all
%   - SRout.FEVD_inf : 16th percentile of FEVD_all
%   - SRout.FEVD_sup : 84th percentile of FEVD_all
% =======================================================================
% Ambrogio Cesa Bianchi, January 2014
% ambrogio.cesabianchi@gmail.com

% Note. This code follows the notation as in the lecture notes available at
% https://sites.google.com/site/ambropo/MatlabCodes

% The R matrix is a 3-D matrix with dimension (nvar,3,nshocks). Assume you
% have 3 variables and you want to identify just one shock. Then:
% 
%              from        to          sign
%  R(:,:,1) = [ 1           4           1          % VAR1
%               1           4          -1          % VAR2
%               0           0           0];        % VAR3
% 
%   - The first column defines the first period from which the restriction is imposed 
%   - The second column defines the last period to which the restriction is imposed 
%   - The last column defines the sign of the restriction: positive (1) or negative (-1)
%   - To leave unrestricted set all thre columns to zero
% 
% In the above example we set the following restrictions. VAR1 must respond
% with positive sign from period 1 to period 4; VAR2 must respond with 
% negative sign from period 1 to period 4; VAR3 is left unrestricted
%
% An additional shock woul be defined as 
%              from        to          sign
%  R(:,:,2) = [ 1           4           1          % VAR1
%               1           4           1          % VAR2
%               1           4          -1];        % VAR3

%% Check inputs
%===============================================
if ~exist('ndraws','var')
    ndraws = 300;
end




%% Retrieve parameters and preallocate variables
%===============================================
nvar = VAR.neqs;

% Determines the number of shocks, of sign restrictions (nsr) and zero 
% restrictions (nzr)
nshocks = size(R,3);
nzr = 0; 
for ss=1:nshocks
    if sum(sum(R(:,:,ss)))==0
        nzr = nzr +1;
    end    
end
nsr = nshocks - nzr;

% Initialize empty matrix for the IRF draws
IRFstore  = nan(nsteps,nvar,nshocks,ndraws); 
FEVDstore = nan(nsteps,nvar,nshocks,ndraws); 
invAstore = nan(nvar,nvar,nshocks,ndraws); 

% Initialize the vectors for the candidate IRF
nsteps_check = max(max(R(:,2,:)));        % maximal length of IRF function to be checked
nsteps_R = max(max(R(:,2,:)-R(:,1,:)))+1; % number of periods with restriction



%% Sign restriction routine
%===============================================
for ss=1:nshocks
    jj = 0;
    kk = 0;
    tic
    while jj < ndraws
        kk = kk+1;

        % Draw a random orthonormal matrix
        % a) no zero restrictions
        if nzr==0
            S = OrthNorm(nvar);
        % b) with zero restrictions
        else
            S = eye(nvar);
            auxS = OrthNorm(nsr);
            S(nvar-nsr+1:nvar,nvar-nsr+1:nvar) = auxS;
            clear auxS
        end

        % Compute IRFs only for the restricted periods... IRF_candidate has
        % dimension [nsteps_check x nvar]
        IRF_candidate = VARir(VAR,nsteps_check,'sr',0,S);

        % ... and check whether sign restrictions are satisfied
        check      = ones(nsteps_R, nvar); % matrix where checks will be stored
        check_flip = ones(nsteps_R, nvar); % matrix where checks will be stored for flipped signs
        for ii = 1:nvar
            if R(ii,1,ss) ~= 0
                if R(ii,3,ss)  == 1
                    aux = IRF_candidate((R(ii,1,ss)):R(ii,2,ss),ii,ss) > 0;
                    check((R(ii,1,ss)):R(ii,2,ss),ii)= aux;
                    % Check flipped signs
                    aux = IRF_candidate((R(ii,1,ss)):R(ii,2,ss),ii,ss) < 0;
                    check_flip((R(ii,1,ss)):R(ii,2,ss),ii)= aux;
                else
                    aux = IRF_candidate((R(ii,1,ss)):R(ii,2,ss),ii,ss) < 0;
                    check((R(ii,1,ss)):R(ii,2,ss),ii)= aux;
                    % Check flipped signs
                    aux = IRF_candidate((R(ii,1,ss)):R(ii,2,ss),ii,ss) > 0;
                    check_flip((R(ii,1,ss)):R(ii,2,ss),ii)= aux;
                end
            end
        end
        clear aux

        % If restrictions are satisfied, compute IRFs for the desired periods (nstep)
        if min(check)==1
            jj = jj+1 ;
            % IRF (change the sign!)
            [loop_irf, loop_IRF_opt] = VARir(VAR,nsteps,'sr',0,S); 
            IRFstore(:,:,ss,jj)  = loop_irf(:,:,ss);
            % FEVD
            aux_fevd = VARfevd(VAR,nsteps,'sr',S);
            FEVDstore(:,:,ss,jj)  = aux_fevd(:,:,ss);
            % invA
            aux_invA = loop_IRF_opt.invA;
            invAstore(:,:,ss,jj) = aux_invA;
            % Display number of loops
            disp(['Shock ' num2str(ss) ' -- Loop: ' num2str(jj) ' / ' num2str(kk) ' draws']);
        elseif min(check_flip)==1
            jj = jj+1 ;
            % IRF (change the sign!)
            [loop_irf, loop_IRF_opt] = VARir(VAR,nsteps,'sr',0,S); 
            IRFstore(:,:,ss,jj)  = -loop_irf(:,:,ss);
            % FEVD
            aux_fevd = VARfevd(VAR,nsteps,'sr',S);
            FEVDstore(:,:,ss,jj)  = aux_fevd(:,:,ss);
            % invA
            aux_invA = loop_IRF_opt.invA;
            invAstore(:,:,ss,jj) = aux_invA;
            % Display number of loops
            disp(['Shock ' num2str(ss) ' -- Loop: ' num2str(jj) ' / ' num2str(kk) ' draws']);
        end
    end
    disp([' ']);
end




%% Store results
%===============================================

% Store all accepted IRFs and FEVDs
SRout.IRF_all  = IRFstore;
SRout.FEVD_all = FEVDstore;
SRout.invA_all = invAstore;

% Compute and ave median impulse response
SRout.IRF_med(:,:,:)  = median(IRFstore,4);
SRout.FEVD_med(:,:,:) = median(FEVDstore,4);
SRout.invA_med(:,:,:) = median(invAstore,4);

% Compute lower and upper bounds
aux = prctile(IRFstore,[16 84],4);
SRout.IRF_inf = aux(:,:,:,1);
SRout.IRF_sup = aux(:,:,:,2);

aux = prctile(FEVDstore,[16 84],4);
SRout.FEVD_inf = aux(:,:,:,1);
SRout.FEVD_sup = aux(:,:,:,2);
clear aux
