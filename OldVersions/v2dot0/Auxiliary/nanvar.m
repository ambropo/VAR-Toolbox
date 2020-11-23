function y = nanvar(x,dim,flag)
% FORMAT: Y = NANVAR(X,DIM,FLAG)
% 
%    Variance ignoring NaNs
%
%    This function enhances the functionality of NANVAR as distributed in
%    the MATLAB Statistics Toolbox and is meant as a replacement (hence the
%    identical name).  
%
%    NANVAR(X,DIM) calculates the standard deviation along any dimension of
%    the N-D array X ignoring NaNs.  
%
%    NANVAR(X,DIM,0) normalizes by (N-1) where N is SIZE(X,DIM).  This make
%    NANVAR(X,DIM).^2 the best unbiased estimate of the variance if X is
%    a sample of a normal distribution. If omitted FLAG is set to zero.
%    
%    NANVAR(X,DIM,1) normalizes by N and produces second moment of the 
%    sample about the mean.
%
%    If DIM is omitted NANVAR calculates the standard deviation along first
%    non-singleton dimension of X.
%
%    Similar replacements exist for NANMEAN, NANMEDIAN, NANMIN, NANMAX, 
%    NANSTD, and NANSUM which are all part of the NaN-suite.
%
%    See also STD

% -------------------------------------------------------------------------
%    author:      Jan Gläscher
%    affiliation: Neuroimage Nord, University of Hamburg, Germany
%    email:       glaescher@uke.uni-hamburg.de
%    
%    $Revision: 1.1 $ $Date: 2008/05/02 21:46:17 $

if isempty(x)
	y = NaN;
	return
end

if nargin < 3
	flag = 0;
end

if nargin < 2
	dim = min(find(size(x)~=1));
	if isempty(dim)
		dim = 1; 
	end	  
end


% Find NaNs in x and nanmean(x)
nans = isnan(x);
avg = nanmean(x,dim);

% create array indicating number of element 
% of x in dimension DIM (needed for subtraction of mean)
tile = ones(1,max(ndims(x),dim));
tile(dim) = size(x,dim);

% remove mean
x = x - repmat(avg,tile);

count = size(x,dim) - sum(nans,dim);

% Replace NaNs with zeros.
x(isnan(x)) = 0; 


% Protect against a  all NaNs in one dimension
i = find(count==0);

if flag == 0
	y = sum(x.*x,dim)./max(count-1,1);
else
	y = sum(x.*x,dim)./max(count,1);
end
y(i) = i + NaN;

% $Id: nanvar.m,v 1.1 2008/05/02 21:46:17 glaescher Exp glaescher $
