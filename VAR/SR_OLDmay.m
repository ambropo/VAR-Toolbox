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
    VAR_draw.Bdraw = B; % Update VAR_draw with the rotated B matrix 
    jj = jj+1;

    % Compute and store IR, VD, HD
    [aux_irf, VAR_draw] = VARir(VAR_draw,VARopt); 
    IRstore(:,:,:,jj)  = aux_irf;
    aux_fevd = VARvd(VAR_draw,VARopt);
    VDstore(:,:,:,jj)  = aux_fevd;
    aux_hd = VARhd(VAR_draw);
    HDstore_shock(:,:,:,jj) = aux_hd.shock;
    HDstore_init(:,:,jj)    = aux_hd.init;
    HDstore_const(:,:,jj)   = aux_hd.const;
    HDstore_trend(:,:,jj)   = aux_hd.trend;
    HDstore_trend2(:,:,jj)  = aux_hd.trend2;
    HDstore_endo(:,:,jj)    = aux_hd.endo;
    if nvar_ex>0; HDstore_exo(:,:,:,jj) = aux_hd.exo; end

    % Store B
    Bstore(:,:,jj) = VAR_draw.B;
    
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
% Store all accepted IRs and VDs
SRout.IRall  = IRstore;
SRout.VDall = VDstore;
SRout.Ball = Bstore;

% Compute and save median impulse response
SRout.IRmed(:,:,:)  = median(IRstore,4);
SRout.VDmed(:,:,:) = median(VDstore,4);
SRout.Bmed(:,:,:) = median(Bstore,3);
SRout.HDmed.shock(:,:,:)  = median(HDstore_shock,4);
SRout.HDmed.init(:,:,:)   = median(HDstore_init,3);
SRout.HDmed.const(:,:,:)  = median(HDstore_const,3);
SRout.HDmed.trend(:,:,:)  = median(HDstore_trend,3);
SRout.HDmed.trend2(:,:,:) = median(HDstore_trend2,3);
SRout.HDmed.endo(:,:,:)   = median(HDstore_endo,3);
SRout.HDmed.exo(:,:,:)    = median(HDstore_exo,4);

% Compute lower and upper bounds
pctg_inf = (100-pctg)/2; 
pctg_sup = 100 - (100-pctg)/2;
zaux = prctile(IRstore,[pctg_inf pctg_sup],4);
SRout.IRinf = aux(:,:,:,1);
SRout.IRsup = aux(:,:,:,2);

aux = prctile(VDstore,[pctg_inf pctg_sup],4);
SRout.VDinf = aux(:,:,:,1);
SRout.VDsup = aux(:,:,:,2);

aux = prctile(HDstore_shock,[pctg_inf pctg_sup],4);
SRout.HDinf.shock = aux(:,:,:,1);
SRout.HDsup.shock = aux(:,:,:,2);

aux = prctile(HDstore_init,[pctg_inf pctg_sup],3);
SRout.HDinf.init = aux(:,:,1);
SRout.HDsup.init = aux(:,:,2);

aux = prctile(HDstore_const,[pctg_inf pctg_sup],3);
SRout.HDinf.const = aux(:,:,1);
SRout.HDsup.const = aux(:,:,2);

aux = prctile(HDstore_trend,[pctg_inf pctg_sup],3);
SRout.HDinf.trend = aux(:,:,1);
SRout.HDsup.trend = aux(:,:,2);

aux = prctile(HDstore_trend2,[pctg_inf pctg_sup],3);
SRout.HDinf.trend2 = aux(:,:,1);
SRout.HDsup.trend2 = aux(:,:,2);

aux = prctile(HDstore_endo,[pctg_inf pctg_sup],3);
SRout.HDinf.endo = aux(:,:,1);
SRout.HDsup.endo = aux(:,:,2);

aux = prctile(HDstore_exo,[pctg_inf pctg_sup],4);
SRout.HDinf.exo = aux(:,:,1);
SRout.HDsup.exo = aux(:,:,2);

clear aux
