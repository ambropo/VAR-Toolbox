function y=nanmovavg(x,n)

aux_x=x;
[aux_NumObs aux_NumVar]=size(x);
window=n;

for j=1:aux_NumVar
    for i=1:window-1
        y(i,j)=NaN;
    end
    for i=window:aux_NumObs
        y(i,j)=mean(y(i-window+1:i,j));
    end
end


    