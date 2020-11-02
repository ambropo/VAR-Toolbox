clear all, close all  
clc
format long
addpath(pathdef)


%% CHOOSE ESTIMATION & IDENTIFICATION
%------------------------------------

identification = 1; % Sign restriction
% identification = 2; % Choleski

do_plot =1;

%% PRELIMINARY 
%-------------

% Load the data. Data matrix consists of:[gdp, p, pcom, ff, nbr, tr, m1]
[data text] = xlsread('Example_BVAR_SignRestriction.xlsx','series');

% Define labels for plots
labels = text(1,2:end);
dates = text(2:end,1);

% Transform some data
data(:,1) = log(data(:,1))*100;
data(:,5) = log(data(:,5))*100;
data(:,6) = log(data(:,6))*100;
data(:,7) = log(data(:,7))*100;

% Define the variables to be used in the BVAR (order matters!)
DATA = data(:,1:3);
% DATA = data(:,1:2);

% Define number of variables and of observations
[nobs_raw nvars] = size(DATA);

% Set the case for the VAR (0, 1, or 2)
cons = 0;
% Set number of nlags
nlags = 2;
% number of periods of IRF
nsteps = 10;
% number of draws
ndraws = 100;

% Estimate the VAR
VAR = VARmodel(DATA,nlags,cons);

% Define an empty matrix(:,:,:) for the median 
IRF_median = zeros(nvars, 1, nsteps);
% Define an empty matrix(:,:,:,:) for the error bands
imp_sign_restr_perc = zeros(nvars, 1, nsteps, 2);
% Define an empty matrix saving all IRF
IRF_big = zeros(nvars,1,nsteps,ndraws); 


%% IDENTIFICATION
%----------------

%--------------------------------------------------------------------------
if identification == 1
%--------------------------------------------------------------------------

% Specify the sign restriction...
%                                    positive (1)
%                from        to      negative (0)
Restrictions = [ 1           4           0          %gdp
                 1           4           0          %p
                 1           4           0          %pcom
%                  1           4           1          %ff
%                  0           0           0          %nbr
%                  0           0           0          %tr
%                  0           0           0          %m1
               ];  

    i_big_loop = 0;
    ii         = 0;
    bayesian   = 0;

    while i_big_loop < ndraws
        ii = ii+1;

        if bayesian == 1
            % draw sigma_draw and coeffecient matrix (Bayesian), or...      
            [sigma_draw beta_draw] = BVARdrawpost(VAR); 
        else
            % ... use the estimated sigma (non Bayesian)
            sigma_draw = VAR.sigma;
            beta_draw = VAR.beta;
        end
        
        % compute cholesky decomposition
        low_chol = chol(sigma_draw)';
        
        % Create a random vector (nvars x 1) of unit length (i.e., sum of square is equal one)
        alpha_draw  = randn(nvars,1);
        % alpha_draw(1) = 0; % If you want a zero restriction on the first variable
        norm_alpha  = sqrt(alpha_draw'*alpha_draw);
        alpha_draw  = alpha_draw/norm_alpha; % Notice that alpha_draw'*alpha_draw=1
        
        A = RandOrthMat(3);
                
        % Draw a random candidate impulse vector (see Appendix A -did I mean from Uligh paper??-: impulse is a column of A)
%         impulse = low_chol*alpha_draw;
        impulse = low_chol*A(:,1);
        
        % Initialize the vectors for the candidate IRF
        aux_step = max(Restrictions(:,2)); % maximal length of IRF function to be checked
        rest_vec_length = max(Restrictions(:,2)-Restrictions(:,1))+1; % number of periods with restriction
        
        % Compute IRFs only for the restricted periods... nvarsXnsteps
        IRF_candidate = BVARir_single(VAR, sigma_draw, beta_draw, impulse, aux_step)'; % calls a function that computes IRF only for aux_step periods

        % ... and check whether sign restrictions are satisfied
        Big_check = ones(nvars, rest_vec_length); % matrix where checks will be stored
        for i_cs = 1:nvars
            if Restrictions(i_cs, 1) ~= 0
                if Restrictions(i_cs, 3)  == 1
                    check_colummn = [IRF_candidate(i_cs,(Restrictions(i_cs,1)):Restrictions(i_cs,2),1)>0];
                    Big_check(i_cs,1:size(check_colummn,2))=check_colummn;
                else
                    check_colummn = [IRF_candidate(i_cs,(Restrictions(i_cs,1)):Restrictions(i_cs,2),1)<0];
                    Big_check(i_cs,1:size(check_colummn,2))=check_colummn;
                end
            end
        end

        % If restrictions are satisfied, compute IRFs for the desired periods (nstep)
        check_it = Big_check;
        if (min(check_it)==1) % if all restrictions are satisfied:
            i_big_loop     = i_big_loop+1 ;
            disp(['Loop: ' num2str(i_big_loop) ' / ' num2str(ii) ' draws']);
            IRF_full  = BVARir_single(VAR, sigma_draw, beta_draw, impulse, nsteps); % compute IRF for 'nstep' periods
            % re-shape IRF_full in a matrix (var1,var2,periods)
            IRF_reshaped = reshape(IRF_full',nvars,1,nsteps);
            % 
            IRF_big(:,:,:,i_big_loop)=IRF_reshaped;
        end
    end
    
%--------------------------------------------------------------------------
elseif identification == 2  % Choleski
%--------------------------------------------------------------------------
    for i_big_loop=1:ndraws
        
        % Define the variable to be shocked
        shock_pos = 1; 
        
        % Construct the vector impulse
        impulse = zeros(nvars,1); 
        impulse(shock_pos)=1;
        
        % draw sigma_draw and coeffecient matrix
        [sigma_draw beta_draw] = BVARdrawpost(VAR); 
        % compute cholesky decomposition
        low_chol = chol(sigma_draw)';
        
        disp(['Loop: ' num2str(i_big_loop) ' / ' num2str(i_big_loop) ' draws']);
        
        IRF_full  = BVARir_single(VAR, sigma_draw, beta_draw, impulse, nsteps); % compute IRF for 'nstep' periods
        IRF_reshaped = reshape(IRF_full',nvars,1,nsteps);
        IRF_big(:,:,:,i_big_loop) = IRF_reshaped;

    end

end

%% PLOT IRFs
%-----------

% Compute median impulse response (median is over the draws i.e., 4th coulumn of IRF_big)
IRF_median(:,:,:) = median(IRF_big,4); % median impulse responses

% Compute error bands
for n_per=1:nsteps
    for i_per=1:nvars
        imp_sign_restr_perc(i_per,1,n_per,1) = prctile(IRF_big(i_per,:,n_per,:),16);
        imp_sign_restr_perc(i_per,1,n_per,2) = prctile(IRF_big(i_per,:,n_per,:),84);
    end
end

% Example: to get the impulse response of variable ordered 1, you type:
example = reshape(IRF_median(1,1,:),1,nsteps)';
% which to take the first variable from 1 to nsteps 

if do_plot==1

    %  Define the optimale size of the plot (max 24 charts)  
    row = round(sqrt(nvars));
    col = ceil(sqrt(nvars));

    % Define a timeline
    irf_step = 1:1:nsteps;
    x_axis = zeros(1,nsteps);

    for ii=1:nvars
        subplot(row,col,ii);
        plot(irf_step,reshape(IRF_median(ii,1,:),1,nsteps),'b','LineWidth',1.5); hold on;
        plot(irf_step,reshape(imp_sign_restr_perc(ii,1,:,1),1,nsteps),'--b','LineWidth',1); hold on;
        plot(irf_step,reshape(imp_sign_restr_perc(ii,1,:,2),1,nsteps),'--b','LineWidth',1); hold on;
        plot(x_axis,'k','LineWidth',0.5)
        xlim([1 nsteps]);
        title(labels(ii), 'FontWeight','bold','FontSize',10); set(gca,'FontSize',8);
        xlabel('Quarters after shock');
        ylabel('Percent deviation');
    end
    
end

% close all
