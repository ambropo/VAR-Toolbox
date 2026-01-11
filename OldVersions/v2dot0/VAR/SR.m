function SRout = SR(VAR,R,VARopt)
% =======================================================================
% Compute IRFs, FEVDs, and HDs for a VAR model estimated with VARmodel and 
% identified with sign restrictions
% =======================================================================
% SRout = SR(VAR,R,VARopt)
% -----------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function
%   - R: 3-D matrix containing the sign restrictions (nvar,3,nshocks)
%       described below
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% -----------------------------------------------------------------------
% OUTPUT
%   - SRout
%       * IRFall  : 4-D matrix of IRFs  (nsteps,nvar,nshocks,ndraws)
%       * FEVDall : 4-D matrix of FEVDs (nsteps,nvar,nshocks,ndraws)
%       * HDall   : 4-D matrix of HDs (nsteps,nvar,nshocks,ndraws)
%       * invAall : 4-D matrix of invAs (nvar,nvar,nshocks,ndraws)
%       * IRFmed  : median of IRFall
%       * FEVDmed : median of FEVDall
%       * invAmed : median of invAall
%       * HDmed   : median of HDall
%       * IRFinf  : 16th percentile of IRFall
%       * FEVDinf : 16th percentile of FEVDall
%       * IRFinf  : 16th percentile of HDall
%       * IRFsup  : 84th percentile of IRFall
%       * FEVDsup : 84th percentile of FEVDall
%       * HDsup   : 84th percentile of HDall
% =======================================================================
% Ambrogio Cesa Bianchi, March 2015
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
%   - To leave unrestricted set all three columns to zero
% 
% In the above example we set the following restrictions. VAR1 must respond
% with positive sign from period 1 to period 4; VAR2 must respond with 
% negative sign from period 1 to period 4; VAR3 is left unrestricted
%
% An additional shock could be defined as follows:
%              from        to          sign
%  R(:,:,2) = [ 1           4           1          % VAR1
%               1           4           1          % VAR2
%               1           4          -1];        % VAR3



%% Check inputs
%===============================================
if ~exist('R','var')
    error('You have not provided sign restrictions (R)')
end

if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end


%% Retrieve parameters and preallocate variables
%===============================================
nvar = VAR.nvar;
nsteps = VARopt.nsteps;
ndraws = VARopt.ndraws;
nobs = VAR.nobs;
nlag = VAR.nlag;

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
IRFstore  = nan(nsteps,nvar,nvar,ndraws); 
FEVDstore = nan(nsteps,nvar,nvar,ndraws); 
HDstore = nan(nobs+nlag,nvar,nvar,ndraws); 
invAstore = nan(nvar,nvar,ndraws); 

% Initialize the vectors for the candidate IRF
nsteps_check = max(max(R(:,2,:)));        % maximal length of IRF function to be checked
nsteps_R = max(max(R(:,2,:)-R(:,1,:)))+1; % number of periods with restriction



%% Sign restriction routine
%===============================================
jj = 0; % accepted draws
kk = 0; % total draws
ww = 1; % index for printing on screen
while jj < ndraws
    kk = kk+1;
    if jj==0 && kk>4000, error('Max number of iterations reached. Try different sign restrictions'), end
    
    % 1. Draw a random orthonormal matrix
    if nzr==0 % no zero restrictions
        S = OrthNorm(nvar);
    else % with zero restrictions
        S = eye(nvar);
        auxS = OrthNorm(nsr);
        S(nvar-nsr+1:nvar,nvar-nsr+1:nvar) = auxS;
        clear auxS
    end
    
    % 2. Draw F and sigma from the posterior and set up VAR_draw
    [sigma_draw, Ft_draw] = VARdrawpost(VAR);
    VAR_draw = VAR;
    VAR_draw.Ft = Ft_draw;
    VAR_draw.sigma = sigma_draw;
    
    % 3. Set up VARopt and VAR_draw
    VARopt.ident = 'sr';
    VARopt.nsteps = nsteps_check;
    VAR_draw = VAR;
    VAR_draw.S = S;

    % Compute IRFs only for the restricted periods. IRF_draw has dimension [nsteps_check x nvar]
    [IRF_draw, VAR_draw] = VARir(VAR_draw,VARopt);

    % ... and check whether sign restrictions are satisfied
    checkall = ones(nvar,nshocks);
    checkall_flip = ones(nvar,nshocks);
    for ss=1:nshocks
        for ii = 1:nvar
            if R(ii,1,ss) ~= 0
                if R(ii,3,ss) == 1
                    check = IRF_draw((R(ii,1,ss)):R(ii,2,ss),ii,ss) > 0;
                    checkall(ii,ss) = min(check);
                    % Check flipped signs
                    check_flip = IRF_draw((R(ii,1,ss)):R(ii,2,ss),ii,ss) < 0;
                    checkall_flip(ii,ss) = min(check_flip);
                elseif R(ii,3,ss) == -1
                    check = IRF_draw((R(ii,1,ss)):R(ii,2,ss),ii,ss) < 0;
                    checkall(ii,ss) = min(check);
                    % Check flipped signs
                    check_flip = IRF_draw((R(ii,1,ss)):R(ii,2,ss),ii,ss) > 0;
                    checkall_flip(ii,ss) = min(check_flip);
                end
            end
        end
        clear aux aux_flip
    end

    VARopt.nsteps = nsteps;
    
    % If restrictions are satisfied, compute IRFs for the desired periods (nstep)
    if min(min(checkall))==1
        jj = jj+1 ;
        [aux_irf, VAR_draw] = VARir(VAR_draw,VARopt); 
        IRFstore(:,:,:,jj)  = aux_irf;
        % FEVD
        aux_fevd = VARfevd(VAR_draw,VARopt);
        FEVDstore(:,:,:,jj)  = aux_fevd;
        % HD
        aux_hd = VARhd(VAR_draw);
        HDstore(:,:,:,jj)  = aux_hd.shock;
        % invA
        aux_invA = VAR_draw.invA;
        invAstore(:,:,jj) = aux_invA;
        % Display number of loops
        if jj==10*ww
            disp(['Loop: ' num2str(jj) ' / ' num2str(kk) ' draws']);
            ww=ww+1;
        end
    elseif min(min(checkall_flip))==1
        jj = jj+1 ;
        % IRF (change the sign!)
        [aux_irf, VAR_draw] = VARir(VAR_draw,VARopt); 
        IRFstore(:,:,:,jj)  = -aux_irf;
        % FEVD
        aux_fevd = VARfevd(VAR_draw,VARopt);
        FEVDstore(:,:,:,jj)  = aux_fevd;
        % HD
        aux_hd = VARhd(VAR_draw);
        HDstore(:,:,:,jj)  = aux_hd.shock;
        % invA
        aux_invA = VAR_draw.invA;
        invAstore(:,:,jj) = aux_invA;
        % Display number of loops
        if jj==10*ww
            disp(['Loop: ' num2str(jj) ' / ' num2str(kk) ' draws']);
            ww=ww+1;
        end
    end
end
disp('-- Done!');
disp(' ');


%% Store results
%===============================================

% Store all accepted IRFs and FEVDs
SRout.IRFall  = IRFstore;
SRout.FEVDall = FEVDstore;
SRout.invAall = invAstore;

% Compute and save median impulse response
SRout.IRFmed(:,:,:)  = median(IRFstore,4);
SRout.FEVDmed(:,:,:) = median(FEVDstore,4);
SRout.HDmed(:,:,:) = median(HDstore,4);
SRout.invAmed(:,:,:) = median(invAstore,3);

% Compute lower and upper bounds
aux = prctile(IRFstore,[16 84],4);
SRout.IRFinf = aux(:,:,:,1);
SRout.IRFsup = aux(:,:,:,2);

aux = prctile(FEVDstore,[16 84],4);
SRout.FEVDinf = aux(:,:,:,1);
SRout.FEVDsup = aux(:,:,:,2);

aux = prctile(HDstore,[16 84],4);
SRout.HDinf = aux(:,:,:,1);
SRout.HDsup = aux(:,:,:,2);

clear aux
