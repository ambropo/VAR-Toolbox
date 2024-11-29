function y = nansem(x,dim)
% FORMAT: Y = NANSEM(X,DIM)
% 
%    Standard error of the mean ignoring NaNs
%
%    NANSTD(X,DIM) calculates the standard error of the mean along any
%    dimension of the N-D array X ignoring NaNs.  
%
%    If DIM is omitted NANSTD calculates the standard deviation along first
%    non-singleton dimension of X.
%
%    Similar functions exist: NANMEAN, NANSTD, NANMEDIAN, NANMIN, NANMAX, and
%    NANSUM which are all part of the NaN-suite.

% -------------------------------------------------------------------------
%    author:      Jan Gläscher
%    affiliation: Neuroimage Nord, University of Hamburg, Germany
%    email:       glaescher@uke.uni-hamburg.de
%    
%    $Revision: 1.1 $ $Date: 2004/07/22 09:02:27 $

if isempty(x)
	y = NaN;
	return
end

if nargin < 2
	dim = min(find(size(x)~=1));
	if isempty(dim)
		dim = 1; 
	end	  
end


% Find NaNs in x and nanmean(x)
nans = isnan(x);

count = size(x,dim) - sum(nans,dim);


% Protect against a  all NaNs in one dimension
i = find(count==0);
count(i) = 1;

y = nanstd(x,dim)./sqrt(count);

y(i) = i + NaN;

% $Id: nansem.m,v 1.1 2004/07/22 09:02:27 glaescher Exp glaescher $
