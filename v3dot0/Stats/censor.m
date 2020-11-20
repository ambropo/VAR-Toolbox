function OUT = censor(X,pct)

[nrow, ncol] = size(X);
OUT = nan(nrow,ncol);
for ii=1:ncol
    x = X(:,ii);
    upp = prctile(x,100-pct);
    low = prctile(x,pct);
    x(x>upp) = NaN;
    x(x<low) = NaN;
    OUT(:,ii) = x;
end