function OUT = L(X,nlags)
% =======================================================================
% Creates a matrix (or vector) of lagged values (the first obs are NaN)
% =======================================================================
% OUT = L(X,nlags)
% -----------------------------------------------------------------------
% INPUTS 
%   - X: input matrix (nobs X nvars)
%   - nlags: order of lags (-1 is lag ---- +1 is lead)
% -----------------------------------------------------------------------
% OUTPUT
%	- OUT: lagged matrix (nobs X nvars), the first obs are NaN
% -----------------------------------------------------------------------
% NOTES
%	- If nlags = 0, the original series is returned
% =========================================================================
% Ambrogio Cesa Bianchi, July 2013
% ambrogiocesabianchi@gmail.com
%-------------------------------------------------------------------------
% Updated October 2013

% This script is based on lag.m script by James P. LeSage

init = NaN;

switch(nargin)
    
case 1
    error('Missing input: number of lags');

case 2
   if nlags > 0 % this is lead
       zt = ones(nlags,cols(X))*init;
       OUT = [trimr(X,nlags,0); zt];

   elseif nlags < 0 % this is lag
       zt = ones(abs(nlags),cols(X))*init;
       OUT = [ zt; trimr(X,0,abs(nlags))];
   
   else
       OUT = X;
   
   end

otherwise
    error('Too many inputs for function L');
end

  
