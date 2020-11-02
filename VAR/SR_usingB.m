function SRout = SR(VAR,SIGN,VARopt)
% =========================================================================
% Compute IRs, VDs, and HDs for a VAR model estimated with VARmodel and 
% identified with sign restrictions
% =========================================================================
% SRout = SR(VAR,R,VARopt)
% -------------------------------------------------------------------------
% INPUT
%   - VAR: structure, result of VARmodel function
%   - R: 3-D matrix containing the sign restrictions (nvar,3,nshocks)
%       described below
%   - VARopt: options of the VAR (see VARopt from VARmodel)
% -------------------------------------------------------------------------
% OUTPUT
%   - SRout
%       * IRall : 4-D matrix of IRs  (nsteps,nvar,nshocks,ndraws)
%       * IRmed : median of IRall
%       * IRinf : lower bound of IRall
%       * IRsup : upper bound of IRall
% 
%       * VDall : 4-D matrix of VDs (nsteps,nvar,nshocks,ndraws)
%       * VDmed : median of VDall
%       * VDinf : lower bopund of VDall
%       * VDsup : upper bopund of VDall
% 
%       * Ball  : 4-D matrix of Bs (nvar,nvar,nshocks,ndraws)
%       * Bmed  : median of Ball
%       * Binf  : lower bound of Ball
%       * Bsup  : upper bound of Ball
% 
%       * HDmed : structure with median of HDall (not reported)
%       * HDinf : structure with lower bound of HDall (not reported)
%       * HDsup : structure with upper bound of HDall (not reported)
% =========================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa Bianchi, March 2020
% ambrogio.cesabianchi@gmail.com
% -------------------------------------------------------------------------
% Notes:
% -----
% This code follows the notation as in the lecture notes available at
% https://sites.google.com/site/ambropo/MatlabCodes
% -----
% The SIGN matrix has dimension (nvar,nshocks). Assume you have three 
% variables and you want to identify just one shock, which has positive
% impact on the first variable, negative impact on the second variable, and 
% and unrestricted impact on the third variable. The the SIGN matrix 
% should be specified as:
% 
%             shock1      shock2     shock3
%  SIGN = [ 1           0           0          % VAR1
%          -1           0           0          % VAR2
%          -1           0           0];        % VAR3
% 
% That is: the first column defines the signs of the response of the three 
% variables to the first shock.
% -----


%% Check inputs
%==========================================================================
if ~exist('SIGN','var')
    error('You have not provided sign restrictions (SIGN)')
end

if ~exist('VARopt','var')
    error('You need to provide VAR options (VARopt from VARmodel)');
end


%% Retrieve parameters and preallocate variables
%==========================================================================
nvar    = VAR.nvar;
nvar_ex = VAR.nvar_ex;
nsteps  = VARopt.nsteps;
ndraws  = VARopt.ndraws;
nobs    = VAR.nobs;
nlag    = VAR.nlag;
pctg    = VARopt.pctg;

% Initialize empty matrix for the IR draws
IRstore  = nan(nsteps,nvar,nvar,ndraws); 
VDstore = nan(nsteps,nvar,nvar,ndraws); 
HDstore_shock  = zeros(nobs+nlag,nvar,nvar,ndraws); 
HDstore_init   = zeros(nobs+nlag,nvar,ndraws); 
HDstore_const  = zeros(nobs+nlag,nvar,ndraws); 
HDstore_trend  = zeros(nobs+nlag,nvar,ndraws); 
HDstore_trend2 = zeros(nobs+nlag,nvar,ndraws); 
HDstore_endo   = zeros(nobs+nlag,nvar,ndraws); 
HDstore_exo    = zeros(nobs+nlag,nvar,1,ndraws); % third dimension is a trick, will automatically expand if nvar_ex>2
Bstore = nan(nvar,nvar,ndraws); 


%% Sign restriction routine
%==========================================================================
jj = 0; % accepted draws
kk = 0; % total draws
ww = 1; % index for printing on screen
while jj < ndraws
    kk = kk+1;

    % Draw F and sigma from the posterior and set up VAR_draw
    [sigma_draw, Ft_draw] = VARdrawpost(VAR);
    VAR_draw = VAR;
    VAR_draw.Ft = Ft_draw;
    VAR_draw.sigma = sigma_draw;
    VARopt.ident = 'sr';
    
    % Compute rotated B matrix
    B = SignRestrictions(sigma_draw,SIGN,VAR_draw,VARopt); 

    % Store B
    jj = jj+1;
    Bstore(:,:,jj) = B;
    
    % Display number of loops
    if jj==10*ww
        disp(['Loop: ' num2str(jj) ' / ' num2str(kk) ' draws']);
        ww=ww+1;
    end

end
disp('-- Done!');
disp(' ');


%% Store results
%==========================================================================
% All
SRout.Ball = Bstore;
% Median
SRout.Bmed(:,:,:) = median(Bstore,3);
% Compute lower and upper bounds
pctg_inf = (100-pctg)/2; 
pctg_sup = 100 - (100-pctg)/2;
aux = prctile(Bstore,[pctg_inf pctg_sup],3);
SRout.Binf = aux(:,:,1);
SRout.Bsup = aux(:,:,2);

VARopt.ident = 'sr';

%% IRFs
VAR.B = SRout.Bmed;
[SRout.IRmed, VAR] = VARir(VAR,VARopt);
VAR.B = SRout.Binf;
[SRout.IRinf, VAR] = VARir(VAR,VARopt);
VAR.B = SRout.Bsup;
[SRout.IRsup, VAR] = VARir(VAR,VARopt);

%% VDs
VAR.B = SRout.Bmed;
[SRout.VDmed, VAR] = VARvd(VAR,VARopt);
VAR.B = SRout.Binf;
[SRout.VDinf, VAR] = VARvd(VAR,VARopt);
VAR.B = SRout.Bsup;
[SRout.VDsup, VAR] = VARvd(VAR,VARopt);

%% HDs
VAR.B = SRout.Bmed;
[SRout.HDmed, VAR] = VARhd(VAR,VARopt);
VAR.B = SRout.Binf;
[SRout.HDinf, VAR] = VARhd(VAR,VARopt);
VAR.B = SRout.Bsup;
[SRout.HDsup, VAR] = VARhd(VAR,VARopt);

clear aux
