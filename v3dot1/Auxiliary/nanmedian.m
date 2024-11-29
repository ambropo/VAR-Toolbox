function y = nanmedian(x,dim)
% FORMAT: Y = NANMEDIAN(X,DIM)
% 
%    Median ignoring NaNs
%
%    This function enhances the functionality of NANMEDIAN as distributed
%    in the MATLAB Statistics Toolbox and is meant as a replacement (hence
%    the identical name).  
%
%    NANMEDIAN(X,DIM) calculates the mean along any dimension of the N-D
%    array X ignoring NaNs.  If DIM is omitted NANMEDIAN averages along the
%    first non-singleton dimension of X.
%
%    Similar replacements exist for NANMEAN, NANSTD, NANMIN, NANMAX, and
%    NANSUM which are all part of the NaN-suite.
%
%    See also MEDIAN

% -------------------------------------------------------------------------
%    author:      Jan Gl�scher
%    affiliation: Neuroimage Nord, University of Hamburg, Germany
%    email:       glaescher@uke.uni-hamburg.de
%    
%    $Revision: 1.2 $ $Date: 2007/07/30 17:19:19 $

if isempty(x)
	y = [];
	return
end

if nargin < 2
	dim = min(find(size(x)~=1));
	if isempty(dim)
		dim = 1;
	end
end

siz  = size(x);
n    = size(x,dim);

% Permute and reshape so that DIM becomes the row dimension of a 2-D array
perm = [dim:max(length(size(x)),dim) 1:dim-1];
x = reshape(permute(x,perm),n,prod(siz)/n);


% force NaNs to bottom of each column
x = sort(x,1);

% identify and replace NaNs
nans = isnan(x);
x(isnan(x)) = 0;

% new dimension of x
[n m] = size(x);

% number of non-NaN element in each column
s = size(x,1) - sum(nans);
y = zeros(size(s));

% now calculate median for every element in y
% (does anybody know a more eefficient way than with a 'for'-loop?)
for i = 1:length(s)
	if rem(s(i),2) & s(i) > 0
		y(i) = x((s(i)+1)/2,i);
	elseif rem(s(i),2)==0 & s(i) > 0
		y(i) = (x(s(i)/2,i) + x((s(i)/2)+1,i))/2;
	end
end

% Protect against a column of NaNs
i = find(y==0);
y(i) = i + nan;

% permute and reshape back
siz(dim) = 1;
y = ipermute(reshape(y,siz(perm)),perm);

% $Id: nanmedian.m,v 1.2 2007/07/30 17:19:19 glaescher Exp glaescher $
