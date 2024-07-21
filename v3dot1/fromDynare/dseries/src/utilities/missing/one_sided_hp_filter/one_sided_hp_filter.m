function [ytrend,ycycle]=one_sided_hp_filter(y,lambda,x_user,P_user,discard)
% function [ytrend,ycycle]=one_sided_hp_filter(y,lambda,x_user,P_user,discard)
% Conducts one-sided HP-filtering, derived using the Kalman filter
%
% Inputs:
%   y           [T*n] double    data matrix in column format
%   lambda      [scalar]        Smoothing parameter. Default value of 1600 will be used.
%   x_user      [2*n] double    matrix with initial values of the state
%                               estimate for each variable in y. The underlying
%                               state vector is 2x1 for each variable in y.
%                               Default: use backwards extrapolations
%                               based on the first two observations
%   P_user      [n*1] struct    structural array with n elements, each a two
%                               2x2 matrix of intial MSE estimates for each
%                               variable in y.
%                               Default: matrix with large variances
%   discard     [scalar]        number of initial periods to be discarded
%                               Default: 0
%
% Output:
%   ytrend      [(T-discard)*n] matrix of extracted trends
%   ycycle      [(T-discard)*n] matrix of extracted deviations from the extracted trends
%
% Algorithms:
%
%   Implements the procedure described on p. 301 of Stock, J.H. and M.W. Watson (1999):
%   "Forecasting inflation," Journal of Monetary Economics,  vol. 44(2), pages 293-335, October.
%   that states on page 301:
%
%       "The one-sided HP trend estimate is constructed as the Kalman
%       filter estimate of tau_t in the model:
%
%       y_t=tau_t+epsilon_t
%       (1-L)^2 tau_t=eta_t"
%
%  The Kalman filter notation follows Chapter 13 of Hamilton, J.D. (1994).
%   Time Series Analysis, with the exception of H, which is equivalent to his H'.


% Copyright (C) 200?-2015 Alexander Meyer-Gohde
% Copyright (C) 2015-2017 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <https://www.gnu.org/licenses/>.

if nargin < 2 || isempty(lambda)
    lambda = 1600; %If the user didn't provide a value for lambda, set it to the default value 1600
end
[T,n] = size (y);% Calculate the number of periods and the number of variables in the series

%Set up state space
q=1/lambda;     % the signal-to-noise ration: i.e. var eta_t / var epsilon_t
F=[2,-1;
   1,0];       % state transition matrix
H=[1,0];        % observation matrix
Q=[q,0;
   0,0];        % covariance matrix state equation errors
R=1;            % variance observation equation error

for k=1:n %Run the Kalman filter for each variable
    if nargin < 3 || isempty(x_user) %no intial value for state, extrapolate back two periods from the observations
        x=[2*y(1,k)-y(2,k);
           3*y(1,k)-2*y(2,k)];
    else
        x=x_user(:,k);
    end
    if nargin < 4 || isempty(P_user) %no initial value for the MSE, set a rather high one
        P= [1e5 0;
            0 1e5];
    else
        P=P_user{k};
    end

    for j=1:T %Get the estimates for each period
        [x,P]=kalman_update(F,H,Q,R,y(j,k),x,P); %get new state estimate and update recursion
        ytrend(j,k)=x(2);%second state is trend estimate
    end
end

if nargout==2
    ycycle=y-ytrend;
end

if nargin==5 %user provided a discard parameter
    ytrend=ytrend(discard+1:end,:);%Remove the first "discard" periods from the trend series
    if nargout==2
        ycycle=ycycle(discard+1:end,:);
    end
end
end

function   [x,P]=kalman_update(F,H,Q,R,obs,x,P)
% Updates the Kalman filter estimation of the state and MSE
S=H*P*H'+R;
K=F*P*H';
K=K/S;
x=F*x+K*(obs -H*x); %State estimate
Temp=F-K*H;
P=Temp*P*Temp';
P=P+Q+K*R*K';%MSE estimate
end
