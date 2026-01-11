function B = SignRestrictions(SIGN,VAR,VARopt)
% =======================================================================
% Draws orthonormal rotations of the VAR covariance matrix until 
% satisfies the signs specified in SIGN.
% =======================================================================
% SignRestrictions(SIGN,VAR,VARopt)
% -----------------------------------------------------------------------
% INPUT
%	- SIGN: matrix with sign restrictions
%   - VAR: structure, result of VARmodel.m
%   - VARopt: options of the VAR (result of VARmodel.m)
% -----------------------------------------------------------------------
% OUTPUT
%   - B: impact matrix consistent with SIGN 
% =======================================================================
% VAR Toolbox 3.0
% Ambrogio Cesa-Bianchi
% ambrogiocesabianchi@gmail.com
% August 2018. Updated February 2021
% -----------------------------------------------------------------------

%% Check inputs
% -----------------------------------------------------------------------
dy = size(SIGN,1);
ds = size(SIGN,2);

% Check whether columns of B (and corresponding sigma) are already provided
if isempty(VAR.Biv)
    if size(SIGN,1)==size(SIGN,2)
        sigma = VAR.sigma;
        Biv = [];
    % If SIGN is missing a column, assume corresponding Cholesky
    elseif size(SIGN,1)>size(SIGN,2)
        sigma = VAR.sigma;
        aux = chol(sigma)';
        Biv = aux(:,size(SIGN,1)-size(SIGN,2));
    else
        error('Matrix SIGN has the wrong dimension');
    end

else
    sigma = VAR.sigma_b;
    Biv = VAR.Biv;
end

% Defines which columns of sigma have to be rotated
whereToStart = 1+dy-ds;
if ~(size(Biv,2)==whereToStart-1)
    error('Biv and SIGN must have coherent sizes')
end
nanMat = NaN*ones(dy,1);
orderIndices = 1:dy;

%% Search for rotations that satisfy SIGN and Biv
% -----------------------------------------------------------------------
counter = 1; flag = 0;
while 1
    % Create starting matrix to be rotated.
    % If one column of B has already been provided:
    if whereToStart>1
        C = chol(sigma,'lower');
        q = C\Biv; 
        for ii = whereToStart:dy
            r = randn(dy,1);
            q = [q (eye(dy)-q*q')*r/norm((eye(dy)-q*q')*r)];
        end
        % Check that q*q'=I:
        %q*q'
        startingMat = C*q;
        % Check that startingMat*startingMat'=SigmaHat:
        % startingMat*startingMat'
        % Check that first column of startingMat = Biv
        % [startingMat(:,1) Biv]
    % Otherwise start from a lower Cholesky
    else
        startingMat = chol(sigma,'lower');
    end
    counter = counter + 1;
    if counter>VARopt.sr_rot
        %disp('---------------------------------------------')
        %disp( 'The routine could not find any rotation that satisfies the restrictions in SIGN.')
        %disp(['The max number of rotations (' num2str(VARopt.sr_rot) ') has been reached.']);
        %disp( 'Change the restrictions or increase VARopt.sr_rot');
        %disp('---------------------------------------------')
        flag = 1;
        break
        %error('ERROR. See details above');
    end
    termaa = [startingMat];
    TermA = 0;
    rotMat = eye(dy);
    rotMat(whereToStart:end,whereToStart:end) = getqr(randn(length(whereToStart:dy)));
    % Rotate columns of Sq with Hausholder matrix
    terma = termaa*rotMat;
    termaa = terma;
    % Update VAR_draw with the rotated B matrix 
    VAR.B = termaa; 
    % If sr_hor>1, compute IRF for horizon to be checked
    if VARopt.sr_hor>1
        VARopt.nsteps=VARopt.sr_hor;
        [aux_irf, VAR] = VARir(VAR,VARopt);
    end
    % Check sign restrictions
    for ii = 1 : ds
        for jj = whereToStart : dy
            if isfinite(terma(1,jj))
                % Create CHECK matrix to check the signs
                if VARopt.sr_hor>1
                    CHECK = aux_irf(:,:,jj)';
                else
                    CHECK = terma(:,jj);
                end
                if sum(CHECK.* SIGN(:,ii) < 0) == 0
                    TermA = TermA + 1;
                    orderIndices(whereToStart-1+ii) = jj;
                    terma(:,jj) = nanMat;
                    break
                elseif sum(-CHECK.* SIGN(:,ii) < 0) == 0
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
if flag==0; B=termaa(:,orderIndices); else; B=[]; end
counter;
end
