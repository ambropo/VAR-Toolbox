function OUT = L(X,nlag)
% =======================================================================
% Creates a matrix (or vector) of lagged values (the first obs are NaN)
% =======================================================================
% OUT = L(X,nlag)
% -----------------------------------------------------------------------
% INPUT
%	- X: input matrix (nobs X nvars)
%	- nlag: order of lags (-1 is lag ---- +1 is lead)
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: lagged matrix (nobs X nvars), the first obs are NaN
% -----------------------------------------------------------------------
% NOTES
%	- If nlag = 0, the original series is returned
% =========================================================================
% Ambrogio Cesa Bianchi, March 2015
% ambrogiocesabianchi@gmail.com

% Notes: this script is based on lag.m script by James P. LeSage

init = NaN;
switch(nargin)
    case 1
        error('Missing input: number of lags');
    case 2
       if nlag > 0 % this is lead
           zt = ones(nlag,cols(X))*init;
           OUT = [trimr(X,nlag,0); zt];
       elseif nlag < 0 % this is lag
           zt = ones(abs(nlag),cols(X))*init;
           OUT = [ zt; trimr(X,0,abs(nlag))];
       else
           OUT = X;
       end
    otherwise
        error('Too many inputs for function L');
end

  
